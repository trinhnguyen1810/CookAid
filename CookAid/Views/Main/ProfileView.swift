import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel  // Changed to lowercase for convention

    var body: some View {
        if let user = viewModel.currentUser {  // Updated to use the correct viewModel reference
            VStack(spacing: 20) {
                // Profile Header
                HStack {
                    // Profile Picture
                    Image(systemName: "person.fill") // Replace with actual profile picture
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding()
                    
                    // Profile Name
                    Text(user.fullname)
                        .font(.custom("Cochin", size: 24))
                        .fontWeight(.bold)
                        .padding(.trailing)
                    
                    Spacer()
                }
                .padding(.top)
                
                // Edit Profile Button
                Button(action: {
                    print("Edit Profile tapped")
                    // Add functionality to edit the profile
                }) {
                    Text("Edit Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .font(.custom("Cochin", size: 18))
                        .cornerRadius(8)
                }
                
                // Log Out Button
                Button(action: {
                    viewModel.signOut()  // Corrected the reference to viewModel
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .font(.custom("Cochin", size: 18))
                        .cornerRadius(8)
                }
                
                Spacer() // Push content to the top
            }
            .padding()
            .background(Color.white) // White background
            .navigationBarTitle("Profile", displayMode: .inline)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel()) // Provide a mock AuthViewModel for preview
    }
}

