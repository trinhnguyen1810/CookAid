import SwiftUI
import Foundation

struct ImportToCollectionView: View {
    let recipe: ImportedRecipeDetail
    @ObservedObject var collectionsManager: CollectionsManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                if collectionsManager.collections.isEmpty {
                    EmptyCollectionsImportView(
                        recipe: recipe,
                        collectionsManager: collectionsManager,
                        presentationMode: presentationMode
                    )
                } else {
                    ImportCollectionListView(
                        recipe: recipe,
                        collections: collectionsManager.collections,
                        collectionsManager: collectionsManager,
                        presentationMode: presentationMode
                    )
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Empty Collections Import View
struct EmptyCollectionsImportView: View {
    let recipe: ImportedRecipeDetail
    @ObservedObject var collectionsManager: CollectionsManager
    var presentationMode: Binding<PresentationMode>
    @State private var newCollectionName = ""
    
    var body: some View {
        VStack {
            Image(systemName: "square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.custom("Cochin", size: 20))
                .foregroundColor(.gray)
            
            TextField("New Collection Name", text: $newCollectionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: createCollectionAndAddRecipe) {
                Text("Create Collection and Add Recipe")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(newCollectionName.isEmpty)
        }
    }
    
    private func createCollectionAndAddRecipe() {
        let newCollection = RecipeCollection(name: newCollectionName)
        collectionsManager.collections.append(newCollection)
        
        let collectionRecipe = CollectionRecipe(
            title: recipe.title,
            image: recipe.image,
            ingredients: recipe.extendedIngredients.map {
                RecipeIngredient(
                    id: $0.id,
                    name: $0.name,
                    amount: $0.amount,
                    unit: $0.unit,
                    measures: Measures(
                        us: UnitMeasure(amount: $0.amount, unitShort: $0.unit, unitLong: $0.unit),
                        metric: UnitMeasure(amount: $0.amount, unitShort: $0.unit, unitLong: $0.unit)
                    )
                )
            },
            instructions: recipe.instructionSteps,
            source: .imported,
            originalRecipeId: recipe.id,
            collectionId: newCollection.id
        )
        
        // Add recipe to the new collection
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == newCollection.id }) {
            collectionsManager.collections[index].recipes.append(collectionRecipe)
        }
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}

// Import Collection List View
struct ImportCollectionListView: View {
    let recipe: ImportedRecipeDetail
    let collections: [RecipeCollection]
    @ObservedObject var collectionsManager: CollectionsManager
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            ForEach(collections) { collection in
                Button(action: {
                    let collectionRecipe = CollectionRecipe(
                        title: recipe.title,
                        image: recipe.image,
                        ingredients: recipe.extendedIngredients.map {
                            RecipeIngredient(
                                id: $0.id,
                                name: $0.name,
                                amount: $0.amount,
                                unit: $0.unit,
                                measures: Measures(
                                    us: UnitMeasure(amount: $0.amount, unitShort: $0.unit, unitLong: $0.unit),
                                    metric: UnitMeasure(amount: $0.amount, unitShort: $0.unit, unitLong: $0.unit)
                                )
                            )
                        },
                        instructions: recipe.instructionSteps,
                        source: .imported,
                        originalRecipeId: recipe.id,
                        collectionId: collection.id
                    )
                    
                    // Add recipe to the selected collection
                    if let index = collectionsManager.collections.firstIndex(where: { $0.id == collection.id }) {
                        collectionsManager.collections[index].recipes.append(collectionRecipe)
                    }
                    
                    // Dismiss the view
                    presentationMode.wrappedValue.dismiss()
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
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}
