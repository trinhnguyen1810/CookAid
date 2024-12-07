import Foundation
import Firebase
import FirebaseFirestoreSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        } 
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            print("Attempting to sign in with email: \(email)")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("Sign in successful! User ID: \(result.user.uid)")
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            print("Attempting to create user with email: \(email)")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Create a User object and encode it
            let user = User(id: result.user.uid, fullname: fullname, email: email, profilePicture: nil) // Set profilePicture to nil
            guard let encodedUser = try? Firestore.Encoder().encode(user) else {
                print("DEBUG: Failed to encode user")
                return
            }
            
            // Save the user data to Firestore
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            print("User created successfully and saved to Firestore with ID: \(user.id)")
        } catch {
            print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        // Implement account deletion
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
            print("DEBUG: Current user is \(String(describing: self.currentUser))") // Corrected print statement
        } catch {
            print("DEBUG: Failed to fetch user with error: \(error.localizedDescription)")
        }
    }
}

