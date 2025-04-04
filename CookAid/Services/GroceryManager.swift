import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class GroceryManager: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []
    private var listenerRegistration: ListenerRegistration?

    init() {
        // Setup real-time listener for grocery items
        setupGroceryListener()
    }
    
    deinit {
        // Remove listener when object is deallocated
        listenerRegistration?.remove()
    }

    // Set up a real-time listener for grocery items
    private func setupGroceryListener() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        // Create a reference to the groceryItems collection
        let groceryRef = db.collection("users")
            .document(currentUser.uid)
            .collection("groceryItems")
        
        // Set up a listener that automatically updates when changes occur
        listenerRegistration = groceryRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching grocery items: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            // Update groceryItems with the latest data
            self.groceryItems = documents.compactMap { document in
                try? document.data(as: GroceryItem.self)
            }
        }
    }

    // Fetch grocery items - now only used for initial load or forced refresh
    func fetchGroceryItems() {
        // Only proceed if we don't have a listener already
        if listenerRegistration == nil {
            setupGroceryListener()
        }
    }

    // Add a new grocery item
    func addGroceryItem(_ groceryItem: GroceryItem) {
        let db = Firestore.firestore()
        do {
            try db.collection("users")
                .document(Auth.auth().currentUser!.uid)
                .collection("groceryItems")
                .document(groceryItem.id)
                .setData(from: groceryItem)
            
            print("Grocery item added successfully!")
            // No need to manually add to array - the listener will handle it
        } catch {
            print("Error adding grocery item: \(error.localizedDescription)")
        }
    }

    // Delete a grocery item
    func deleteGroceryItem(_ groceryItem: GroceryItem) {
        let db = Firestore.firestore()
        db.collection("users")
            .document(Auth.auth().currentUser!.uid)
            .collection("groceryItems")
            .document(groceryItem.id)
            .delete() { error in
                if let error = error {
                    print("Error deleting grocery item: \(error.localizedDescription)")
                } else {
                    print("Grocery item deleted successfully!")
                    // No need to manually remove from array - the listener will handle it
                }
            }
    }
    
    // Update an existing grocery item
    func updateGroceryItem(_ groceryItem: GroceryItem) {
        // Just use the add method as it also handles updates
        addGroceryItem(groceryItem)
    }
    
    // Clear all items (for testing or resetting)
    func clearAllItems() {
        for item in groceryItems {
            deleteGroceryItem(item)
        }
    }
}
