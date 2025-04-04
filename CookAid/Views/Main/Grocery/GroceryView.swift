import SwiftUI

struct GroceryView: View {
    @StateObject private var groceryManager = GroceryManager()
    @StateObject private var ingredientsManager = IngredientsManager()
    @State private var searchText: String = ""
    @State private var showAddGrocery = false
    @State private var showDeleteAlert = false
    @State private var showClearAllAlert = false
    @State private var showClearCompletedAlert = false
    @State private var itemToDelete: GroceryItem?
    @State private var itemToAddToPantry: GroceryItem?
    @State private var itemToEdit: GroceryItem?
    @State private var showActionAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Header Section
                        HStack {
                            Text("Grocery List")
                                .font(.custom("Cochin", size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    showClearAllAlert = true
                                }) {
                                    Label("Clear All Items", systemImage: "trash")
                                }
                                
                                Button(action: {
                                    showClearCompletedAlert = true
                                }) {
                                    Label("Clear Completed Items", systemImage: "checkmark.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Search Bar and Add Button
                        HStack {
                            TextField("Search ingredients...", text: $searchText)
                                .padding(10)
                                .font(.custom("Cochin", size: 18))
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                            Button(action: {
                                showAddGrocery.toggle() // Show the AddGroceryView
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Empty state
                        if groceryManager.groceryItems.isEmpty {
                            VStack(spacing: 20) {
                                Spacer().frame(height: 40)
                                Image(systemName: "cart")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.gray)
                                Text("Your grocery list is empty")
                                    .font(.custom("Cochin", size: 18))
                                    .foregroundColor(.gray)
                                Text("Tap + to add items")
                                    .font(.custom("Cochin", size: 15))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            // Category sections using IngredientCategorizer
                            ForEach(IngredientCategorizer.categories, id: \.self) { category in
                                groceryCategorySection(category: category)
                            }
                            
                            // Space at bottom for tab bar
                            Spacer().frame(height: 50)
                        }
                    }
                }

                BottomTabBar()
            }
            .sheet(isPresented: $showAddGrocery) {
                AddGroceryView(groceryManager: groceryManager)
            }
            .sheet(item: $itemToEdit) { item in
                EditGroceryItemView(groceryManager: groceryManager, groceryItem: item)
            }
            .alert("Delete Item", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let itemToDelete = itemToDelete {
                        deleteGroceryItem(itemToDelete)
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(itemToDelete?.name ?? "")?")
            }
            .alert("Clear All Items", isPresented: $showClearAllAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    groceryManager.clearAllItems()
                }
            } message: {
                Text("Are you sure you want to delete all items from your grocery list? This cannot be undone.")
            }
            .alert("Clear Completed Items", isPresented: $showClearCompletedAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear Completed", role: .destructive) {
                    groceryManager.clearCompletedItems()
                }
            } message: {
                Text("Are you sure you want to delete all completed items from your grocery list?")
            }
            .alert("Item Options", isPresented: $showActionAlert) {
                Button("Edit Item", role: .none) {
                    if let item = itemToAddToPantry {
                        itemToEdit = item
                    }
                }
                Button("Add to Pantry", role: .none) {
                    if let item = itemToAddToPantry {
                        addToPantry(item)
                    }
                }
                Button("Delete", role: .destructive) {
                    if let itemToDelete = itemToAddToPantry {
                        deleteGroceryItem(itemToDelete)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("What would you like to do with \(itemToAddToPantry?.name ?? "")?")
            }
            .onAppear {
                groceryManager.fetchGroceryItems()
            }
        }
    }
    
    // Helper function to create category sections
    private func groceryCategorySection(category: String) -> some View {
        let filteredItems = groceryManager.groceryItems.filter { item in
            (item.category == category) &&
            (searchText.isEmpty || item.name.lowercased().contains(searchText.lowercased()))
        }
        
        // Only show categories that have items
        if filteredItems.isEmpty {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(categoryEmoji(for: category))
                    Text(category)
                        .font(.custom("Cochin", size: 22))
                        .fontWeight(.bold)
                }
                .padding(.top, 10)
                .padding(.horizontal)

                ForEach(filteredItems) { item in
                    groceryItemView(item: item)
                }
            }
        )
    }
    
    // Helper function to create grocery item views
    private func groceryItemView(item: GroceryItem) -> some View {
        HStack {
            Button(action: {
                groceryManager.toggleCompletion(for: item)
            }) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.completed ? .green : .gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(item.name)
                .font(.custom("Cochin", size: 16))
                .foregroundColor(item.completed ? .gray : .black)
                .strikethrough(item.completed)
                .lineLimit(1)
                .onTapGesture {
                    // Direct tap on text opens the edit view
                    itemToEdit = item
                }
            
            Spacer()
            
            Button(action: {
                itemToAddToPantry = item
                showActionAlert = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2)
        .padding(.horizontal)
        .contentShape(Rectangle())
    }

    private func deleteGroceryItem(_ item: GroceryItem) {
        groceryManager.deleteGroceryItem(item)
    }

    private func addToPantry(_ item: GroceryItem) {
        // Extract just the ingredient name from the full text
        // The format is: "[name] - [amount] [unit]"
        var ingredientName = item.name
        
        // Check if the name contains a hyphen (which separates name from quantity)
        if let hyphenRange = item.name.range(of: " - ") {
            // Extract just the part before the hyphen
            ingredientName = String(item.name[..<hyphenRange.lowerBound])
        }
        
        let newIngredient = Ingredient(
            id: UUID().uuidString,
            name: ingredientName, // Use the extracted name
            dateBought: Date(),
            category: item.category
        )
        
        // Add to pantry using IngredientsManager
        Task {
            await ingredientsManager.addIngredient(newIngredient)
            deleteGroceryItem(item)
        }
    }
}

extension GroceryView {
    private func categoryEmoji(for category: String) -> String {
        switch category {
        case "Fruits & Vegetables": return "🍎"
        case "Proteins": return "🥩"
        case "Dairy & Dairy Alternatives": return "🥛"
        case "Grains and Legumes": return "🌾"
        case "Spices, Seasonings and Herbs": return "🌿"
        case "Sauces and Condiments": return "🥫"
        case "Baking Essentials": return "🥣"
        case "Others": return "📦"
        default: return "📦"
        }
    }
}
