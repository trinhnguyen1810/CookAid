import SwiftUI

struct GroceryView: View {
    @StateObject private var groceryManager = GroceryManager() // Use GroceryManager
    @State private var searchText: String = ""
    @State private var showAddGrocery = false // State to show the add grocery view
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        // Header Section
                        HStack {
                            Text("Grocery List")
                                .font(.custom("Cochin", size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Search Bar
                        HStack {
                            TextField("Search ingredients...", text: $searchText)
                                .padding(10)
                                .font(.custom("Cochin", size: 18))
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                            Button(action: {
                                showAddGrocery.toggle() // Show the add grocery view
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)

                        let customOrder = [
                            "Fruits & Vegetables",
                            "Proteins",
                            "Dairy & Dairy Alternatives",
                            "Grains and Legumes",
                            "Spices, Seasonings and Herbs",
                            "Sauces and Condiments",
                            "Baking Essentials",
                            "Others"
                        ]

                        let groupedIngredients = Dictionary(grouping: groceryManager.groceryItems.filter { item in
                            searchText.isEmpty || item.name.lowercased().contains(searchText.lowercased())
                        }) { $0.category }

                        ForEach(customOrder, id: \.self) { category in
                            VStack(alignment: .leading) {
                                Text(category)
                                    .font(.custom("Cochin", size: 22))
                                    .fontWeight(.bold)
                                    .padding(.top, 20)
                                    .padding(.horizontal)

                                ForEach(groupedIngredients[category] ?? []) { ingredient in
                                    Text(ingredient.name)
                                        .font(.custom("Cochin", size: 18))
                                        .foregroundColor(.black)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        .strikethrough(ingredient.completed) // Apply strikethrough based on completion
                                        .onTapGesture {
                                            toggleCompletion(for: ingredient) // Toggle completion on tap
                                        }
                                }
                            }
                        }
                    }
                }

                BottomTabBar() // Your existing tab bar
            }
            .sheet(isPresented: $showAddGrocery) {
                AddGroceryView(groceryManager: groceryManager) // Pass GroceryManager
            }
        }
    }

    private func toggleCompletion(for ingredient: GroceryItem) {
        if let index = groceryManager.groceryItems.firstIndex(where: { $0.id == ingredient.id }) {
            groceryManager.groceryItems[index].completed.toggle() // Toggle the completed state
        }
    }
}

// Preview
struct GroceryView_Previews: PreviewProvider {
    static var previews: some View {
        GroceryView()
    }
}
