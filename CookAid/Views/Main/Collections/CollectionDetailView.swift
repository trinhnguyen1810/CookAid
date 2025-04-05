import SwiftUI

struct CollectionDetailView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    
    // The collection ID
    let collectionId: UUID
    
    // State for refresh control
    @State private var refreshKey = UUID()
    
    // Additional state variables
    @State private var showingConfirmDeletion = false
    @State private var recipeToDelete: CollectionRecipe?
    @State private var showingActionSheet = false
    @State private var showingImportRecipeSheet = false
    @State private var showingCreateRecipeSheet = false
    
    // Initialize with collection ID
    init(collection: RecipeCollection) {
        self.collectionId = collection.id
    }
    
    // Get the current collection from the manager
    private var collection: RecipeCollection {
        if let collection = collectionsManager.collections.first(where: { $0.id == collectionId }) {
            return collection
        }
        
        // Return an empty collection as fallback (should never happen)
        return RecipeCollection(id: collectionId, name: "Not found", recipes: [])
    }
    
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
                    
                    NavigationLink(destination:
                        EditCollectionView(collection: collection, onSave: {
                            // Force refresh when returning from edit
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                refreshKey = UUID()
                            }
                        })
                    ) {
                        Text("Edit")
                            .font(.custom("Cochin", size: 17))
                    }
                    
                    // Single + button that shows action sheet
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                            .padding(.leading, 8)
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
                List {
                    ForEach(collection.recipes) { recipe in
                        // IMPORTANT: Use HStack directly instead of NavigationLink
                        HStack {
                            // Use the modified recipe row without the navigation link
                            RecipeRowContent(recipe: recipe)
                            
                            // Only add one navigation arrow manually
                            NavigationLink(destination:
                                CollectionRecipeDetailView(recipe: recipe, collectionId: collectionId)
                                    .onDisappear {
                                        // Force refresh when returning from recipe detail
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            refreshKey = UUID()
                                        }
                                    }
                            ) {
                                EmptyView()
                            }
                            .opacity(0)
                            .frame(width: 0)
                        }
                        .swipeActions {
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
            }
        }
        .id(refreshKey) // This forces the view to completely rebuild when key changes
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Select an option", isPresented: $showingActionSheet) {
            Button("Create New Recipe") {
                showingCreateRecipeSheet = true
            }
            
            Button("Import Recipe from Web") {
                showingImportRecipeSheet = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete Recipe", isPresented: $showingConfirmDeletion) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let recipe = recipeToDelete {
                    deleteRecipe(recipe)
                }
            }
        } message: {
            Text("Are you sure you want to delete this recipe from the collection?")
        }
        .sheet(isPresented: $showingImportRecipeSheet, onDismiss: {
            // Force refresh when sheet is dismissed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refreshKey = UUID()
            }
        }) {
            ImportRecipeView()
                .environmentObject(collectionsManager)
        }
        .sheet(isPresented: $showingCreateRecipeSheet, onDismiss: {
            // Force refresh when sheet is dismissed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refreshKey = UUID()
            }
        }) {
            CreateRecipeView()
                .environmentObject(collectionsManager)
        }
        .onAppear {
            // Force refresh when view appears
            refreshKey = UUID()
        }
    }
    
    // Delete recipe with full UI refresh
    private func deleteRecipe(_ recipe: CollectionRecipe) {
        // Delete from the manager
        collectionsManager.removeRecipeFromCollection(
            recipeId: recipe.id,
            collectionId: collectionId
        )
        
        // Force UI refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            refreshKey = UUID()
        }
    }
}

// Empty State View (unchanged)
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

// NEW: Content-only row (no navigation)
struct RecipeRowContent: View {
    var recipe: CollectionRecipe
    
    var body: some View {
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
            // No chevron - will be added by the NavigationLink
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20) // Restored proper padding
    }
}

// Keep this for compatibility with other views
struct RecipeRow: View {
    var recipe: CollectionRecipe
    var collectionId: UUID
    
    var body: some View {
        NavigationLink(destination: CollectionRecipeDetailView(recipe: recipe, collectionId: collectionId)) {
            RecipeRowContent(recipe: recipe)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
