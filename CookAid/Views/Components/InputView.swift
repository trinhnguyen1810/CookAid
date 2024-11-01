import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField: Bool = false  // This should be `var` to make it configurable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            // Use Group to wrap the conditional view
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
        }
    }
}
 
struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), title: "Email Address", placeholder: "johndoe@example.com")
    }
}

