import SwiftUI
import Foundation

// Imported Recipe Preview View
struct ImportedRecipePreviewView: View {
    let recipe: ImportedRecipeDetail
    let onAddToCollection: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Recipe Title
            Text(recipe.title)
                .font(.custom("Cochin", size: 22))
                .fontWeight(.bold)
            
            // Recipe Image
            if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
            }
            
            // Recipe Details
            HStack {
                if let servings = recipe.servings {
                    HStack {
                        Image(systemName: "person.2")
                        Text("\(servings) Servings")
                    }
                }
                
                if let readyInMinutes = recipe.readyInMinutes {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(readyInMinutes) mins")
                    }
                }
            }
            .foregroundColor(.gray)
            
            // Add to Collection Button
            Button(action: onAddToCollection) {
                Text("Add to Collection")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
