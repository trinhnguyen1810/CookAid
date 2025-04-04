import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class GroceryManager: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []
    private var listenerRegistration: ListenerRegistration?

    init() {
        setupGroceryListener()
    }
    
    deinit {
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

    // Fetch grocery items now only used for initial load or forced refresh
    func fetchGroceryItems() {
        if listenerRegistration == nil {
            setupGroceryListener()
        }
    }

    // Add a new grocery item with duplicate checking
    func addGroceryItem(_ groceryItem: GroceryItem) {
        // Check for duplicates first
        if isDuplicate(name: groceryItem.name) {
            print("Item already exists in the grocery list")
            return
        }
        
        let db = Firestore.firestore()
        do {
            try db.collection("users")
                .document(Auth.auth().currentUser!.uid)
                .collection("groceryItems")
                .document(groceryItem.id)
                .setData(from: groceryItem)
            
            print("Grocery item added successfully!")
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
        let db = Firestore.firestore()
        do {
            try db.collection("users")
                .document(Auth.auth().currentUser!.uid)
                .collection("groceryItems")
                .document(groceryItem.id)
                .setData(from: groceryItem)
        } catch {
            print("Error updating grocery item: \(error.localizedDescription)")
        }
    }
    
    // Toggle completion status
    func toggleCompletion(for item: GroceryItem) {
        // Create a new item with the opposite completion status
        let updatedItem = GroceryItem(
            id: item.id,
            name: item.name,
            category: item.category,
            completed: !item.completed
        )
        
        // Update it in Firestore
        updateGroceryItem(updatedItem)
    }
    
    // Check if an item already exists in the grocery list
    func isDuplicate(name: String) -> Bool {
        // Extract just the base name if it contains " - " separator
        let nameBase = name.components(separatedBy: " - ").first ?? name
        
        return groceryItems.contains { item in
            let itemBase = item.name.components(separatedBy: " - ").first ?? item.name
            return itemBase.lowercased() == nameBase.lowercased()
        }
    }
    
    // Add an ingredient from a recipe with automatic categorization
    func addIngredientFromRecipe(ingredient: RecipeIngredient) {
        // Format the ingredient string
        let amount = formatNumber(ingredient.amount)
        let groceryItemName = "\(ingredient.name) - \(amount) \(ingredient.unit)"
        
        // Check for duplicates
        if isDuplicate(name: ingredient.name) {
            print("This ingredient already exists in your grocery list")
            return
        }
        
        // Create new grocery item with automatic categorization
        let groceryItem = GroceryItem(
            id: UUID().uuidString,
            name: groceryItemName,
            category: IngredientCategorizer.categorize(ingredient.name),
            completed: false
        )
        
        // Add to grocery list
        addGroceryItem(groceryItem)
    }
    
    // Helper method to format numbers
    private func formatNumber(_ number: Double) -> String {
        return number.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", number) : String(format: "%.1f", number)
    }
    
    func clearAllItems() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        let groceryRef = db.collection("users").document(currentUser.uid).collection("groceryItems")
        
        // First get all the documents
        groceryRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self, let documents = snapshot?.documents else {
                print("Error getting documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // If there are no documents, just return
            if documents.isEmpty {
                print("No items to clear")
                return
            }
            
            // Add each document to the batch delete operation
            for document in documents {
                batch.deleteDocument(groceryRef.document(document.documentID))
            }
            
            // Commit the batch
            batch.commit { error in
                if let error = error {
                    print("Error clearing all items: \(error.localizedDescription)")
                } else {
                    print("All grocery items cleared successfully!")
                    // The listener will automatically update the UI
                }
            }
        }
    }
    
    // Clear completed items only
    func clearCompletedItems() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        let groceryRef = db.collection("users").document(currentUser.uid).collection("groceryItems")
        
        // Query for completed items
        groceryRef.whereField("completed", isEqualTo: true).getDocuments { [weak self] (snapshot, error) in
            guard let self = self, let documents = snapshot?.documents else {
                print("Error getting completed items: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // If there are no completed items, just return
            if documents.isEmpty {
                print("No completed items to clear")
                return
            }
            
            // Add each completed item to the batch delete operation
            for document in documents {
                batch.deleteDocument(groceryRef.document(document.documentID))
            }
            
            // Commit the batch
            batch.commit { error in
                if let error = error {
                    print("Error clearing completed items: \(error.localizedDescription)")
                } else {
                    print("Completed grocery items cleared successfully!")
                    // The listener will automatically update the UI
                }
            }
        }
    }
}
