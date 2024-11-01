import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.largeTitle)
                    .padding(.bottom)
                
                if let imagePath = Bundle.main.path(forResource: "Resources/Images/Food Images/\(recipe.imageName).jpg", ofType: "jpg"),
                                   let uiImage = UIImage(contentsOfFile: imagePath) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                        .padding(.bottom)
                                } else {
                                    Text("Image not found")
                                        .foregroundColor(.red)
                                }
                
                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                // Directly display the ingredients string
                Text(recipe.ingredients) // No need for joined(separator:)
                    .padding(.bottom)
                
                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text(recipe.instructions)
                    .padding(.bottom)
                
                Spacer()
            }
            .padding()
            .navigationTitle(recipe.title)
        }
    }
}

