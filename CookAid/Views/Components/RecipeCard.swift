import SwiftUI

struct RecipeCard: View {
    var recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if let imagePath = Bundle.main.path(forResource: "Resources/Images/Food Images/\(recipe.imageName)", ofType: "jpg"),
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
            
            Text(recipe.title)
                .font(.custom("Cochin", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
            
            HStack {
                Spacer()
                Button(action: {
                    // Handle 3 dots actions
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(width: 150, height: 200)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
    }
}
