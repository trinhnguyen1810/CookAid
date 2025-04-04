import SwiftUI
// Type aliases to make the code cleaner
typealias RecipeCollection = RecipeCollections.Collection
typealias CollectionRecipe = RecipeCollections.Recipe

struct CollectionsView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingAddCollectionSheet = false
    @State private var showingImportRecipeSheet = false
    @State private var showingCreateRecipeSheet = false
    @State private var showingConfirmDeletion = false
    @State private var collectionToDelete: RecipeCollection?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Title and Add Button
                    HStack {
                        Text("My Collections")
                            .font(.custom("Cochin", size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: { showingAddCollectionSheet = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    // Collections List or Empty State
                    if collectionsManager.collections.isEmpty {
                        EmptyCollectionsView(
                            showingAddCollectionSheet: $showingAddCollectionSheet,
                            showingImportRecipeSheet: $showingImportRecipeSheet,
                            showingCreateRecipeSheet: $showingCreateRecipeSheet
                        )
                    } else {
                        CollectionListView(
                            collections: collectionsManager.collections,
                            onDelete: { collection in
                                collectionToDelete = collection
                                showingConfirmDeletion = true
                            }
                        )
                    }
                    
                    // Recipe Creation Options
                    if !collectionsManager.collections.isEmpty {
                        RecipeCreationOptionsView(
                            showingImportRecipeSheet: $showingImportRecipeSheet,
                            showingCreateRecipeSheet: $showingCreateRecipeSheet
                        )
                        .padding()
                    }
                    
                    // Spacer to push content up
                    Spacer()
                }
                
                // Bottom Tab Bar
                VStack {
                    Spacer()
                    BottomTabBar()
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showingAddCollectionSheet) {
                AddCollectionView()
                    .environmentObject(collectionsManager)
            }
            .sheet(isPresented: $showingImportRecipeSheet) {
                ImportRecipeView()
                    .environmentObject(collectionsManager)
            }
            .sheet(isPresented: $showingCreateRecipeSheet) {
                CreateRecipeView()
                    .environmentObject(collectionsManager)
            }
            .confirmationDialog(
                "Are you sure you want to delete this collection?",
                isPresented: $showingConfirmDeletion,
                titleVisibility: .visible
            ) {
                Button("Delete Collection", role: .destructive) {
                    if let collection = collectionToDelete {
                        collectionsManager.deleteCollection(collectionId: collection.id)
                        collectionToDelete = nil
                    }
                }
            }
        }
    }
}

// Empty Collections View
struct EmptyCollectionsView: View {
    @Binding var showingAddCollectionSheet: Bool
    @Binding var showingImportRecipeSheet: Bool
    @Binding var showingCreateRecipeSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.custom("Cochin", size: 24))
                .foregroundColor(.gray)
            
            Text("Create a collection to organize your recipes")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddCollectionSheet = true }) {
                Text("Create First Collection")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Divider()
                .padding(.vertical)
            
            Text("Or add recipes directly")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                Button(action: { showingImportRecipeSheet = true }) {
                    VStack {
                        Image(systemName: "link")
                            .font(.system(size: 24))
                        Text("Import from Web")
                            .font(.custom("Cochin", size: 16))
                    }
                    .frame(width: 140, height: 100)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                
                Button(action: { showingCreateRecipeSheet = true }) {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24))
                        Text("Create Recipe")
                            .font(.custom("Cochin", size: 16))
                    }
                    .frame(width: 140, height: 100)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}


struct RecipeCreationOptionsView: View {
    @State private var showOptions = false
    @Binding var showingImportRecipeSheet: Bool
    @Binding var showingCreateRecipeSheet: Bool

    var body: some View {
        VStack(spacing: 10) {
            // Main Button (Wider, Shorter)
            Button(action: {
                withAnimation {
                    showOptions.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                    Text("Add New Recipe")
                        .font(.custom("Cochin", size: 16))
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(10)
                .frame(width: 260, height: 45) // Wider, Shorter
                .background(Color.black)
                .cornerRadius(10)
            }

            // Options (Wider, Shorter)
            if showOptions {
                VStack(spacing: 8) {
                    RecipeOptionButton(
                        title: "Import from Web",
                        icon: "link",
                        color: .blue
                    ) {
                        showingImportRecipeSheet = true
                    }

                    RecipeOptionButton(
                        title: "Create Recipe",
                        icon: "square.and.pencil",
                        color: .green
                    ) {
                        showingCreateRecipeSheet = true
                    }
                }
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .top))) // Smooth animation
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(radius: 5)
        .padding(8)
    }
}

// Reusable button (Wider, Shorter)
struct RecipeOptionButton: View {
    var title: String
    var icon: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(.custom("Cochin", size: 16))
                    .foregroundColor(color)
            }
            .padding(8)
            .frame(width: 240, height: 40) // Wider, Shorter
            .background(color.opacity(0.1))
            .cornerRadius(8)
            .shadow(color: color.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }
}
