import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // Logo image
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                // Welcome text
                Text("Welcome Back!")
                    .font(.custom("Cochin", size: 34))
                    .fontWeight(.bold)
                    .padding()
                
                // Input fields for email and password
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email", placeholder: "johndoe@example.com")
                        .autocapitalization(.none)
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Sign in button
                Button(action: {
                    signIn()
                }) {
                    Text("Sign in")
                        .font(.custom("Cochin", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                // Navigation to Sign Up view
                NavigationLink(destination: SignUpView().navigationBarBackButtonHidden()) {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.custom("Cochin", size: 16))
                    .foregroundColor(.black)
                    .padding()
                }
            }
            .padding()
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
    }
    private func signIn() {
        // Validate input fields
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            showingAlert = true
            print("Validation failed: email or password is empty.")
            return
        }
        
        print("Attempting to sign in with email: \(email)")
        
        // Attempt to sign in
        Task {
            do {
                try await viewModel.signIn(withEmail: email, password: password)
                print("Sign in successful!")
            } catch {
                errorMessage = "Failed to sign in: \(error.localizedDescription)"
                showingAlert = true
                print("Sign in failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView().environmentObject(AuthViewModel()) // Provide a mock AuthViewModel for preview
        }
    }
}
