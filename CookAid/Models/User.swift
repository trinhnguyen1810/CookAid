import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let profilePicture: String? // New property for profile picture URL
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "John Doe", email: "johndoe@example.com", profilePicture: nil)
}
