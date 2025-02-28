import SwiftUI

struct EditRecipeView: View {
    @ObservedObject var collectionsManager: CollectionsManager
    @State private var recipe: CollectionRecipe
    @State private var editableIngredients: [EditableRecipeIngredient] = []
    var collectionId: UUID
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    
    init(collectionsManager: CollectionsManager, recipe: CollectionRecipe, collectionId: UUID) {
        self.collectionsManager = collectionsManager
        self._recipe = State(initialValue: recipe)
        self.collectionId = collectionId
        self._editableIngredients = State(initialValue: recipe.ingredients.map { EditableRecipeIngredient(from: $0) })
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Title", text: $recipe.title)
                    
                    // Tags field
                    VStack(alignment: .leading) {
                        Text("Tags (comma separated)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        let tagsBinding = Binding<String>(
                            get: { recipe.tags.joined(separator: ", ") },
                            set: { newValue in
                                let components = newValue.components(separatedBy: ",")
                                recipe.tags = components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                            }
                        )
                        
                        TextField("Tags", text: tagsBinding)
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(editableIngredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Amount", value: $editableIngredients[index].amount, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            
                            TextField("Unit", text: $editableIngredients[index].unit)
                                .frame(width: 80)
                            
                            TextField("Ingredient", text: $editableIngredients[index].name)
                        }
                    }
                    .onDelete { indexSet in
                        editableIngredients.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Ingredient") {
                        editableIngredients.append(EditableRecipeIngredient.empty())
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(recipe.instructions.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.gray)
                            
                            TextField("Step", text: $recipe.instructions[index])
                        }
                    }
                    .onDelete { indexSet in
                        recipe.instructions.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Step") {
                        recipe.instructions.append("")
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveRecipe()
                    }
                    
                    Button("Delete Recipe", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert("Delete Recipe", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text("Are you sure you want to delete this recipe from the collection? This cannot be undone.")
            }
        }
    }
    
    private func saveRecipe() {
        // Update the recipe with edited ingredients
        var updatedRecipe = recipe
        updatedRecipe.ingredients = editableIngredients.map { $0.toRecipeIngredient() }
        
        // Find the collection
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }) {
            // Find the recipe in the collection
            if let recipeIndex = collectionsManager.collections[index].recipes.firstIndex(where: { $0.id == recipe.id }) {
                // Update the recipe
                collectionsManager.collections[index].recipes[recipeIndex] = updatedRecipe
                // Save changes
                collectionsManager.saveCollections()
                // Dismiss the view
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func deleteRecipe() {
        collectionsManager.removeRecipeFromCollection(recipeId: recipe.id, collectionId: collectionId)
        presentationMode.wrappedValue.dismiss()
    }
}
