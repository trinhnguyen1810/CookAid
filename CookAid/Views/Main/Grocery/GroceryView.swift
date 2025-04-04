import SwiftUI

struct GroceryView: View {
    @StateObject private var groceryManager = GroceryManager() // Use GroceryManager
    @StateObject private var ingredientsManager = IngredientsManager()
    @State private var searchText: String = ""
    @State private var showAddGrocery = false // State to show the add grocery view
    @State private var showDeleteAlert = false // State to show delete confirmation alert
    @State private var itemToDelete: GroceryItem? // The item to delete
    @State private var itemToAddToPantry: GroceryItem? // The item to add to pantry
    @State private var showActionAlert = false // State to show action alert
    @State private var isAddingNewItem = false // State for inline adding of new items
    @State private var newItemName = ""
    @State private var newItemCategory = "Others"

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
                            TextField("Search items...", text: $searchText)
                                .padding(10)
                                .font(.custom("Cochin", size: 18))
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                            Button(action: {
                                withAnimation {
                                    isAddingNewItem.toggle() // Toggle inline adding
                                    if !isAddingNewItem {
                                        newItemName = ""
                                    }
                                }
                            }) {
                                Image(systemName: isAddingNewItem ? "xmark" : "plus")
                                    .foregroundColor(.black)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        
                        // New Item Entry (Inline)
                        if isAddingNewItem {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("New item name", text: $newItemName)
                                    .font(.custom("Cochin", size: 16))
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                
                                // Category Picker
                                Menu {
                                    ForEach([
                                        "Fruits & Vegetables",
                                        "Proteins",
                                        "Dairy & Dairy Alternatives",
                                        "Grains and Legumes",
                                        "Spices, Seasonings and Herbs",
                                        "Sauces and Condiments",
                                        "Baking Essentials",
                                        "Others"
                                    ], id: \.self) { category in
                                        Button(action: {
                                            newItemCategory = category
                                        }) {
                                            HStack {
                                                Text(category)
                                                if category == newItemCategory {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(newItemCategory)
                                            .font(.custom("Cochin", size: 14))
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                    }
                                    .padding(6)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                                }
                                
                                // Add button
                                Button(action: addNewItem) {
                                    Text("Add Item")
                                        .font(.custom("Cochin", size: 16))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(newItemName.isEmpty ? Color.gray.opacity(0.3) : Color.black)
                                        .foregroundColor(newItemName.isEmpty ? Color.gray : Color.white)
                                        .cornerRadius(8)
                                }
                                .disabled(newItemName.isEmpty)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        }

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
                            if let items = groupedIngredients[category], !items.isEmpty {
                                VStack(alignment: .leading) {
                                    Text(category)
                                        .font(.custom("Cochin", size: 22))
                                        .fontWeight(.bold)
                                        .padding(.top, 20)
                                        .padding(.horizontal)

                                    ForEach(items) { item in
                                        EditableGroceryItem(groceryManager: groceryManager, groceryItem: item)
                                            .padding(.horizontal)
                                            .padding(.vertical, 3)
                                    }
                                }
                            }
                        }
                        
                        // Empty state if no items match search
                        if groceryManager.groceryItems.filter({ item in
                            searchText.isEmpty || item.name.lowercased().contains(searchText.lowercased())
                        }).isEmpty {
                            VStack {
                                Text("No items found")
                                    .font(.custom("Cochin", size: 18))
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.top, 30)
                        }
                    }
                    .padding(.bottom, 80) // Space for bottom tab bar
                }

                BottomTabBar() // Your existing tab bar
            }
            .alert(isPresented: $showActionAlert) {
                Alert(
                    title: Text("Choose an Action"),
                    message: Text("What would you like to do with \(itemToAddToPantry?.name ?? "")?"),
                    primaryButton: .default(Text("Add to Pantry")) {
                        if let item = itemToAddToPantry {
                            addToPantry(item)
                        }
                    },
                    secondaryButton: .destructive(Text("Delete")) {
                        if let itemToDelete = itemToAddToPantry {
                            deleteGroceryItem(itemToDelete)
                        }
                    }
                )
            }
        }
        .onAppear {
            // Fetch grocery items when view appears
            groceryManager.fetchGroceryItems()
        }
    }

    // Add new item function
    private func addNewItem() {
        guard !newItemName.isEmpty else { return }
        
        // Create new grocery item
        let newItem = GroceryItem(
            id: UUID().uuidString,
            name: newItemName,
            category: newItemCategory,
            completed: false
        )
        
        // Add to grocery manager
        groceryManager.addGroceryItem(newItem)
        
        // Reset state
        newItemName = ""
        withAnimation {
            isAddingNewItem = false
        }
    }

    // Delete grocery item
    private func deleteGroceryItem(_ item: GroceryItem) {
        groceryManager.deleteGroceryItem(item)
    }

    // Add to pantry function (keep from original)
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
            id: item.id,
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

// Preview
struct GroceryView_Previews: PreviewProvider {
    static var previews: some View {
        GroceryView()
    }
}
