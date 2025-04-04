import SwiftUI

struct EditGroceryItemView: View {
    @ObservedObject var groceryManager: GroceryManager
    @StateObject private var ingredientsManager = IngredientsManager()
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
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    
                    Button(action: {
                        addToPantry()
                    }) {
                        Text("Add to Pantry")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.custom("Cochin", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                    }
                
                    Button(action: {
                        groceryManager.deleteGroceryItem(groceryItem)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Delete Item")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.custom("Cochin", size: 18))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
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
    
    private func addToPantry() {
        // Extract just the ingredient name from the full text
        var ingredientName = groceryItem.name
        
        // Check if the name contains a hyphen (which separates name from quantity)
        if let hyphenRange = groceryItem.name.range(of: " - ") {
            // Extract just the part before the hyphen
            ingredientName = String(groceryItem.name[..<hyphenRange.lowerBound])
        }
        
        let newIngredient = Ingredient(
            id: groceryItem.id,
            name: ingredientName, // Use the extracted name
            dateBought: Date(),
            category: groceryItem.category
        )
        
        // Add to pantry using IngredientsManager
        Task {
            await ingredientsManager.addIngredient(newIngredient)
            groceryManager.deleteGroceryItem(groceryItem)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
