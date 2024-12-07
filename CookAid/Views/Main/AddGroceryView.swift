import SwiftUI

struct AddGroceryView: View {
    @ObservedObject var groceryManager: GroceryManager // Use GroceryManager
    @State private var name: String = ""
    @State private var category: String = "Others" // Default category
    @Environment(\.presentationMode) var presentationMode
    
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
        NavigationView {
            Form {
                Section(header: Text("Add Grocery Item")) {
                    TextField("Grocery Name", text: $name)
                        .font(.custom("Cochin", size: 18))

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
            }
            .navigationTitle("Add Grocery")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addGrocery() {
        let newGrocery = GroceryItem(id: UUID().uuidString, name: name, category: category)
        groceryManager.addGroceryItem(newGrocery) // Use GroceryManager to add
        presentationMode.wrappedValue.dismiss() // Dismiss the view after adding
    }
}
