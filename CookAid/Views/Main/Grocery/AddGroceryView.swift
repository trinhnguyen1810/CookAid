import SwiftUI

struct AddGroceryView: View {
    @ObservedObject var groceryManager: GroceryManager
    @State private var name: String = ""
    @State private var category: String = "Others" // Default to Others
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Grocery Item")) {
                    TextField("Item Name", text: $name)
                        .font(.custom("Cochin", size: 18))
                        .onChange(of: name) { newValue in
                            // Auto-categorize as user types
                            if !newValue.isEmpty {
                                category = IngredientCategorizer.categorize(newValue)
                            }
                        }
                    
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategorizer.categories, id: \.self) { category in
                            Text(category)
                                .font(.custom("Cochin", size: 18))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Cochin", size: 18))
                }
                
                Button("Add to Grocery List") {
                    addGroceryItem()
                }
                .font(.custom("Cochin", size: 18))
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Add Grocery Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addGroceryItem() {
        let item = GroceryItem(
            id: UUID().uuidString,
            name: name,
            category: category
        )
        
        groceryManager.addGroceryItem(item)
        presentationMode.wrappedValue.dismiss()
    }
}
