import Foundation
import SwiftUI
import Combine

class CollectionsManager: ObservableObject {
    @Published var collections: [RecipeCollections.Collection] = []
    @Published var updateTrigger = UUID() 
    
    private let collectionsKey = "userRecipeCollections"
    private let recipeAPIManager: RecipeAPIManager
    
    init(recipeAPIManager: RecipeAPIManager) {
        self.recipeAPIManager = recipeAPIManager
        loadCollections()
    }
    
    // Convenience initializer without parameters
    init() {
        // Create a default RecipeAPIManager instance
        self.recipeAPIManager = RecipeAPIManager()
        loadCollections()
    }
    
    // Save collections to UserDefaults
    func saveCollections() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(collections)
            UserDefaults.standard.set(data, forKey: collectionsKey)
            
            // Trigger UI updates
            DispatchQueue.main.async {
                self.updateTrigger = UUID()
                self.objectWillChange.send()
            }
        } catch {
            print("Error saving collections: \(error)")
        }
    }
    
    // Load collections from UserDefaults
    private func loadCollections() {
        guard let data = UserDefaults.standard.data(forKey: collectionsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            collections = try decoder.decode([RecipeCollections.Collection].self, from: data)
        } catch {
            print("Error loading collections: \(error)")
        }
    }
    
    // Get a specific collection by ID
    func getCollection(by id: UUID) -> RecipeCollections.Collection? {
        return collections.first { $0.id == id }
    }
    
    // Create a new collection
    func createCollection(name: String, description: String? = nil) {
        let newCollection = RecipeCollections.Collection(name: name, description: description)
        collections.append(newCollection)
        saveCollections()
    }
    
    // Add recipe to a specific collection (from RecipeDetail)
    func addRecipeToCollection(recipeDetail: RecipeDetail, collectionId: UUID) {
        let collectionRecipe = RecipeCollections.Recipe(from: recipeDetail, collectionId: collectionId)
        
        if let index = collections.firstIndex(where: { $0.id == collectionId }) {
            // Check if recipe already exists in the collection
            if !collections[index].recipes.contains(where: { $0.originalRecipeId == recipeDetail.id }) {
                collections[index].recipes.append(collectionRecipe)
                saveCollections()
            }
        }
    }
    
    // Add recipe to a specific collection
    func addRecipeToCollection(quickRecipe: QuickRecipe, collectionId: UUID) {
        if let index = collections.firstIndex(where: { $0.id == collectionId }) {
            // Create a temporary partial recipe with basic info
            let partialRecipe = RecipeCollections.Recipe(
                from: quickRecipe,
                collectionId: collectionId
            )
            
            // Add partial recipe to collection immediately for UI responsiveness
            collections[index].recipes.append(partialRecipe)
            
            // Then fetch the full details in the background
            Task {
                if let recipeDetail = await recipeAPIManager.fetchRecipeDetail(id: quickRecipe.id) {
                    // Create a full recipe with all details
                    let fullRecipe = RecipeCollections.Recipe(
                        from: recipeDetail,
                        collectionId: collectionId
                    )
                    
                    // Update the collection with the complete recipe
                    await MainActor.run {
                        // Find the index of the partial recipe
                        if let recipeIndex = self.collections[index].recipes.firstIndex(where: { $0.originalRecipeId == quickRecipe.id }) {
                            // Replace it with the full recipe
                            self.collections[index].recipes[recipeIndex] = fullRecipe
                            self.saveCollections()
                        }
                    }
                }
            }
            
            // Save and notify even before details are fetched to show immediate UI feedback
            saveCollections()
        }
    }
    
    // Add recipe to a specific collection for import
    func addRecipeToCollection(importedRecipe: ImportedRecipeDetail, collectionId: UUID) {
        // Create the recipe from imported recipe
        let collectionRecipe = RecipeCollections.Recipe(
            title: importedRecipe.title,
            image: importedRecipe.image,
            ingredients: importedRecipe.extendedIngredients.map {
                RecipeIngredient(
                    id: $0.id,
                    name: $0.name,
                    amount: $0.amount,
                    unit: $0.unit,
                    measures: Measures(
                        metric: MeasureUnit(amount: $0.amount, unitShort: $0.unit, unitLong: $0.unit),
                        us: MeasureUnit(amount: $0.amount, unitShort: $0.unit, unitLong: $0.unit)
                    )
                )
            },
            instructions: importedRecipe.instructionSteps,
            source: .imported,
            originalRecipeId: importedRecipe.id,
            collectionId: collectionId
        )
        
        if let index = collections.firstIndex(where: { $0.id == collectionId }) {
            // Add the recipe to collection
            collections[index].recipes.append(collectionRecipe)
            
            // Save changes to persistence
            saveCollections()
            
            print("Recipe added to collection ID: \(collectionId)")
        } else {
            print("Collection not found with ID: \(collectionId)")
        }
    }
    
    // Update a recipe
    func updateRecipe(recipeId: UUID, collectionId: UUID, updatedRecipe: RecipeCollections.Recipe) {
        if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }),
           let recipeIndex = collections[collectionIndex].recipes.firstIndex(where: { $0.id == recipeId }) {
            
            collections[collectionIndex].recipes[recipeIndex] = updatedRecipe
            saveCollections()
        }
    }
    
    func removeRecipeFromCollection(recipeId: UUID, collectionId: UUID) {
        if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) {
            // Find and remove the recipe
            collections[collectionIndex].recipes.removeAll { $0.id == recipeId }
            saveCollections()
        }
    }
    
    // Delete an entire collection
    func deleteCollection(collectionId: UUID) {
        collections.removeAll { $0.id == collectionId }
        saveCollections()
    }
    
    // Update a collection
    func updateCollection(collectionId: UUID, name: String? = nil, description: String? = nil) {
        if let index = collections.firstIndex(where: { $0.id == collectionId }) {
            if let newName = name {
                collections[index].name = newName
            }
            if let newDescription = description {
                collections[index].description = newDescription
            }
            saveCollections()
        }
    }
    
    // Force a UI refresh
    func refreshUI() {
        DispatchQueue.main.async {
            self.updateTrigger = UUID()
            self.objectWillChange.send()
        }
    }
    
    // Check if a recipe is already in a collection
    func isRecipeInCollection(recipeId: Int) -> Bool {
        return collections.contains { collection in
            collection.recipes.contains { $0.originalRecipeId == recipeId }
        }
    }
    
    // Get collections containing a specific recipe
    func collectionsContainingRecipe(recipeId: Int) -> [RecipeCollections.Collection] {
        return collections.filter { collection in
            collection.recipes.contains { $0.originalRecipeId == recipeId }
        }
    }
}
