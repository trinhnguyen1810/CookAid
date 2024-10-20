import Foundation
import FirebaseAuth

class FirebaseManager: ObservableObject {
    @Published var isUserLoggedIn: Bool = false

    init() {
        if Auth.auth().currentUser != nil {
            isUserLoggedIn = true
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if error == nil {
                self?.isUserLoggedIn = true
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        isUserLoggedIn = false
    }
}

