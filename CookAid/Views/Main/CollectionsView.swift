import SwiftUI
import Foundation

struct CollectionsView: View {
    @StateObject private var collectionsManager = CollectionsManager()
    @State private var showingAddCollectionSheet = false
    @State private var showingConfirmDeletion = false
    @State private var collectionToDelete: RecipeCollection?
    
    var body: some View {
        NavigationStack {
            VStack {
                if collectionsManager.collections.isEmpty {
                    EmptyCollectionsView(
                        showingAddCollectionSheet: $showingAddCollectionSheet
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
            }
            .navigationTitle("My Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCollectionSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCollectionSheet) {
                AddCollectionView(collectionsManager: collectionsManager)
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

struct EmptyCollectionsView: View {
    @Binding var showingAddCollectionSheet: Bool
    
    var body: some View {
        VStack {
            Image(systemName: "square.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Collections Yet")
                .font(.custom("Cochin", size: 20))
                .foregroundColor(.gray)
            
            Button(action: { showingAddCollectionSheet = true }) {
                Text("Create First Collection")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct CollectionListView: View {
    var collections: [RecipeCollection]
    var onDelete: (RecipeCollection) -> Void
    
    var body: some View {
        List {
            ForEach(collections) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(collection.name)
                            .font(.custom("Cochin", size: 20))
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("\(collection.recipes.count) Recipes")
                                .font(.custom("Cochin", size: 16))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatDate(collection.dateCreated))
                                .font(.custom("Cochin", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDelete(collection)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AddCollectionView: View {
    @ObservedObject var collectionsManager: CollectionsManager
    @State private var collectionName = ""
    @State private var collectionDescription = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Collection Details")) {
                    TextField("Collection Name", text: $collectionName)
                    
                    TextField("Description (Optional)", text: $collectionDescription)
                }
            }
            .navigationTitle("New Collection")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !collectionName.isEmpty {
                        collectionsManager.createCollection(
                            name: collectionName,
                            description: collectionDescription.isEmpty ? nil : collectionDescription
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(collectionName.isEmpty)
            )
        }
    }
}

struct CollectionDetailView: View {
    var collection: RecipeCollection
    @StateObject private var collectionsManager = CollectionsManager()
    @State private var showingConfirmDeletion = false
    @State private var recipeToDelete: CollectionRecipe?
    
    var body: some View {
        VStack {
            if collection.recipes.isEmpty {
                EmptyCollectionDetailView()
            } else {
                List {
                    ForEach(collection.recipes) { recipe in
                        NavigationLink(destination: CollectionRecipeDetailView(recipe: recipe)) {
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

struct EditCollectionView: View {
    @State private var collection: RecipeCollection
    @State private var name: String
    @State private var description: String
    @StateObject private var collectionsManager = CollectionsManager()
    @Environment(\.presentationMode) var presentationMode
    
    init(collection: RecipeCollection) {
        _collection = State(initialValue: collection)
        _name = State(initialValue: collection.name)
        _description = State(initialValue: collection.description ?? "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Collection Details")) {
                TextField("Collection Name", text: $name)
                TextField("Description (Optional)", text: $description)
            }
            
            Section {
                Button("Save Changes") {
                    collectionsManager.updateCollection(
                        collectionId: collection.id,
                        name: name,
                        description: description.isEmpty ? nil : description
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Edit Collection")
    }
}

struct CollectionRecipeDetailView: View {
    var recipe: CollectionRecipe
    
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
                
                // Recipe Tags and Dietary Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
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
                    
                    if !recipe.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    TagView(tag: tag)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.custom("Cochin", size: 20))
                        .fontWeight(.bold)
                    
                    ForEach(recipe.ingredients) { ingredient in
                        Text("\(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
                            .font(.custom("Cochin", size: 16))
                    }
                }
                .padding(.horizontal)
                
                // Instructions Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.custom("Cochin", size: 20))
                        .fontWeight(.bold)
                    
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                            .font(.custom("Cochin", size: 16))
                            .padding(.bottom, 4)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Recipe Details")
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

// Preview for Collections View
struct CollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsView()
    }
}
