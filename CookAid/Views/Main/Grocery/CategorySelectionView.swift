import SwiftUI

struct CategorySelectionView: View {
    let ingredient: RecipeIngredient
    let groceryManager: GroceryManager
    let onAdd: () -> Void
    
    @State private var selectedCategory: String = ""
    @State private var errorMessage: String? = nil
    @State private var showingError: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    // Get categories from IngredientCategorizer
    private let categories = IngredientCategorizer.categories
    
    var body: some View {
        VStack {
            Text("Adding to Grocery List:")
                .font(.custom("Cochin", size: 20))
                .padding(.top)
            
            Text(ingredient.name)
                .font(.custom("Cochin", size: 22))
                .fontWeight(.bold)
                .padding(.bottom)
                
            Text("Select a category")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
                .padding(.bottom, 5)
            
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack {
                            Text(category)
                                .font(.custom("Cochin", size: 18))
                            
                            Spacer()
                            
                            if category == selectedCategory {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Button(action: {
                addToGroceryList()
            }) {
                Text("Add to Grocery List")
                    .font(.custom("Cochin", size: 18))
                    .fontWeight(.medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(selectedCategory.isEmpty)
        }
        .onAppear {
            // Auto-select category using IngredientCategorizer
            selectedCategory = IngredientCategorizer.categorize(ingredient.name)
        }
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "Unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addToGroceryList() {
        // Format the ingredient string
        let groceryItemName = "\(ingredient.name) - \(formatNumber(ingredient.amount)) \(ingredient.unit)"
        
        // Check for duplicates
        if isDuplicate(name: groceryItemName) {
            errorMessage = "This ingredient already exists in your grocery list"
            showingError = true
            return
        }
        
        // Create a new grocery item
        let groceryItem = GroceryItem(
            id: UUID().uuidString,
            name: groceryItemName,
            category: selectedCategory,
            completed: false
        )
        
        // Add to grocery list
        groceryManager.addGroceryItem(groceryItem)
        
        // Call the completion handler
        onAdd()
    }
    
    // Format number helper
    private func formatNumber(_ number: Double) -> String {
        return number.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", number) : String(format: "%.1f", number)
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
