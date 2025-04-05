import SwiftUI

struct PantryView: View {
    @StateObject private var ingredientsManager = IngredientsManager()
    @State private var showAddIngredient = false
    @State private var searchText: String = ""
    @State private var selectedIngredient: Ingredient? // To hold the ingredient to edit
    @State private var showClearAllAlert = false
    @State private var showClearCategoryAlert = false
    @State private var categoryToClear: String = ""

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
                                // Menu for Clear options
                                Menu {
                                    Button(action: {
                                        showClearAllAlert = true
                                    }) {
                                        Label("Clear All Ingredients", systemImage: "trash")
                                    }
                                    
                                    Menu("Clear by Category") {
                                        ForEach(IngredientCategorizer.categories, id: \.self) { category in
                                            Button(action: {
                                                categoryToClear = category
                                                showClearCategoryAlert = true
                                            }) {
                                                Text(category)
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(Color.red)
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
                        
                        // Empty state
                        if ingredientsManager.ingredients.isEmpty {
                            VStack(spacing: 20) {
                                Spacer().frame(height: 40)
                                Image(systemName: "carrot")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.gray)
                                Text("Your pantry is empty")
                                    .font(.custom("Cochin", size: 18))
                                    .foregroundColor(.gray)
                                Text("Tap + to add ingredients")
                                    .font(.custom("Cochin", size: 15))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            // Define custom order for categories
                            let customOrder = IngredientCategorizer.categories

                            // Displaying ingredients by category
                            let groupedIngredients = Dictionary(grouping: ingredientsManager.ingredients.filter { ingredient in
                                searchText.isEmpty || ingredient.name.lowercased().contains(searchText.lowercased())
                            }) { $0.category }
                            
                            ForEach(customOrder, id: \.self) { category in
                                if let ingredientsInCategory = groupedIngredients[category], !ingredientsInCategory.isEmpty {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(categoryEmoji(for: category))
                                            Text(category)
                                                .font(.custom("Cochin", size: 22))
                                                .fontWeight(.bold)
                                        }
                                        .padding(.top, 20)
                                        .padding(.horizontal)
                                        
                                        
                                        // LazyVGrid for two cards in a row
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                            ForEach(ingredientsInCategory) { ingredient in
                                                IngredientCard(ingredient: ingredient)
                                                    .padding(.horizontal)
                                                    .padding(.top, 10)
                                                    .onTapGesture {
                                                        selectedIngredient = ingredient // Set the selected ingredient for editing on tap
                                                    }
                                            }
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
            .onAppear {
                // Force refresh if not initialized
                if !ingredientsManager.isInitialized {
                    ingredientsManager.forceRefresh()
                    print("PantryView: Forced ingredients refresh on appear")
                }
            }
            
            .sheet(item: $selectedIngredient) { ingredient in
                EditIngredientView(ingredients: $ingredientsManager.ingredients, ingredient: ingredient)
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientView(ingredients: $ingredientsManager.ingredients)
            }
            .alert("Clear All Ingredients", isPresented: $showClearAllAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    Task {
                        await ingredientsManager.clearAllIngredients()
                    }
                }
            } message: {
                Text("Are you sure you want to remove all ingredients from your pantry? This cannot be undone.")
            }
            .alert("Clear Category", isPresented: $showClearCategoryAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear \(categoryToClear)", role: .destructive) {
                    Task {
                        await ingredientsManager.clearIngredientsByCategory(category: categoryToClear)
                    }
                }
            } message: {
                Text("Are you sure you want to remove all \(categoryToClear) from your pantry?")
            }
            .task {
                await ingredientsManager.fetchIngredients()
            }
        }
    }
}

// Separate struct for ingredient card
struct IngredientCard: View {
    let ingredient: Ingredient

    var body: some View {
        VStack {
            Text(ingredient.name)
                .font(.custom("Cochin", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(1)
            
            let dateString = ingredient.dateBought != nil ? DateFormatter.localizedString(from: ingredient.dateBought!, dateStyle: .medium, timeStyle: .none) : "N/A"
            
            Text("Date bought: \(dateString)")
                .font(.custom("Cochin", size: 14))
                .italic()
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension PantryView {
    private func categoryEmoji(for category: String) -> String {
        switch category {
        case "Proteins": return "🥩"
        case "Dairy & Dairy Alternatives": return "🥛"
        case "Grains and Legumes": return "🌾"
        case "Fruits & Vegetables": return "🥦"
        case "Spices, Seasonings and Herbs": return "🌿"
        case "Sauces and Condiments": return "🥫"
        case "Cooking Essentials": return "🧂"
        case "Others": return "📦"
        default: return "📦"
        }
    }
}


struct PantryView_Previews: PreviewProvider {
    static var previews: some View {
        PantryView()
    }
}
