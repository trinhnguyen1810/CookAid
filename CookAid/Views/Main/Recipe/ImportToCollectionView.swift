import SwiftUI
import Foundation

struct ImportToCollectionView: View {
    let recipe: ImportedRecipeDetail
    @EnvironmentObject var collectionsManager: CollectionsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showDebugInfo = false
    @State private var debugInfo = ""
    
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
                
                if showDebugInfo {
                    Text(debugInfo)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarItems(
                leading: Button("Debug") {
                    showDebugInfo.toggle()
                    debugInfo = "Collections: \(collectionsManager.collections.count), Recipe: \(recipe.title)"
                }.opacity(0.2),
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Empty Collections Import View
struct EmptyCollectionsImportView: View {
    let recipe: ImportedRecipeDetail
    @ObservedObject var collectionsManager: CollectionsManager
    var presentationMode: Binding<PresentationMode>
    @State private var newCollectionName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("success") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private func createCollectionAndAddRecipe() {
        // Create a new collection with the specified name
        let newCollection = RecipeCollection(name: newCollectionName)
        collectionsManager.collections.append(newCollection)
        
        // Explicitly save collections
        collectionsManager.saveCollections()
        
        // Add the recipe to the new collection
        collectionsManager.addRecipeToCollection(importedRecipe: recipe, collectionId: newCollection.id)
        
        // Explicitly trigger UI update
        collectionsManager.objectWillChange.send()
        
        // Show success message
        alertMessage = "Recipe added successfully to new collection!"
        showAlert = true
        
        // Dismiss will happen after alert is acknowledged
    }
}

// Import Collection List View
struct ImportCollectionListView: View {
    let recipe: ImportedRecipeDetail
    let collections: [RecipeCollection]
    @ObservedObject var collectionsManager: CollectionsManager
    var presentationMode: Binding<PresentationMode>
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedCollectionId: UUID?
    
    var body: some View {
        List {
            ForEach(collections) { collection in
                Button(action: {
                    addRecipeToCollection(collection.id)
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("success") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    private func addRecipeToCollection(_ collectionId: UUID) {
        // Store the selected collection ID
        selectedCollectionId = collectionId
        
        // Add the recipe to the selected collection
        collectionsManager.addRecipeToCollection(
            importedRecipe: recipe,
            collectionId: collectionId
        )
        
        // Explicitly trigger UI update
        collectionsManager.objectWillChange.send()
        
        // Add debug information to alert message
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }) {
            let recipeCount = collectionsManager.collections[index].recipes.count
            alertMessage = "Recipe added successfully! Collection now has \(recipeCount) recipes."
        } else {
            alertMessage = "Recipe added successfully!"
        }
        
        showAlert = true
        
        // Dismiss will happen after alert is acknowledged
    }
}
