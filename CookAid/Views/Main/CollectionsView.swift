import SwiftUI
import Foundation

struct CollectionsView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingAddCollectionSheet = false
    @State private var showingImportRecipeSheet = false
    @State private var showingCreateRecipeSheet = false
    @State private var showingConfirmDeletion = false
    @State private var collectionToDelete: RecipeCollection?
    
    var body: some View {
        NavigationStack {
            VStack {
                if collectionsManager.collections.isEmpty {
                    EmptyCollectionsView(
                        showingAddCollectionSheet: $showingAddCollectionSheet,
                        showingImportRecipeSheet: $showingImportRecipeSheet,
                        showingCreateRecipeSheet: $showingCreateRecipeSheet
                    )
                } else {
                    CollectionListView(
                        collections: collectionsManager.collections,
                        onDelete: { collection in
                            collectionToDelete = collection
                            showingConfirmDeletion = true
                        }
                    )
                    
                    // Recipe Creation Options
                    RecipeCreationOptionsView(
                        showingImportRecipeSheet: $showingImportRecipeSheet,
                        showingCreateRecipeSheet: $showingCreateRecipeSheet
                    )
                }
            }
            .navigationTitle("My Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCollectionSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCollectionSheet) {
                AddCollectionView(collectionsManager: collectionsManager)
            }
            .sheet(isPresented: $showingImportRecipeSheet) {
                ImportRecipeView()
                    .environmentObject(collectionsManager)
            }
            .sheet(isPresented: $showingCreateRecipeSheet) {
                CreateRecipeView(collectionsManager: collectionsManager)
            }
            .confirmationDialog(
                "Are you sure you want to delete this collection?",
                isPresented: $showingConfirmDeletion,
                titleVisibility: .visible
            ) {
                Button("Delete Collection", role: .destructive) {
                    if let collection = collectionToDelete {
                        collectionsManager.deleteCollection(collectionId: collection.id)
                        collectionToDelete = nil
                    }
                }
            }
        }
    }
}

struct EmptyCollectionsView: View {
    @Binding var showingAddCollectionSheet: Bool
    @Binding var showingImportRecipeSheet: Bool
    @Binding var showingCreateRecipeSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.custom("Cochin", size: 24))
                .foregroundColor(.gray)
            
            Text("Create a collection to organize your recipes")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddCollectionSheet = true }) {
                Text("Create First Collection")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Divider()
                .padding(.vertical)
            
            Text("Or add recipes directly")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                Button(action: { showingImportRecipeSheet = true }) {
                    VStack {
                        Image(systemName: "link")
                            .font(.system(size: 24))
                        Text("Import from Web")
                            .font(.custom("Cochin", size: 16))
                    }
                    .frame(width: 140, height: 100)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                
                Button(action: { showingCreateRecipeSheet = true }) {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24))
                        Text("Create Recipe")
                            .font(.custom("Cochin", size: 16))
                    }
                    .frame(width: 140, height: 100)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

struct RecipeCreationOptionsView: View {
    @Binding var showingImportRecipeSheet: Bool
    @Binding var showingCreateRecipeSheet: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Add New Recipes")
                .font(.custom("Cochin", size: 20))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                Button(action: { showingImportRecipeSheet = true }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Import from Web")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                
                Button(action: { showingCreateRecipeSheet = true }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Create Recipe")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding()
    }
}

// Add Collection View remains unchanged
struct AddCollectionView: View {
    @ObservedObject var collectionsManager: CollectionsManager
    @State private var collectionName = ""
    @State private var collectionDescription = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Collection Details")) {
                    TextField("Collection Name", text: $collectionName)
                    
                    TextField("Description (Optional)", text: $collectionDescription)
                }
            }
            .navigationTitle("New Collection")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !collectionName.isEmpty {
                        collectionsManager.createCollection(
                            name: collectionName,
                            description: collectionDescription.isEmpty ? nil : collectionDescription
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(collectionName.isEmpty)
            )
        }
    }
}



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
                // Use the public method to save changes
                collectionsManager.updateCollection(collectionId: collectionId)
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

