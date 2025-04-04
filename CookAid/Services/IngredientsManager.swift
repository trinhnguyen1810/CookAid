import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class IngredientsManager: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    private var recipeAPIManager: RecipeAPIManager?
    private var listenerRegistration: ListenerRegistration?
    
    init(recipeAPIManager: RecipeAPIManager) {
        self.recipeAPIManager = recipeAPIManager
        setupIngredientsListener()
    }

    init() {
        setupIngredientsListener()
    }
    
    deinit {
        // Remove listener when object is deallocated
        listenerRegistration?.remove()
    }
    
    // Setup real-time listener for ingredients
    private func setupIngredientsListener() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        // Create a reference to the ingredients collection
        let ingredientsRef = db.collection("users")
            .document(currentUser.uid)
            .collection("ingredients")
        
        // Set up a listener that automatically updates when changes occur
        listenerRegistration = ingredientsRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching ingredients: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No ingredients found")
                return
            }
            
            // Update ingredients with the latest data
            self.ingredients = documents.compactMap { document in
                try? document.data(as: Ingredient.self)
            }
        }
    }

    @MainActor
    func fetchIngredients() async {
        // Only proceed if we don't have a listener already
        if listenerRegistration == nil {
            setupIngredientsListener()
        }
    }

    func addIngredient(_ ingredient: Ingredient) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        do {
            try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .document(ingredient.id)
                .setData(from: ingredient)
            
            await MainActor.run {
                // No need to manually update the array - the listener will handle it
            }
            
            if let recipeAPIManager = recipeAPIManager {
                await recipeAPIManager.fetchRecipes(ingredients: ingredients.map { $0.name })
            }
        } catch {
            print("Error adding ingredient: \(error.localizedDescription)")
        }
    }
    
    func deleteIngredient(_ ingredient: Ingredient) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        do {
            try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .document(ingredient.id)
                .delete()
            
            print("Ingredient deleted successfully!")
            // The listener will update the UI automatically
        } catch {
            print("Error deleting ingredient: \(error.localizedDescription)")
        }
    }
    
    // Check if ingredient already exists
    func isDuplicate(name: String) -> Bool {
        return ingredients.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    // Clear all ingredients
    func clearAllIngredients() async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        do {
            let snapshot = try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .getDocuments()
            
            // If there are no ingredients, just return
            if snapshot.documents.isEmpty {
                print("No ingredients to clear")
                return
            }
            
            // Add each ingredient to batch delete
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch
            try await batch.commit()
            print("All ingredients cleared successfully!")
            // The listener will update the UI automatically
            
        } catch {
            print("Error clearing all ingredients: \(error.localizedDescription)")
        }
    }
    
    // Clear ingredients by category
    func clearIngredientsByCategory(category: String) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        do {
            let snapshot = try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .whereField("category", isEqualTo: category)
                .getDocuments()
            
            // If there are no ingredients in this category, just return
            if snapshot.documents.isEmpty {
                print("No ingredients found in category: \(category)")
                return
            }
            
            // Add each ingredient in this category to batch delete
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch
            try await batch.commit()
            print("All ingredients in category '\(category)' cleared successfully!")
            // The listener will update the UI automatically
            
        } catch {
            print("Error clearing ingredients by category: \(error.localizedDescription)")
        }
    }
    
    // Update an ingredient's category
    func updateIngredientCategory(ingredient: Ingredient, newCategory: String) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let updatedIngredient = Ingredient(
            id: ingredient.id,
            name: ingredient.name,
            dateBought: ingredient.dateBought,
            category: newCategory
        )
        
        let db = Firestore.firestore()
        do {
            try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .document(ingredient.id)
                .setData(from: updatedIngredient)
            
            print("Ingredient category updated successfully!")
            // The listener will update the UI automatically
        } catch {
            print("Error updating ingredient category: \(error.localizedDescription)")
        }
    }
}
