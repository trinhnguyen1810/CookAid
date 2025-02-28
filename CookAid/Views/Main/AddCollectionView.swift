import SwiftUI

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
