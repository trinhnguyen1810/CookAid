import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class IngredientsManager: ObservableObject {
    @Published var ingredients: [Ingredient] = []

    init() {
        fetchIngredients()
    }

    func fetchIngredients() {
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("ingredients").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching ingredients: \(error.localizedDescription)")
                return
            }
            self.ingredients = snapshot?.documents.compactMap { document in
                try? document.data(as: Ingredient.self)
            } ?? []
        }
    }

    func addIngredient(_ ingredient: Ingredient) {
        let db = Firestore.firestore()
        do {
            let _ = try db.collection("users").document(Auth.auth().currentUser!.uid).collection("ingredients").document(ingredient.id).setData(from: ingredient)
            ingredients.append(ingredient) // Update local state
        } catch {
            print("Error adding ingredient: \(error.localizedDescription)")
        }
    }
}
