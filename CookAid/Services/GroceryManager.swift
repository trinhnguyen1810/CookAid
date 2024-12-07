import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class GroceryManager: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []

    init() {
        fetchGroceryItems()
    }

    func fetchGroceryItems() {
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("groceryItems").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching grocery items: \(error.localizedDescription)")
                return
            }
            self.groceryItems = snapshot?.documents.compactMap { document in
                try? document.data(as: GroceryItem.self)
            } ?? []
        }
    }

    func addGroceryItem(_ groceryItem: GroceryItem) {
        let db = Firestore.firestore()
        do {
            let _ = try db.collection("users").document(Auth.auth().currentUser!.uid).collection("groceryItems").document(groceryItem.id).setData(from: groceryItem)
            groceryItems.append(groceryItem) // Update local state
        } catch {
            print("Error adding grocery item: \(error.localizedDescription)")
        }
    }

    func deleteGroceryItem(_ groceryItem: GroceryItem) {
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("groceryItems").document(groceryItem.id).delete() { error in
            if let error = error {
                print("Error deleting grocery item: \(error.localizedDescription)")
            } else {
                print("Grocery item deleted successfully!")
            }
        }
    }
}
