import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var ingredientsManager: IngredientsManager
    @StateObject private var recipeAPIManager = RecipeAPIManager()
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingAddIngredientView = false
    
    @State private var row1Items: [String] = []
    @State private var row2Items: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with User Info
                        HeaderView()
                        
                        // Search Bar
                        searchBarView
                        
                        // Pantry View
                        MyPantryView(
                            row1Items: $row1Items,
                            row2Items: $row2Items,
                            showingAddIngredientView: $showingAddIngredientView
                        )
                        
                        // Conditional Content
                        if isSearching {
                            searchResultsView
                        } else {
                            defaultContentView
                        }
                    }
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .task {
                        await loadData()
                    }
                    .onChange(of: ingredientsManager.ingredients.count) { _ in
                        Task {
                            await loadData()
                        }
                    }
                    .padding(.bottom, 60)
                }
                
                BottomTabBar()
            }
        }
        .sheet(isPresented: $showingAddIngredientView) {
            AddIngredientView(ingredients: $ingredientsManager.ingredients)
        }
    }
    
    // Search Bar View
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            TextField("Search recipes", text: $searchText)
                .font(.custom("Cochin", size: 17))
                .onChange(of: searchText) { newValue in
                    if newValue.count >= 3 {
                        isSearching = true
                        recipeAPIManager.searchRecipes(query: newValue)
                    } else {
                        isSearching = false
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // Search Results View
    private var searchResultsView: some View {
        VStack(alignment: .leading) {
            Text("Search Results")
                .font(.custom("Cochin", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.leading, 20)
            
            if recipeAPIManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if recipeAPIManager.searchResults.isEmpty {
                Text("No recipes found")
                    .foregroundColor(.gray)
                    .padding(.leading, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(recipeAPIManager.searchResults) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                            RecipeCard(recipe: recipe.title, image: recipe.image)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // Default Home Content View
    private var defaultContentView: some View {
        VStack {
            if let errorMessage = recipeAPIManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                RecommendedRecipesView(recipes: recipeAPIManager.recipes)
                QuickRecipesView(quickrecipes: recipeAPIManager.quickrecipes)
            }
        }
    }
    
    private func loadData() async {
        await ingredientsManager.fetchIngredients()
        splitPantryItems()
        
        // Only load these if not searching
        if !isSearching {
            await recipeAPIManager.fetchRecipes(ingredients: ingredientsManager.ingredients.map { $0.name })
            await recipeAPIManager.fetchQuickMeals(ingredients: ingredientsManager.ingredients.map { $0.name })
        }
    }
    
    private func splitPantryItems() {
        let midpoint = ingredientsManager.ingredients.count / 2
        row1Items = ingredientsManager.ingredients.prefix(midpoint).map { $0.name }
        row2Items = ingredientsManager.ingredients.suffix(from: midpoint).map { $0.name }
    }
}

struct HeaderView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let user = viewModel.currentUser {
                    Text("Hi, \(user.fullname)")
                        .font(.custom("Cochin", size: 25))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                Text("Turn ingredients into delicious possibilities!")
                    .font(.custom("Cochin", size: 18))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing)

            Spacer()
        }
        .padding(.bottom, 10)
    }
}

struct MyPantryView: View {
    @Binding var row1Items: [String]
    @Binding var row2Items: [String]
    @Binding var showingAddIngredientView: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Pantry")
                    .font(.custom("Cochin", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()

                HStack(spacing: 10) {
                    Button(action: {
                        // Action for camera
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.black)
                        .cornerRadius(8)
                    }

                    // Plus Button to add ingredient
                    Button(action: {
                        showingAddIngredientView = true // Show the AddIngredientView
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                }
                .padding(.trailing, 5)
                .padding(.top, 10)
            }
            .padding(.horizontal)
            .padding(.leading, 5)
            .padding(.top, 10)

            PantryItemsRow(items: row1Items)
            PantryItemsRow(items: row2Items)
        }
    }
}

struct PantryItemsRow: View {
    var items: [String]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.custom("Cochin", size: 17))
                        .padding(8)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.leading, 9)
        }
    }
}

struct RecommendedRecipesView: View {
    var recipes: [Recipe] // Accept recipes as a parameter

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recipes Based On Ingredients")
                .font(.custom("Cochin", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.leading, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                        RecipeCard(recipe: recipe.title, image: recipe.image)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct QuickRecipesView: View {
    var quickrecipes: [QuickRecipe]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Meals")
                .font(.custom("Cochin", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.leading, 20)
            
            if quickrecipes.isEmpty {
                Text("No quick meals available.")
                    .foregroundColor(.gray)
                    .padding(.leading, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(quickrecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                            RecipeCard(recipe: recipe.title, image: recipe.image)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AuthViewModel())
            .environmentObject(IngredientsManager(recipeAPIManager: RecipeAPIManager())) // Provide a mock AuthViewModel for preview
    }
}
