import SwiftUI

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String
    let dateBought: String
    let category: String // New property for ingredient category
}

struct PantryView: View {
    // Sample list of ingredients
    @State private var ingredients: [Ingredient] = [
        Ingredient(name: "Chicken", dateBought: "2024-09-01", category: "Proteins"),
        Ingredient(name: "Yogurt", dateBought: "2024-09-20", category: "Dairy & Dairy Alternatives"),
        Ingredient(name: "Rice", dateBought: "2024-09-10", category: "Grains and Legumes"),
        Ingredient(name: "Basil", dateBought: "2024-09-05", category: "Spices, Seasonings and Herbs"),
        Ingredient(name: "Flour", dateBought: "2024-09-12", category: "Baking Essentials"),
        Ingredient(name: "Olive Oil", dateBought: "2024-09-15", category: "Oils and Fats"),
        Ingredient(name: "Soy Sauce", dateBought: "2024-09-17", category: "Sauces and Condiments"),
    ]

    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        // Title and action buttons at the top
                        HStack {
                            Text("My Pantry")
                                .font(.custom("Cochin", size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Spacer()

                            HStack(spacing: 10) {
                                // Camera Button
                                Button(action: {
                                    // Handle scan recipe action
                                }) {
                                    HStack {
                                        Image(systemName: "camera")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(Color.black)
                                    .cornerRadius(8)
                                }

                                // Sort Button
                                Button(action: {
                                    // Handle sort action
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.arrow.down")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(Color.black)
                                    .cornerRadius(8)
                                }

                                // Plus Button
                                Button(action: {
                                    // Handle adding a pantry item
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(Color.black)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.trailing, 5)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                        .padding(.leading, 5)
                        .padding(.top, 10)

                        // Search Bar
                        HStack {
                            TextField("Search ingredients...", text: $searchText)
                                .padding(10)
                                .font(.custom("Cochin", size: 18))
                                .background(Color.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.top, 10)

                        // Define custom order for categories
                        let customOrder = [
                            "Fruits & Vegetables",
                            "Proteins",
                            "Dairy & Dairy Alternatives",
                            "Grains and Legumes",
                            "Spices, Seasonings and Herbs",
                            "Sauces and Condiments",
                            "Baking Essentials", // Add Baking Essentials if needed
                            "Others" // Add Others category
                        ]

                        // Displaying ingredients by category
                        let groupedIngredients = Dictionary(grouping: ingredients.filter { ingredient in
                            searchText.isEmpty || ingredient.name.lowercased().contains(searchText.lowercased())
                        }) { $0.category }

                        ForEach(customOrder, id: \.self) { category in
                            VStack(alignment: .leading) {
                                Text(category)
                                    .font(.custom("Cochin", size: 22))
                                    .fontWeight(.bold)
                                    .padding(.top, 20)
                                    .padding(.horizontal)

                                // LazyVGrid for two cards in a row
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                    // Get ingredients for the current category or an empty array if none exist
                                    let ingredientsInCategory = groupedIngredients[category] ?? []

                                    ForEach(ingredientsInCategory) { ingredient in
                                        IngredientCard(ingredient: ingredient)
                                            .padding(.horizontal)
                                            .padding(.top, 10)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 100) // Space above the tab bar
                    }
                }
                .background(Color.white) // Background color for scrollable content

                // Bottom tab bar
                BottomTabBar()
                    .padding(.bottom, 30)
            }
            .edgesIgnoringSafeArea(.bottom) // Ensure the tab bar overlays the safe area
        }
    }
}

struct IngredientCard: View {
    let ingredient: Ingredient

    var body: some View {
        VStack {
            Text(ingredient.name)
                .font(.custom("Cochin", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text("Date bought: \(ingredient.dateBought)") // Added label before date
                .font(.custom("Cochin", size: 14))
                .italic()
                .foregroundColor(.gray)
                .padding(.top, 2) // Space between name and date
        }
        .padding()
        .frame(maxWidth: .infinity) // Make the card expand to the available width
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Optional shadow for depth
    }
}

struct PantryView_Previews: PreviewProvider {
    static var previews: some View {
        PantryView()
    }
}

