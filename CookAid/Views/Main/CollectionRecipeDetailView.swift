import SwiftUI

struct CollectionRecipeDetailView: View {
    var recipe: CollectionRecipe
    var collectionId: UUID
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingEditSheet = false
    
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
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.custom("Cochin", size: 20))
                        .fontWeight(.bold)
                    
                    if recipe.ingredients.isEmpty {
                        Text("No ingredients available.")
                            .font(.custom("Cochin", size: 16))
                            .foregroundColor(.gray)
                    } else {
                        ForEach(recipe.ingredients, id: \.id) { ingredient in
                            Text("\(formatNumber(ingredient.amount)) \(ingredient.unit) \(ingredient.name)")
                                .font(.custom("Cochin", size: 16))
                        }
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
            .padding(.vertical)
        }
        .navigationTitle("Recipe Details")
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(
                collectionsManager: collectionsManager,
                recipe: recipe,
                collectionId: collectionId
            )
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        return number.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", number) : String(format: "%.2f", number)
    }
    
    private func sourceTypeString(_ source: RecipeSource) -> String {
        switch source {
        case .apiRecipe:
            return "API Recipe (View Only)"
        case .imported:
            return "Imported Recipe"
        case .custom:
            return "Custom Recipe"
        }
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
