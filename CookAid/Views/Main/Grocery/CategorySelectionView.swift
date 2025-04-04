import SwiftUI

struct CategorySelectionView: View {
    let ingredient: RecipeIngredient
    let groceryManager: GroceryManager
    let onAdd: () -> Void
    
    // Initialize with auto-selected category based on ingredient name
    @State private var selectedCategory: String
    @Environment(\.presentationMode) var presentationMode
    
    init(ingredient: RecipeIngredient, groceryManager: GroceryManager, onAdd: @escaping () -> Void) {
        self.ingredient = ingredient
        self.groceryManager = groceryManager
        self.onAdd = onAdd
        
        // Auto-select a category based on the ingredient name
        let autoCategory = IngredientCategorizer.categorize(ingredient.name)
        _selectedCategory = State(initialValue: autoCategory)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Adding to Grocery List:")
                .font(.custom("Cochin", size: 20))
                .padding(.top)
            
            Text(ingredient.name)
                .font(.custom("Cochin", size: 22))
                .fontWeight(.bold)
                .padding(.bottom)
            
            // Display ingredient amount and unit if available
            if ingredient.amount > 0 {
                Text("\(formatNumber(ingredient.amount)) \(ingredient.unit)")
                    .font(.custom("Cochin", size: 18))
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            
            // Use a simple picker with pre-selected category
            Picker("Category", selection: $selectedCategory) {
                ForEach(IngredientCategorizer.categories, id: \.self) { category in
                    Text(category)
                        .font(.custom("Cochin", size: 18))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
            .padding(.horizontal)
            
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
        }
    }
    
    private func addToGroceryList() {
        // Create a new grocery item with the selected category
        let groceryItem = GroceryItem(
            id: UUID().uuidString,
            name: "\(ingredient.name) - \(formatNumber(ingredient.amount)) \(ingredient.unit)",
            category: selectedCategory
        )
        
        // Add to grocery list using grocery manager
        groceryManager.addGroceryItem(groceryItem)
        
        // Call the closure to dismiss the sheet from the parent view
        onAdd()
    }
    
    private func formatNumber(_ number: Double) -> String {
        return number.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", number) : String(format: "%.1f", number)
    }
}
