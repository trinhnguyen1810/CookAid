import SwiftUI
import Foundation

struct AddToCollectionView: View {
    // Using ObservedObject still, since this is passed from the parent view
    @ObservedObject var collectionsManager: CollectionsManager
    
    // Recipe to be added (could be from different sources)
    var recipe: QuickRecipe
    
    // Environment variable to dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for creating a new collection
    @State private var showingNewCollectionSheet = false
    @State private var newCollectionName = ""
    @State private var newCollectionDescription = ""
    
    // State to track selected collections
    @State private var selectedCollections: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // Collections List or Empty State
                if collectionsManager.collections.isEmpty {
                    EmptyCollectionsView()
                } else {
                    collectionsListView
                }
                
                // Create New Collection Button
                createNewCollectionButton
            }
            .navigationTitle("Add to Collection")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    addRecipeToSelectedCollections()
                }
                .disabled(selectedCollections.isEmpty)
            )
            .sheet(isPresented: $showingNewCollectionSheet) {
                newCollectionSheet
            }
        }
    }
    
    // List of Existing Collections
    private var collectionsListView: some View {
        List {
            ForEach(collectionsManager.collections) { collection in
                HStack {
                    VStack(alignment: .leading) {
                        Text(collection.name)
                            .font(.headline)
                        
                        Text("\(collection.recipes.count) recipes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Checkmark for selected collections
                    if selectedCollections.contains(collection.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleCollectionSelection(collection.id)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // Button to Create New Collection
    private var createNewCollectionButton: some View {
        Button(action: { showingNewCollectionSheet = true }) {
            HStack {
                Image(systemName: "plus.circle")
                Text("Create New Collection")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    // New Collection Creation Sheet
    private var newCollectionSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Collection Details")) {
                    TextField("Collection Name", text: $newCollectionName)
                    TextField("Description (Optional)", text: $newCollectionDescription)
                }
            }
            .navigationTitle("New Collection")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingNewCollectionSheet = false
                },
                trailing: Button("Create") {
                    createNewCollection()
                }
                .disabled(newCollectionName.isEmpty)
            )
        }
    }
    
    // Empty Collections View
    private func EmptyCollectionsView() -> some View {
        VStack {
            Image(systemName: "square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.title)
                .foregroundColor(.gray)
            
            Button("Create First Collection") {
                showingNewCollectionSheet = true
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    // Toggle collection selection
    private func toggleCollectionSelection(_ collectionId: UUID) {
        if selectedCollections.contains(collectionId) {
            selectedCollections.remove(collectionId)
        } else {
            selectedCollections.insert(collectionId)
        }
    }
    
    // Create a new collection
    private func createNewCollection() {
        // Create the new collection
        let newCollection = RecipeCollection(
            name: newCollectionName,
            description: newCollectionDescription.isEmpty ? nil : newCollectionDescription
        )
        
        // Add the collection
        collectionsManager.collections.append(newCollection)
        
        // Add the recipe to the new collection
        collectionsManager.addRecipeToCollection(
            quickRecipe: recipe,
            collectionId: newCollection.id
        )
        
        // Reset and dismiss
        newCollectionName = ""
        newCollectionDescription = ""
        showingNewCollectionSheet = false
        presentationMode.wrappedValue.dismiss()
    }
    
    // Add recipe to selected collections
    private func addRecipeToSelectedCollections() {
        for collectionId in selectedCollections {
            collectionsManager.addRecipeToCollection(
                quickRecipe: recipe,
                collectionId: collectionId
            )
        }
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}

// Preview for AddToCollectionView
struct AddToCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddToCollectionView(
            collectionsManager: CollectionsManager(),
            recipe: QuickRecipe(
                id: 1,
                title: "Chocolate Cake",
                image: "https://example.com/cake.jpg",
                imageType: "jpg"
            )
        )
    }
}
