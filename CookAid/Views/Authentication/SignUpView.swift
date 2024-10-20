import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Sign Up")
                    .font(.custom("Cochin", size: 34))
                    .fontWeight(.bold)
                    .padding()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    // Handle sign up action
                }) {
                    Text("Sign Up")
                        .font(.custom("Cochin", size: 20))
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigation link to login
                NavigationLink(destination: LoginView()) {
                    Text("Already have an account? Login")
                        .font(.custom("Cochin", size: 16))
                        .foregroundColor(.black)
                        .padding()
                }
            }
            .padding()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

