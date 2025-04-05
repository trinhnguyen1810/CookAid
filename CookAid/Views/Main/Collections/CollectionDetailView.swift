import SwiftUI

struct CollectionDetailView: View {
    let collection: RecipeCollection
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingConfirmDeletion = false
    @State private var recipeToDelete: CollectionRecipe?
    @State private var refreshTrigger = UUID()
    @State private var showingImportRecipeSheet = false
    @State private var showingCreateRecipeSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collection Header
            VStack(alignment: .leading, spacing: 10) {
                Text(collection.name)
                    .font(.custom("Cochin", size: 28))
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.bottom, 4)
                
                // Description (if available)
                if let description = collection.description, !description.isEmpty {
                    Text(description)
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                
                HStack {
                    Text("\(collection.recipes.count) Recipes")
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    NavigationLink(destination: EditCollectionView(collection: collection)) {
                        Text("Edit")
                            .font(.custom("Cochin", size: 17))
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            if collection.recipes.isEmpty {
                // Empty state
                EmptyCollectionDetailView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Recipe List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(collection.recipes) { recipe in
                            RecipeRow(recipe: recipe, collectionId: collection.id)
                                .contextMenu {
                                    Button(action: {
                                        recipeToDelete = recipe
                                        showingConfirmDeletion = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            
                            // Divider after each item except the last
                            if recipe.id != collection.recipes.last?.id {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            
            // Recipe Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    showingCreateRecipeSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                        Text("Add New Recipe")
                            .font(.custom("Cochin", size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    showingImportRecipeSheet = true
                }) {
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 16))
                        Text("Import from Web")
                            .font(.custom("Cochin", size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    showingCreateRecipeSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16))
                        Text("Create Recipe")
                            .font(.custom("Cochin", size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Extra space for tab bar
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Recipe", isPresented: $showingConfirmDeletion) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let recipe = recipeToDelete {
                    collectionsManager.removeRecipeFromCollection(
                        recipeId: recipe.id,
                        collectionId: collection.id
                    )
                    recipeToDelete = nil
                    refreshTrigger = UUID()
                }
            }
        } message: {
            Text("Are you sure you want to delete this recipe from the collection?")
        }
        .sheet(isPresented: $showingImportRecipeSheet) {
            ImportRecipeView()
                .environmentObject(collectionsManager)
        }
        .sheet(isPresented: $showingCreateRecipeSheet) {
            CreateRecipeView()
                .environmentObject(collectionsManager)
        }
        .id(refreshTrigger)
        .onAppear {
            refreshTrigger = UUID()
        }
    }
}

// Empty State View
struct EmptyCollectionDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)
            
            Text("No Recipes in Collection")
                .font(.custom("Cochin", size: 22))
                .foregroundColor(.black)
            
            Text("Add recipes to see them here")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Recipe Row to match your app's list style
struct RecipeRow: View {
    var recipe: CollectionRecipe
    var collectionId: UUID
    
    var body: some View {
        NavigationLink(destination: CollectionRecipeDetailView(recipe: recipe, collectionId: collectionId)) {
            HStack(spacing: 15) {
                // Recipe Image
                Group {
                    if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "fork.knife")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Recipe Title
                    Text(recipe.title)
                        .font(.custom("Cochin", size: 20))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    // Recipe Tags or Dietary Info
                    HStack(spacing: 8) {
                        if recipe.vegetarian == true {
                            Label("Vegetarian", systemImage: "leaf.fill")
                                .font(.custom("Cochin", size: 14))
                                .foregroundColor(.green)
                        }
                        
                        if recipe.glutenFree == true {
                            Label("GF", systemImage: "g.circle")
                                .font(.custom("Cochin", size: 14))
                                .foregroundColor(.orange)
                        }
                        
                        // Show ingredient count or other info if no dietary tags
                        if recipe.vegetarian != true && recipe.glutenFree != true {
                            Text("\(recipe.ingredients.count) ingredients")
                                .font(.custom("Cochin", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.trailing, 5)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
