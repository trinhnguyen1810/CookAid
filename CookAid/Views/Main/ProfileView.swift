import SwiftUI

struct ProfileView: View {
    var user: User = User(name: "John Doe", email: "john.doe@example.com", bio: "Food enthusiast and recipe creator.")

    var body: some View {
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
                Text(user.name)
                    .font(.custom("Cochin", size: 24))
                    .fontWeight(.bold)
                    .padding(.trailing)
                
                Spacer()
            }
            .padding(.top)

            // Edit Profile Button
            Button(action: {
                print("Edit Profile tapped")
            }) {
                Text("Edit Profile")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .font(.custom("Cochin", size: 18))
                    .cornerRadius(8)
            }
            
            // Log In Button
            Button(action: {
                print("Log In tapped")
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .font(.custom("Cochin", size: 18))
                    .cornerRadius(8)
            }

            // Log Out Button
            Button(action: {
                print("Log Out tapped")
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


struct User {
    var name: String
    var email: String
    var bio: String
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

