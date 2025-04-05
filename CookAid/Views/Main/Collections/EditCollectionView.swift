import SwiftUI

struct EditCollectionView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    @Environment(\.presentationMode) var presentationMode
    
    // Local state
    @State private var name: String
    @State private var description: String
    
    // The collection ID
    let collectionId: UUID
    
    // Add callback for notifying parent view of changes
    var onSave: (() -> Void)?
    
    init(collection: RecipeCollection, onSave: (() -> Void)? = nil) {
        self.collectionId = collection.id
        self._name = State(initialValue: collection.name)
        self._description = State(initialValue: collection.description ?? "")
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            Section(header: Text("Collection Details")) {
                TextField("Collection Name", text: $name)
                TextField("Description (Optional)", text: $description)
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
            }
        }
        .navigationTitle("Edit Collection")
    }
    
    private func saveChanges() {
        // Direct update approach for immediate effect
        if let index = collectionsManager.collections.firstIndex(where: { $0.id == collectionId }) {
            // Update the collection directly
            collectionsManager.collections[index].name = name
            collectionsManager.collections[index].description = description.isEmpty ? nil : description
            
            // Save to persistence
            collectionsManager.saveCollections()
            
            // Force UI refresh with explicit notification
            DispatchQueue.main.async {
                // Notify observers
                collectionsManager.objectWillChange.send()
                
                // If we have a callback, call it
                onSave?()
                
                // Create a small delay before dismissing to allow UI to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            // Fallback to using the manager method
            collectionsManager.updateCollection(
                collectionId: collectionId,
                name: name,
                description: description.isEmpty ? nil : description
            )
            
            // Call onSave if provided
            onSave?()
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        }
    }
}
