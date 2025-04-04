import SwiftUI

struct EditGroceryItemView: View {
    @ObservedObject var groceryManager: GroceryManager
    @State private var itemName: String
    @State private var itemCategory: String
    @State private var isCompleted: Bool
    
    let groceryItem: GroceryItem
    @Environment(\.presentationMode) var presentationMode
    
    // Init with an existing grocery item
    init(groceryManager: GroceryManager, groceryItem: GroceryItem) {
        self.groceryManager = groceryManager
        self.groceryItem = groceryItem
        
        // Initialize state properties
        _itemName = State(initialValue: groceryItem.name)
        _itemCategory = State(initialValue: groceryItem.category)
        _isCompleted = State(initialValue: groceryItem.completed)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                        .font(.custom("Cochin", size: 18))
                    
                    Picker("Category", selection: $itemCategory) {
                        ForEach(IngredientCategorizer.categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Cochin", size: 18))
                    
                    Toggle("Completed", isOn: $isCompleted)
                        .font(.custom("Cochin", size: 18))
                }
                
                Section {
                    Button(action: {
                        updateGroceryItem()
                    }) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.custom("Cochin", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        groceryManager.deleteGroceryItem(groceryItem)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Delete Item")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.custom("Cochin", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Edit Grocery Item")
            .navigationBarItems(trailing:
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func updateGroceryItem() {
        // Validate input
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedName.isEmpty {
            // Create updated item
            let updatedItem = GroceryItem(
                id: groceryItem.id,
                name: trimmedName,
                category: itemCategory,
                completed: isCompleted
            )
            
            // Update the item in the manager
            groceryManager.updateGroceryItem(updatedItem)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
