import SwiftUI

struct AddGroceryView: View {
    @ObservedObject var groceryManager: GroceryManager
    @State private var name: String = ""
    @State private var category: String = "Others" // Default category
    @State private var errorMessage: String? = nil
    @State private var showingError: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    // Get categories from IngredientCategorizer
    private let categories = IngredientCategorizer.categories
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Grocery Item")) {
                    TextField("Grocery Name", text: $name)
                        .font(.custom("Cochin", size: 18))
                        .onChange(of: name) { newValue in
                            if !newValue.isEmpty {
                                // Automatically categorize as user types
                                category = IngredientCategorizer.categorize(newValue)
                            }
                        }

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Cochin", size: 18))
                }

                Button("Add Grocery") {
                    addGrocery()
                }
                .font(.custom("Cochin", size: 18))
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle("Add Grocery")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "Unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func addGrocery() {
        // Validate input - trim whitespace
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if name is empty
        if trimmedName.isEmpty {
            errorMessage = "Grocery name cannot be empty"
            showingError = true
            return
        }
        
        // Check for duplicates
        if isDuplicate(name: trimmedName) {
            errorMessage = "This item already exists in your grocery list"
            showingError = true
            return
        }
        
        // Create the grocery item
        let groceryItem = GroceryItem(
            id: UUID().uuidString,
            name: trimmedName,
            category: category,
            completed: false
        )
        
        // Add to grocery list
        groceryManager.addGroceryItem(groceryItem)
        
        presentationMode.wrappedValue.dismiss();
    }
    
    // Check if the item already exists in the grocery list
    private func isDuplicate(name: String) -> Bool {
        return groceryManager.groceryItems.contains { item in
            // Extract just the base name if it contains " - " separator
            let itemBaseName = item.name.components(separatedBy: " - ").first ?? item.name
            let nameToCheck = name.components(separatedBy: " - ").first ?? name
            
            return itemBaseName.lowercased() == nameToCheck.lowercased()
        }
    }
}

struct AddGroceryView_Previews: PreviewProvider {
    static var previews: some View {
        AddGroceryView(groceryManager: GroceryManager())
    }
}
