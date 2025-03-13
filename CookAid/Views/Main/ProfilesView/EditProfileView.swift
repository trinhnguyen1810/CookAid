import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore // Add this import statement


struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var newName: String = ""
    @State private var selectedImage: PhotosPickerItem? // For image selection
    @State private var profileImage: Image? // For displaying the selected image
    @State private var imageData: Data? // For uploading the image

    var body: some View {
        VStack(spacing: 20) {
            // Profile Picture
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            // Name TextField
            TextField("Full Name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.custom("Cochin", size: 18)) // Set font style

            // Image Picker
            PhotosPicker(selection: $selectedImage, matching: .images) {
                Text("Select Profile Picture")
                    .font(.custom("Cochin", size: 18))
                    .foregroundColor(.black)
            }
            .onChange(of: selectedImage) { newItem in
                Task {
                    // Retrieve selected asset in the form of Data
                    if let newItem = newItem {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            imageData = data
                            profileImage = Image(uiImage: UIImage(data: data)!)
                        }
                    }
                }
            }

            // Save Button
            Button(action: {
                updateProfile()
            }) {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black) // Set background color to black
                    .foregroundColor(.white) // Set text color to white
                    .cornerRadius(8)
                    .font(.custom("Cochin", size: 18)) // Set font style
            }
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            if let user = viewModel.currentUser {
                newName = user.fullname // Pre-fill the name field
                if let profilePicture = user.profilePicture, let url = URL(string: profilePicture) {
                    // Load the image from the URL if available
                    loadImage(from: url)
                }
            }
        }
    }

    private func loadImage(from url: URL) {
        // Load the image from the URL (this is a placeholder, implement actual loading)
        // You can use URLSession or any image loading library to fetch the image
    }

    private func updateProfile() {
        // Update the user's profile with the new name and profile picture
        if let user = viewModel.currentUser {
            let updatedUser = User(id: user.id, fullname: newName, email: user.email, profilePicture: nil) // Update with new name
            viewModel.currentUser = updatedUser // Update the current user in the view model
            
            // Handle image upload if imageData is not nil
            if let imageData = imageData {
                uploadImage(imageData) { imageUrl in
                    // Update the user with the new profile picture URL
                    if let imageUrl = imageUrl {
                        let updatedUserWithImage = User(id: user.id, fullname: newName, email: user.email, profilePicture: imageUrl)
                        viewModel.currentUser = updatedUserWithImage // Update the current user in the view model
                        // Save updated user data to Firestore
                        saveUserToFirestore(updatedUserWithImage)
                    }
                }
            } else {
                // If no image is uploaded, just save the updated name
                saveUserToFirestore(updatedUser)
            }
        }
        presentationMode.wrappedValue.dismiss() // Dismiss the view
    }

    private func saveUserToFirestore(_ user: User) {
        // Save the updated user data to Firestore
        let db = Firestore.firestore()
        do {
            let encodedUser = try Firestore.Encoder().encode(user)
            db.collection("users").document(user.id).setData(encodedUser) { error in
                if let error = error {
                    print("DEBUG: Failed to update user in Firestore with error: \(error.localizedDescription)")
                } else {
                    print("DEBUG: User updated successfully in Firestore with ID: \(user.id)")
                }
            }
        } catch {
            print("DEBUG: Failed to encode user with error: \(error.localizedDescription)")
        }
    }

    private func uploadImage(_ data: Data, completion: @escaping (String?) -> Void) {
        // Create a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a unique filename for the image
        let fileName = UUID().uuidString // Generate a unique ID for the image
        let storageRef = storage.reference().child("profile_images/\(fileName).jpg") // Path in Firebase Storage

        // Upload the image data to Firebase Storage
        let uploadTask = storageRef.putData(data, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload image with error: \(error.localizedDescription)")
                completion(nil) // Return nil on failure
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("DEBUG: Failed to retrieve download URL with error: \(error.localizedDescription)")
                    completion(nil) // Return nil on failure
                    return
                }
                // Return the download URL as a string
                completion(url?.absoluteString)
            }
        }
        
        // Optionally, you can observe the upload progress
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("DEBUG: Upload is \(percentComplete * 100)% complete")
        }
    }
}
