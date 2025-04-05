import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class IngredientsManager: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    @Published var isInitialized = false // Track initialization state
    private var recipeAPIManager: RecipeAPIManager?
    private var listenerRegistration: ListenerRegistration?
    
    init(recipeAPIManager: RecipeAPIManager) {
        self.recipeAPIManager = recipeAPIManager
        // Add a slight delay to ensure auth is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupIngredientsListener()
        }
    }

    init() {
        // Add a slight delay to ensure auth is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupIngredientsListener()
        }
    }
    
    deinit {
        // Remove listener when object is deallocated
        listenerRegistration?.remove()
    }
    
    // Setup real-time listener for ingredients
    private func setupIngredientsListener() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            // Mark as initialized even if no user found
            DispatchQueue.main.async {
                self.isInitialized = true
                print("Ingredients manager marked as initialized (no user)")
            }
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
                // Empty data is still valid data
                DispatchQueue.main.async {
                    self.ingredients = []
                    // Ensure we mark as initialized
                    self.isInitialized = true
                    print("Ingredients manager initialized with empty list")
                }
                return
            }
            
            // Update ingredients with the latest data
            let newIngredients = documents.compactMap { document in
                try? document.data(as: Ingredient.self)
            }
            
            DispatchQueue.main.async {
                self.ingredients = newIngredients
                // Mark as initialized when we get first data
                self.isInitialized = true
                print("Ingredients manager initialized with \(newIngredients.count) ingredients")
                // Explicitly notify listeners
                self.objectWillChange.send()
            }
        }
    }

    @MainActor
    func fetchIngredients() async {
        // Only proceed if we don't have a listener already
        if listenerRegistration == nil {
            setupIngredientsListener()
        } else if !isInitialized {
            // If we have a listener but it's not initialized, force refresh
            forceRefresh()
        }
    }
    
    // Add a method to force refresh when needed
    func forceRefresh() {
        print("Force refreshing ingredients manager")
        if let listenerRegistration = listenerRegistration {
            // Remove existing listener
            listenerRegistration.remove()
            self.listenerRegistration = nil
        }
        // Set up a new listener
        setupIngredientsListener()
    }

    func addIngredient(_ ingredient: Ingredient) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        // Check for duplicates before adding
        if isDuplicate(name: ingredient.name) {
            print("Duplicate ingredient detected: \(ingredient.name). Not adding to pantry.")
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
                // Force an explicit update if the listener is slow
                if !self.ingredients.contains(where: { $0.id == ingredient.id }) {
                    self.ingredients.append(ingredient)
                    self.objectWillChange.send()
                    print("Manually added ingredient to local array: \(ingredient.name)")
                }
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
    
    // Improved duplicate check function
    func isDuplicate(name: String) -> Bool {
        // Normalize the name for comparison (trim whitespace and convert to lowercase)
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check if any existing ingredient matches the normalized name
        return ingredients.contains {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedName
        }
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
