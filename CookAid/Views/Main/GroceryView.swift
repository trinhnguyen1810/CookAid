import SwiftUI

struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
}

struct GroceryView: View {
    @State private var groceryItems: [GroceryItem] = [
        GroceryItem(name: "Apples", category: "Fruits & Vegetables"),
        GroceryItem(name: "Bananas", category: "Fruits & Vegetables"),
        GroceryItem(name: "Carrots", category: "Fruits & Vegetables"),
        GroceryItem(name: "Chicken", category: "Proteins"),
        GroceryItem(name: "Milk", category: "Dairy & Dairy Alternatives"),
        GroceryItem(name: "Rice", category: "Grains and Legumes"),
        GroceryItem(name: "Salt", category: "Spices, Seasonings and Herbs"),
        GroceryItem(name: "Olive Oil", category: "Others")
    ]
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack{
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
                                print("Add button tapped")
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

                        let groupedIngredients = Dictionary(grouping: groceryItems.filter { item in
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
                                }
                            }
                        }
                    }
                  
                }

                BottomTabBar() // Your existing tab bar
            }
        }
    }
}

// Preview
struct GroceryView_Previews: PreviewProvider {
    static var previews: some View {
        GroceryView()
    }
}

