import SwiftUI

struct MealItemView: View {
    let meal: MealItem
    let date: Date
    let mealType: MealType
    @EnvironmentObject var mealPlanManager: MealPlanManager
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingDeleteConfirmation = false
    @State private var showingRecipeDetail = false
    
    var body: some View {
        HStack {
            // Meal image
            if let imageUrl = meal.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "fork.knife")
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            
            // Meal title
            Text(meal.title)
                .font(.custom("Cochin", size: 16))
                .lineLimit(1)
            
            Spacer()
            
            // Delete button
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingRecipeDetail = true
        }
        .confirmationDialog(
            "Remove from meal plan?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                mealPlanManager.removeRecipe(id: meal.id, date: date, mealType: mealType)
            }
        }
        .background(
            NavigationLink(destination: findRecipeDetailView(), isActive: $showingRecipeDetail) {
                EmptyView()
            }
        )
    }
    
    // Find the corresponding recipe detail view by ID
    private func findRecipeDetailView() -> some View {
        // Find the corresponding recipe in collections
        let recipe = findRecipeInCollections()
        
        if let recipe = recipe {
            return AnyView(CollectionRecipeDetailView(recipe: recipe, collectionId: recipe.collectionId))
        } else if let recipeId = Int(meal.recipeId.uuidString.prefix(8), radix: 16) {
            // Fallback to API recipe detail using the numeric ID if available
            return AnyView(RecipeDetailView(recipeId: recipeId))
        } else {
            // Generic error view if recipe cannot be found
            return AnyView(
                VStack {
                    Text("Recipe not found")
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                }
            )
        }
    }
    
    // Helper to find recipe in collections
    private func findRecipeInCollections() -> RecipeCollections.Recipe? {
        for collection in collectionsManager.collections {
            if let recipe = collection.recipes.first(where: { $0.id == meal.recipeId }) {
                return recipe
            }
        }
        return nil
    }
}
