import SwiftUI

struct PantryView: View {
    // Sample list of ingredients
    @StateObject private var ingredientsManager = IngredientsManager()
    @State private var showAddIngredient = false
    @State private var searchText: String = ""
    @State private var selectedIngredient: Ingredient? // To hold the ingredient to edit

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
                                    showAddIngredient.toggle()
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
                        let customOrder = ["Proteins", "Dairy & Dairy Alternatives", "Grains and Legumes", "Fruits & Vegetables", "Spices, Seasonings and Herbs", "Sauces and Condiments", "Cooking Essentials","Others"]

                        // Displaying ingredients by category
                        let groupedIngredients = Dictionary(grouping: ingredientsManager.ingredients.filter { ingredient in
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
                                        IngredientCard(ingredient: ingredient, ingredients: $ingredientsManager.ingredients)
                                            .padding(.horizontal)
                                            .padding(.top, 10)
                                            .onTapGesture {
                                                selectedIngredient = ingredient // Set the selected ingredient for editing on tap
                                            }
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
            .edgesIgnoringSafeArea(.bottom)
            .sheet(item: $selectedIngredient) { ingredient in
                EditIngredientView(ingredients: $ingredientsManager.ingredients, ingredient: ingredient)
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientView(ingredients: $ingredientsManager.ingredients)
            }
        }
    }
    
    struct IngredientCard: View {
        let ingredient: Ingredient
        @Binding var ingredients: [Ingredient] // Add binding to ingredients

        var body: some View {
            VStack {
                Text(ingredient.name)
                    .font(.custom("Cochin", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                let dateString = ingredient.dateBought != nil ? DateFormatter.localizedString(from: ingredient.dateBought!, dateStyle: .medium, timeStyle: .none) : "N/A"
                
                Text("Date bought: \(dateString)")
                    .font(.custom("Cochin", size: 14))
                    .italic()
                    .foregroundColor(.gray)
                    .padding(.top, 2)

                // Removed the Edit button; the card itself is tappable
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    struct PantryView_Previews: PreviewProvider {
        static var previews: some View {
            PantryView()
        }
    }
}
