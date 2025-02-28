import SwiftUI

struct CollectionDetailView: View {
    let collection: RecipeCollection
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingConfirmDeletion = false
    @State private var recipeToDelete: CollectionRecipe?
    
    var body: some View {
        VStack {
            if collection.recipes.isEmpty {
                EmptyCollectionDetailView()
            } else {
                List {
                    ForEach(collection.recipes) { recipe in
                        NavigationLink(destination: CollectionRecipeDetailView(recipe: recipe, collectionId: collection.id)) {
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
                                
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.custom("Cochin", size: 18))
                                    
                                    if !recipe.tags.isEmpty {
                                        Text(recipe.tags.joined(separator: ", "))
                                            .font(.custom("Cochin", size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                recipeToDelete = recipe
                                showingConfirmDeletion = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .confirmationDialog(
                    "Are you sure?",
                    isPresented: $showingConfirmDeletion,
                    titleVisibility: .visible
                ) {
                    Button("Delete Recipe", role: .destructive) {
                        if let recipe = recipeToDelete {
                            collectionsManager.removeRecipeFromCollection(
                                recipeId: recipe.id,
                                collectionId: collection.id
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarItems(trailing:
            NavigationLink(destination: EditCollectionView(collection: collection)) {
                Text("Edit")
            }
        )
    }
}

struct EmptyCollectionDetailView: View {
    var body: some View {
        VStack {
            Image(systemName: "list.bullet")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Recipes in Collection")
                .font(.custom("Cochin", size: 20))
                .foregroundColor(.gray)
        }
    }
}
