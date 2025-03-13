import SwiftUI

struct CategorySelectionView: View {
    let ingredient: RecipeIngredient
    let groceryManager: GroceryManager
    let onAdd: () -> Void
    @State private var selectedCategory: String = "Others"
    @Environment(\.presentationMode) var presentationMode
    
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
