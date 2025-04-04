import SwiftUI
import Firebase
import FirebaseFirestore

struct PantryView: View {
    @StateObject private var ingredientsManager = IngredientsManager()
    @State private var showAddIngredient = false
    @State private var searchText: String = ""
    @State private var selectedIngredient: Ingredient? // To hold the ingredient to edit
    @State private var isDragging = false
    @State private var draggedIngredient: Ingredient?
    @State private var targetCategory: String?

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
                        let customOrder = ["Proteins", "Dairy & Dairy Alternatives", "Grains and Legumes", "Fruits & Vegetables", "Spices, Seasonings and Herbs", "Sauces and Condiments", "Cooking Essentials", "Others"]

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
                                    .background(targetCategory == category ? Color.blue.opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                                
                                // We'll wrap everything in a ZStack to allow dropping on empty categories
                                ZStack {
                                    // This Rectangle serves as a drop target for empty categories
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: groupedIngredients[category]?.isEmpty ?? true ? 100 : 0)
                                        .dropDestination(for: String.self) { items, location in
                                            guard let draggedIngredient = draggedIngredient else { return false }
                                            
                                            // Check if the dragged ingredient is from a different category
                                            if draggedIngredient.category != category {
                                                moveIngredient(draggedIngredient, toCategory: category)
                                                return true
                                            }
                                            return false
                                        } isTargeted: { isTargeted in
                                            targetCategory = isTargeted ? category : nil
                                        }
                                    
                                    // LazyVGrid for two cards in a row
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                        // Get ingredients for the current category or an empty array if none exist
                                        let ingredientsInCategory = groupedIngredients[category] ?? []
                                        
                                        if ingredientsInCategory.isEmpty {
                                            // Show an empty state for categories with no ingredients
                                            Text("Drag ingredients here")
                                                .font(.custom("Cochin", size: 16))
                                                .italic()
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                        } else {
                                            ForEach(ingredientsInCategory) { ingredient in
                                                IngredientCard(
                                                    ingredient: ingredient,
                                                    ingredients: $ingredientsManager.ingredients,
                                                    isDragging: $isDragging,
                                                    draggedIngredient: $draggedIngredient
                                                )
                                                .padding(.horizontal)
                                                .padding(.top, 10)
                                                .onTapGesture {
                                                    selectedIngredient = ingredient // Set the selected ingredient for editing on tap
                                                }
                                                .onDrag {
                                                    draggedIngredient = ingredient
                                                    isDragging = true
                                                    return NSItemProvider(object: ingredient.id as NSString)
                                                }
                                            }
                                        }
                                    }
                                    .dropDestination(for: String.self) { items, location in
                                        guard let draggedIngredient = draggedIngredient else { return false }
                                        
                                        // Check if the dragged ingredient is from a different category
                                        if draggedIngredient.category != category {
                                            moveIngredient(draggedIngredient, toCategory: category)
                                            return true
                                        }
                                        return false
                                    } isTargeted: { isTargeted in
                                        targetCategory = isTargeted ? category : nil
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
            .onChange(of: isDragging) { dragging in
                if !dragging {
                    // Reset when drag ends
                    targetCategory = nil
                    draggedIngredient = nil
                }
            }
        }
    }
    
    private func moveIngredient(_ ingredient: Ingredient, toCategory category: String) {
        Task {
            await ingredientsManager.updateIngredientCategory(ingredient, newCategory: category)
            // Reset drag state
            isDragging = false
            draggedIngredient = nil
        }
    }
    
    struct IngredientCard: View {
        let ingredient: Ingredient
        @Binding var ingredients: [Ingredient]
        @Binding var isDragging: Bool
        @Binding var draggedIngredient: Ingredient?

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
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            // Add visual feedback when dragging
            .opacity(isDragging && draggedIngredient?.id == ingredient.id ? 0.5 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDragging && draggedIngredient?.id == ingredient.id ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// Extension for IngredientsManager to add the updateIngredientCategory method
extension IngredientsManager {
    @MainActor
    func updateIngredientCategory(_ ingredient: Ingredient, newCategory: String) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        // Create updated ingredient with new category
        let updatedIngredient = Ingredient(
            id: ingredient.id,
            name: ingredient.name,
            dateBought: ingredient.dateBought,
            category: newCategory
        )
        
        // Update in Firestore
        let db = Firestore.firestore()
        do {
            try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .document(ingredient.id)
                .setData(from: updatedIngredient)
            
            // Update in local state
            if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                ingredients[index] = updatedIngredient
            }
            
            print("Ingredient category updated successfully")
        } catch {
            print("Error updating ingredient category: \(error.localizedDescription)")
        }
    }
}

struct PantryView_Previews: PreviewProvider {
    static var previews: some View {
        PantryView()
    }
}
