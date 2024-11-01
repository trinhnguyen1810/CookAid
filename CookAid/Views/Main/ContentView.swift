import SwiftUI
import Firebase

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            if viewModel.userSession != nil {
                NavigationView {
                    VStack {
                        // Switch between different views based on the selected tab
                        switch selectedTab {
                        case .home:
                            HomeView()
                        case .pantry:
                            PantryView()
                        case .recommender:
                            RecommenderView()
                        case .recipes:
                            Text("Recipes View")
                        case .profile:
                            ProfileView()
                        }
                    }
                    .navigationBarHidden(true)
                    .onAppear {
                        checkUserExists() // Check user existence when this view appears
                    }
                }
            } else {
                LoginView()
            }
        }
    }

    // Function to check if the user exists in Firestore
    private func checkUserExists() {
        guard let userId = viewModel.userSession?.uid else {
            // No user is logged in, just return
            return
        }

        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error)")
                signOut() // If there's an error, assume the user is not valid
            } else if let document = document, !document.exists {
                // User does not exist, handle logout
                signOut()
            }
            // If the user exists, do nothing
        }
    }

    // Function to sign out the user
    private func signOut() {
        do {
            try Auth.auth().signOut() // Sign out from Firebase Auth
            viewModel.userSession = nil // Update the session in the view model
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

// Define the tab enumeration
enum Tab {
    case home, pantry, recommender, recipes, profile
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthViewModel()) // Provide a mock AuthViewModel for preview
    }
}

