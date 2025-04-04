import SwiftUI

struct CollectionRecipeDetailView: View {
    var recipe: CollectionRecipe
    var collectionId: UUID
    @StateObject private var groceryManager = GroceryManager()
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingEditSheet = false
    @State private var isShowingFullRecipe = false
    @State private var selectedIngredient: RecipeIngredient? = nil
    @State private var showCategorySelection = false
    @State private var showingAddAllConfirmation = false
    @State private var addedMessage = ""
    @State private var showingAlert = false
    
    // Add refresh trigger
    @State private var refreshKey = UUID()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(recipe.title)
                    .font(.custom("Cochin", size: 22))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Image
                if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.horizontal)
                }
                
                // Edit button for editable recipes
                if recipe.source == .imported || recipe.source == .custom {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Recipe")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                // Recipe source indicator
                HStack {
                    Text("Source: ")
                        .font(.custom("Cochin", size: 16))
                        .foregroundColor(.gray)
                    
                    Text(sourceTypeString(recipe.source))
                        .font(.custom("Cochin", size: 16))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                // Tags
                if !recipe.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(recipe.tags, id: \.self) { tag in
                                TagView(tag: tag)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Dietary indicators
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if recipe.vegetarian == true {
                            TagView(tag: "Vegetarian")
                        }
                        if recipe.vegan == true {
                            TagView(tag: "Vegan")
                        }
                        if recipe.glutenFree == true {
                            TagView(tag: "Gluten Free")
                        }
                        if recipe.dairyFree == true {
                            TagView(tag: "Dairy Free")
                        }
                    }
                    .padding(.horizontal)
                }
                
                // For API recipes with missing data, show a button to view complete details
                if recipe.source == .apiRecipe && recipe.originalRecipeId != nil &&
                   (recipe.ingredients.isEmpty || recipe.instructions.isEmpty) {
                    
                    VStack(spacing: 20) {
                        Text("This recipe has full details available")
                            .font(.custom("Cochin", size: 18))
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            isShowingFullRecipe = true
                        }) {
                            HStack {
                                Image(systemName: "eye")
                                Text("View Complete Recipe")
                            }
                            .font(.custom("Cochin", size: 17))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    
                } else {
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Ingredients")
                                .font(.custom("Cochin", size: 20))
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("(Tap to add to grocery list)")
                                .font(.custom("Cochin", size: 14))
                                .foregroundColor(.gray)
                                .italic()
                        }
                        
                        if recipe.ingredients.isEmpty {
                            Text("No ingredients available.")
                                .font(.custom("Cochin", size: 16))
                                .foregroundColor(.gray)
                        } else {
                            ForEach(recipe.ingredients, id: \.id) { ingredient in
                                HStack {
                                    Text("\(formatNumber(ingredient.amount)) \(ingredient.unit) \(ingredient.name)")
                                        .font(.custom("Cochin", size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Button {
                                        // Make sure we set the ingredient first and wait for the state to update
                                        // before showing the sheet
                                        selectedIngredient = ingredient
                                        
                                        // Use a slightly longer delay to ensure state is fully updated
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            // Double check that the ingredient is still set before showing sheet
                                            if selectedIngredient != nil {
                                                showCategorySelection = true
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "cart.badge.plus")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.1))
                                        .padding(-2)
                                )
                            }
                            
                            // Add "Add All to Grocery List" button
                            Button(action: {
                                showingAddAllConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "cart.fill.badge.plus")
                                    Text("Add All to Grocery List")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            }
                            .padding(.top, 12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.custom("Cochin", size: 20))
                            .fontWeight(.bold)
                        
                        if recipe.instructions.isEmpty {
                            Text("No instructions available.")
                                .font(.custom("Cochin", size: 16))
                                .foregroundColor(.gray)
                        } else {
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                Text("\(index + 1). \(step)")
                                    .font(.custom("Cochin", size: 16))
                                    .padding(.bottom, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .id(refreshKey) // This forces the view to completely rebuild when key changes
        }
        .navigationTitle("Recipe Details")
        .sheet(isPresented: $showingEditSheet, onDismiss: {
            // Force refresh when editing is done
            refreshKey = UUID()
            
            // Get the updated recipe from the manager
            if let updatedCollection = collectionsManager.getCollection(by: collectionId),
               let updatedRecipe = updatedCollection.recipes.first(where: { $0.id == recipe.id }) {
                // This is a hack to update the recipe variable since it's not @State
                // We're forcing the entire view to refresh with the refreshKey
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Set this to trigger a UI update
                    refreshKey = UUID()
                }
            }
        }) {
            // Pass a refresh callback to EditRecipeView
            EditRecipeView(
                recipe: recipe,
                collectionId: collectionId,
                onSave: {
                    // Trigger UI refresh when save happens
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        refreshKey = UUID()
                    }
                }
            )
            .environmentObject(collectionsManager)
        }
        .sheet(isPresented: $showCategorySelection, onDismiss: {
            // Reset the selectedIngredient when sheet is dismissed
            selectedIngredient = nil
        }) {
            // Only show the sheet if selectedIngredient is not nil
            // This is a critical guard that prevents a blank sheet
            if let ingredient = selectedIngredient {
                NavigationView {
                    CategorySelectionView(
                        ingredient: ingredient,
                        groceryManager: groceryManager,
                        onAdd: {
                            // Directly set showCategorySelection to false to dismiss the sheet
                            showCategorySelection = false
                        }
                    )
                    .navigationBarItems(trailing: Button("Done") {
                        showCategorySelection = false
                    })
                }
            } else {
                // This is a fallback in case selectedIngredient is nil somehow
                // It will automatically dismiss the sheet
                Color.clear.onAppear {
                    print("ERROR: Tried to show category selection with nil ingredient")
                    DispatchQueue.main.async {
                        showCategorySelection = false
                    }
                }
            }
        }
        .background(
            NavigationLink(
                destination: recipe.originalRecipeId != nil ? RecipeDetailView(recipeId: recipe.originalRecipeId!) : nil,
                isActive: $isShowingFullRecipe
            ) {
                EmptyView()
            }
        )
        .confirmationDialog(
            "Add all ingredients to grocery list?",
            isPresented: $showingAddAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Add All") {
                addAllIngredientsToGrocery()
            }
        }
        .alert(addedMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            // Force refresh when view appears
            refreshKey = UUID()
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        return number.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", number) : String(format: "%.2f", number)
    }
    
    private func sourceTypeString(_ source: RecipeSource) -> String {
        switch source {
        case .apiRecipe:
            return "Spoonacular API Recipe (View Only)"
        case .imported:
            return "Imported Recipe"
        case .custom:
            return "Custom Recipe"
        }
    }
    
    private func addAllIngredientsToGrocery() {
        // Count of successfully added ingredients
        var addedCount = 0
        var skippedCount = 0
        
        // Loop through all ingredients
        for ingredient in recipe.ingredients {
            // Format the ingredient string
            let groceryItemName = "\(ingredient.name) - \(formatNumber(ingredient.amount)) \(ingredient.unit)"
            
            // Check if this ingredient is already in the grocery list to avoid duplicates
            let isDuplicate = groceryManager.groceryItems.contains { item in
                item.name.lowercased() == groceryItemName.lowercased()
            }
            
            // Only add if it's not a duplicate
            if !isDuplicate {
                // Create a new grocery item
                // Using IngredientCategorizer instead of the custom function
                let groceryItem = GroceryItem(
                    id: UUID().uuidString,
                    name: groceryItemName,
                    category: IngredientCategorizer.categorize(ingredient.name),
                    completed: false
                )
                
                // Add to grocery list
                groceryManager.addGroceryItem(groceryItem)
                addedCount += 1
            } else {
                skippedCount += 1
            }
        }
        
        // Show success message
        if skippedCount > 0 {
            addedMessage = "Added \(addedCount) ingredients to your grocery list! (Skipped \(skippedCount) duplicates)"
        } else {
            addedMessage = "Added \(addedCount) ingredients to your grocery list!"
        }
        showingAlert = true
    }
}

struct TagView: View {
    var tag: String
    
    var body: some View {
        Text(tag)
            .font(.custom("Cochin", size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}
