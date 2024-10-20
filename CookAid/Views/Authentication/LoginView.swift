import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Image("logo") // Ensure you have an image named "logo" in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Welcome Back!")
                    .font(.custom("Cochin", size: 34))
                    .fontWeight(.bold)
                    .padding()

                TextField("Email", text: $email) // Email input
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                SecureField("Password", text: $password) // Password input
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                Button(action: {
                    // Simulate a login action
                    if email.isEmpty || password.isEmpty {
                        errorMessage = "Please enter your email and password."
                        showingAlert = true
                    } else {
                        // Normally, you would perform login logic here
                        print("Login tapped with Email: \(email) and Password: \(password)")
                    }
                }) {
                    Text("Login")
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

                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

