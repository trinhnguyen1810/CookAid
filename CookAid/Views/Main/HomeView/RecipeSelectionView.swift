import SwiftUI

struct RecipeSelectionView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    var date: Date
    var mealType: MealType
    @EnvironmentObject var mealPlanManager: MealPlanManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(collectionsManager.collections) { collection in
                    Section(header: Text(collection.name)) {
                        ForEach(collection.recipes) { recipe in
                            Button(action: {
                                // Add recipe to meal plan
                                mealPlanManager.addRecipe(
                                    recipeId: recipe.id,
                                    title: recipe.title,
                                    image: recipe.image,
                                    date: date,
                                    mealType: mealType
                                )
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(recipe.title)
                                        .font(.custom("Cochin", size: 16))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add \(mealType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
