import SwiftUI

struct EditCollectionView: View {
    @State private var collection: RecipeCollection
    @State private var name: String
    @State private var description: String
    @EnvironmentObject var collectionsManager: CollectionsManager
    @Environment(\.presentationMode) var presentationMode
    
    init(collection: RecipeCollection) {
        _collection = State(initialValue: collection)
        _name = State(initialValue: collection.name)
        _description = State(initialValue: collection.description ?? "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Collection Details")) {
                TextField("Collection Name", text: $name)
                TextField("Description (Optional)", text: $description)
            }
            
            Section {
                Button("Save Changes") {
                    collectionsManager.updateCollection(
                        collectionId: collection.id,
                        name: name,
                        description: description.isEmpty ? nil : description
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Edit Collection")
    }
}
