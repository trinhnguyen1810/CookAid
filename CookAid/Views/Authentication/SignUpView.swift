import SwiftUI

struct SignUpView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Create an Account")
                    .font(.custom("Cochin", size: 34))
                    .fontWeight(.bold)
                    .padding()

                VStack(spacing: 24) {
                    InputView(text: $fullName, title: "Full Name", placeholder: "John Doe")
                    InputView(text: $email, title: "Email", placeholder: "johndoe@example.com")
                        .autocapitalization(.none)
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                    InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Re-enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)

                Button(action: {
                    // Validate input fields
                    if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                        errorMessage = "Please fill in all fields."
                        showingAlert = true
                    } else if password != confirmPassword {
                        errorMessage = "Passwords do not match."
                        showingAlert = true
                    } else {
                        // Attempt to create user
                        Task {
                            do {
                                try await viewModel.createUser(withEmail: email, password: password, fullname: fullName)
                                print("User created successfully with Full Name: \(fullName), Email: \(email)")
                            } catch {
                                errorMessage = "Failed to create user: \(error.localizedDescription)"
                                showingAlert = true
                                print("DEBUG: User creation failed with error: \(error.localizedDescription)")
                                if let error = error as NSError? {
                                    print("DEBUG: Full error details: \(error), code: \(error.code), domain: \(error.domain)")
                                }

                            }
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.custom("Cochin", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Sign Up Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }

                NavigationLink(destination: LoginView().navigationBarBackButtonHidden()) {
                    HStack(spacing: 3) {
                        Text("Already have an account?")
                        Text("Log in")
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
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView().environmentObject(AuthViewModel()) // Provide a mock AuthViewModel for preview
    }
}

