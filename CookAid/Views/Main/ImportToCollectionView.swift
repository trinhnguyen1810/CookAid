import SwiftUI
import Foundation

struct ImportToCollectionView: View {
    let recipe: ImportedRecipeDetail
    @EnvironmentObject var collectionsManager: CollectionsManager
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
        
        collectionsManager.addRecipeToCollection(importedRecipe: recipe, collectionId: newCollection.id)
        
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
                    collectionsManager.addRecipeToCollection(
                        importedRecipe: recipe,
                        collectionId: collection.id
                    )
                    
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
