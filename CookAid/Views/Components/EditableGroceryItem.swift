import SwiftUI

// MARK: - Editable Grocery Item
struct EditableGroceryItem: View {
    @ObservedObject var groceryManager: GroceryManager
    var groceryItem: GroceryItem
    
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedCategory: String = ""
    
    // Available categories
    let categories = [
        "Fruits & Vegetables",
        "Proteins",
        "Dairy & Dairy Alternatives",
        "Grains and Legumes",
        "Spices, Seasonings and Herbs",
        "Sauces and Condiments",
        "Baking Essentials",
        "Others"
    ]
    
    var body: some View {
        if isEditing {
            // Editing mode - inline editor
            VStack(alignment: .leading, spacing: 8) {
                // Name TextField
                TextField("Item name", text: $editedName, onCommit: {
                    if editedName.isEmpty {
                        // Delete if empty
                        deleteItem()
                    } else {
                        saveChanges()
                    }
                })
                .font(.custom("Cochin", size: 16))
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                
                // Category Picker
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            editedCategory = category
                        }) {
                            HStack {
                                Text(category)
                                if category == editedCategory {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(editedCategory)
                            .font(.custom("Cochin", size: 14))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // Action buttons
                HStack {
                    // Save button
                    Button(action: saveChanges) {
                        Label("Save", systemImage: "checkmark.circle.fill")
                            .font(.custom("Cochin", size: 14))
                            .foregroundColor(.green)
                    }
                    .padding(.trailing, 8)
                    
                    // Cancel button
                    Button(action: cancelEditing) {
                        Label("Cancel", systemImage: "xmark.circle.fill")
                            .font(.custom("Cochin", size: 14))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    // Delete button
                    Button(action: deleteItem) {
                        Label("Delete", systemImage: "trash")
                            .font(.custom("Cochin", size: 14))
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 4)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .animation(.default, value: isEditing)
        } else {
            // Display mode - normal grocery item
            Text(groceryItem.name)
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .strikethrough(groceryItem.completed) // Apply strikethrough based on completion
                .onTapGesture {
                    toggleCompletion()
                }
                .onLongPressGesture {
                    startEditing()
                }
                .contextMenu {
                    Button(action: startEditing) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: deleteItem) {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button(action: toggleCompletion) {
                        Label(groceryItem.completed ? "Mark as Incomplete" : "Mark as Complete",
                              systemImage: groceryItem.completed ? "circle" : "checkmark.circle")
                    }
                }
        }
    }
    
    // Start editing mode
    private func startEditing() {
        editedName = groceryItem.name
        editedCategory = groceryItem.category
        withAnimation {
            isEditing = true
        }
    }
    
    // Save changes
    private func saveChanges() {
        if !editedName.isEmpty {
            // Create updated item
            let updatedItem = GroceryItem(
                id: groceryItem.id,
                name: editedName,
                category: editedCategory,
                completed: groceryItem.completed
            )
            
            // Use the groceryManager to update the item
            groceryManager.updateGroceryItem(updatedItem)
        }
        
        withAnimation {
            isEditing = false
        }
    }
    
    // Cancel editing
    private func cancelEditing() {
        withAnimation {
            isEditing = false
        }
    }
    
    // Delete item
    private func deleteItem() {
        groceryManager.deleteGroceryItem(groceryItem)
        
        withAnimation {
            isEditing = false
        }
    }
    
    // Toggle completion
    private func toggleCompletion() {
        // Create updated item
        let updatedItem = GroceryItem(
            id: groceryItem.id,
            name: groceryItem.name,
            category: groceryItem.category,
            completed: !groceryItem.completed
        )
        
        // Use the groceryManager to update the item
        groceryManager.updateGroceryItem(updatedItem)
    }
}
