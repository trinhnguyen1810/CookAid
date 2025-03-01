import SwiftUI

struct RecipeCard: View {
    var recipe: String
    var image: String
    var recipeId: Int
    
    @State private var showingAddToCollectionSheet = false
    @EnvironmentObject var collectionsManager: CollectionsManager // Changed to EnvironmentObject
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(8)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Text(recipe)
                .font(.custom("Cochin", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Spacer()
                Button(action: {
                    showingAddToCollectionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
        .sheet(isPresented: $showingAddToCollectionSheet) {
            AddToCollectionView(
                recipe: QuickRecipe(
                    id: recipeId,
                    title: recipe,
                    image: image,
                    imageType: "jpg"
                )
            )
            .environmentObject(collectionsManager)
        }
    }
    
    // Additional initializer with default recipeId
    init(recipe: String, image: String) {
        self.recipe = recipe
        self.image = image
        self.recipeId = 0 // Default value
    }
    
    // Original initializer with all parameters
    init(recipe: String, image: String, recipeId: Int) {
        self.recipe = recipe
        self.image = image
        self.recipeId = recipeId
    }
}

// Preview for RecipeCard
struct RecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCard(
            recipe: "Delicious Chocolate Cake",
            image: "https://example.com/cake-image.jpg",
            recipeId: 1234
        )
        .environmentObject(CollectionsManager()) // Add this for preview
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
