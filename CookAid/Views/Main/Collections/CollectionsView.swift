import SwiftUI

typealias RecipeCollection = RecipeCollections.Collection
typealias CollectionRecipe = RecipeCollections.Recipe

struct CollectionsView: View {
    @EnvironmentObject var collectionsManager: CollectionsManager
    @State private var showingAddCollectionSheet = false
    @State private var showingConfirmDeletion = false
    @State private var collectionToDelete: RecipeCollection?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Title Header with Add Button
                    HStack {
                        Text("My Collections")
                            .font(.custom("Cochin", size: 28))
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddCollectionSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Collections List or Empty State
                    if collectionsManager.collections.isEmpty {
                        EmptyCollectionsView(
                            showingAddCollectionSheet: $showingAddCollectionSheet
                        )
                    } else {
                        // Collections List
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(collectionsManager.collections) { collection in
                                    CollectionRow(collection: collection)
                                        .contextMenu {
                                            Button(action: {
                                                collectionToDelete = collection
                                                showingConfirmDeletion = true
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                collectionToDelete = collection
                                                showingConfirmDeletion = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    
                                    Divider()
                                        .padding(.horizontal, 20)
                                }
                                
                                // Add padding at the bottom for tab bar
                                Spacer().frame(height: 80)
                            }
                        }
                    }
                }
                
                // Bottom Tab Bar
                VStack {
                    Spacer()
                    BottomTabBar()
                }
            }
            .sheet(isPresented: $showingAddCollectionSheet) {
                AddCollectionView()
                    .environmentObject(collectionsManager)
            }
            .alert("Delete Collection", isPresented: $showingConfirmDeletion) {
                Button("Cancel", role: .cancel) {
                    collectionToDelete = nil // Reset state if canceled
                }
                Button("Delete", role: .destructive) {
                    deleteCollection()
                }
            } message: {
                Text("Are you sure you want to delete this collection? This action cannot be undone.")
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    // Function to delete the selected collection
    private func deleteCollection() {
        if let collection = collectionToDelete {
            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Delete the collection
            collectionsManager.deleteCollection(collectionId: collection.id)
            
            // Reset the state
            collectionToDelete = nil
            
            // Note: We don't need to manually update the UI since collectionsManager
            // is an observed object and will trigger UI updates automatically
        }
    }
}

// Collection Row Component
struct CollectionRow: View {
    var collection: RecipeCollection
    
    // Format date
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: collection.dateCreated)
    }
    
    var body: some View {
        NavigationLink(destination: CollectionDetailView(collection: collection)) {
            VStack(alignment: .leading, spacing: 8) {
                // Collection Name
                Text(collection.name)
                    .font(.custom("Cochin", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // Recipe Count and Date
                HStack {
                    Text("\(collection.recipes.count) Recipes")
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.custom("Cochin", size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Empty Collections View
struct EmptyCollectionsView: View {
    @Binding var showingAddCollectionSheet: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.custom("Cochin", size: 24))
                .foregroundColor(.black)
            
            Text("Create a collection to organize your recipes")
                .font(.custom("Cochin", size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddCollectionSheet = true }) {
                Text("Create First Collection")
                    .font(.custom("Cochin", size: 18))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
            
            Spacer()
            Spacer().frame(height: 80) // Space for tab bar
        }
        .padding()
    }
}