// Create Recipe View (new)
struct CreateRecipeView: View {
    @ObservedObject var collectionsManager: CollectionsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var servings = 2
    @State private var cookTime = 30
    @State private var ingredients: [EditableRecipeIngredient] = []
    @State private var instructions: [String] = [""]
    @State private var showingCollectionSelection = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Title", text: $title)
                    
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                    
                    Stepper("Cook Time: \(cookTime) min", value: $cookTime, in: 5...180, step: 5)
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Amount", value: $ingredients[index].amount, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            
                            TextField("Unit", text: $ingredients[index].unit)
                                .frame(width: 80)
                            
                            TextField("Ingredient", text: $ingredients[index].name)
                        }
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Ingredient") {
                        ingredients.append(EditableRecipeIngredient.empty())
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.gray)
                            
                            TextField("Step", text: $instructions[index])
                        }
                    }
                    .onDelete { indexSet in
                        instructions.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Step") {
                        instructions.append("")
                    }
                }
                
                Section {
                    Button("Save Recipe") {
                        if isValidRecipe() {
                            showingCollectionSelection = true
                        }
                    }
                    .disabled(!isValidRecipe())
                }
            }
            .navigationTitle("Create Recipe")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingCollectionSelection) {
                SelectCollectionView(
                    collectionsManager: collectionsManager,
                    onSave: { collectionId in
                        saveRecipe(to: collectionId)
                    }
                )
            }
        }
    }
    
    private func isValidRecipe() -> Bool {
        return !title.isEmpty && !ingredients.isEmpty && !instructions.isEmpty && !instructions[0].isEmpty
    }
    
    private func saveRecipe(to collectionId: UUID) {
        // Create a new CollectionRecipe
        let recipe = CollectionRecipe(
            id: UUID(),
            title: title,
            image: nil,
            ingredients: ingredients.map { $0.toRecipeIngredient() },
            instructions: instructions.filter { !$0.isEmpty },
            source: .custom,
            originalRecipeId: nil,
            collectionId: collectionId,
            tags: [],
            vegetarian: false,
            vegan: false,
            glutenFree: false,
            dairyFree: false
        )
        
        // Find the collection and add the recipe
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }) {
            collectionsManager.collections[index].recipes.append(recipe)
            // Use the public method to save collections
            collectionsManager.updateCollection(collectionId: collectionId)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// Select Collection View for saving custom recipes
struct SelectCollectionView: View {
    @ObservedObject var collectionsManager: CollectionsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCollectionId: UUID?
    @State private var showingCreateCollection = false
    @State private var newCollectionName = ""
    
    var onSave: (UUID) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                if collectionsManager.collections.isEmpty {
                    VStack(spacing: 20) {
                        Text("No Collections Available")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Create a collection to save your recipe")
                            .foregroundColor(.gray)
                        
                        Button("Create Collection") {
                            showingCreateCollection = true
                        }
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    List(collectionsManager.collections) { collection in
                        Button(action: {
                            selectedCollectionId = collection.id
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(collection.name)
                                        .font(.headline)
                                    
                                    Text("\(collection.recipes.count) recipes")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if selectedCollectionId == collection.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Collection")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if let id = selectedCollectionId {
                        onSave(id)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(selectedCollectionId == nil)
            )
            .alert("Create New Collection", isPresented: $showingCreateCollection) {
                TextField("Collection Name", text: $newCollectionName)
                Button("Cancel", role: .cancel) {}
                Button("Create") {
                    if !newCollectionName.isEmpty {
                        collectionsManager.createCollection(name: newCollectionName)
                        if let newCollection = collectionsManager.collections.last {
                            selectedCollectionId = newCollection.id
                        }
                        newCollectionName = ""
                    }
                }
            }
        }
    }
}

// Preview Provider
struct CollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsView()
            .environmentObject(CollectionsManager())
    }
}
