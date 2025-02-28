import SwiftUI

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
        return !title.isEmpty &&
               (!ingredients.isEmpty && ingredients.allSatisfy { !$0.name.isEmpty }) &&
               (!instructions.isEmpty && instructions.allSatisfy { !$0.isEmpty })
    }
    
    private func saveRecipe(to collectionId: UUID) {
        // Create a new CollectionRecipe
        let recipe = RecipeCollections.Recipe(
            id: UUID(),
            title: title,
            image: nil,
            ingredients: ingredients.map { $0.toRecipeIngredient() },
            instructions: instructions.filter { !$0.isEmpty },
            source: .custom,
            originalRecipeId: nil,
            collectionId: collectionId
        )
        
        // Find the collection and add the recipe
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }) {
            collectionsManager.collections[index].recipes.append(recipe)
            // Save collections
            collectionsManager.saveCollections()
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

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
