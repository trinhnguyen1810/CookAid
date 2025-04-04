import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var ingredientsManager: IngredientsManager
    @StateObject private var recipeAPIManager = RecipeAPIManager()
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingAddIngredientView = false
    @State private var selectedDiets: [String] = []
    @State private var selectedIntolerances: [String] = []
    @State private var showDietFilter = false
    
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
                        
                        // Filter Buttons
                        FilterButtonsView(
                            showDietFilter: $showDietFilter,
                            dietCount: selectedDiets.count,
                            intoleranceCount: selectedIntolerances.count
                        )
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Filter Chips View
                        if !selectedDiets.isEmpty || !selectedIntolerances.isEmpty {
                            FilterChipsView(
                                diets: selectedDiets,
                                intolerances: selectedIntolerances,
                                onRemoveDiet: { diet in
                                    selectedDiets.removeAll { $0 == diet }
                                    Task { await loadData() }
                                },
                                onRemoveIntolerance: { intolerance in
                                    selectedIntolerances.removeAll { $0 == intolerance }
                                    Task { await loadData() }
                                },
                                onClearAll: {
                                    selectedDiets.removeAll()
                                    selectedIntolerances.removeAll()
                                    Task { await loadData() }
                                }
                            )
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Pantry View
                        MyPantryView(
                            row1Items: $row1Items,
                            row2Items: $row2Items,
                            showingAddIngredientView: $showingAddIngredientView
                        )
                        
                        // Content based on loading state
                        switch recipeAPIManager.loadingState {
                        case .idle, .success:
                            if isSearching {
                                searchResultsView
                            } else {
                                defaultContentView
                            }
                        case .loading:
                            LoadingView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        case .error(let message):
                            ErrorMessageView(message: message) {
                                // Retry action
                                Task { await loadData() }
                            }
                        }
                    }
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .task {
                        await loadData()
                    }
                    .onChange(of: ingredientsManager.ingredients.count) { _ in
                        Task { await loadData() }
                    }
                    .onChange(of: selectedDiets) { _ in
                        Task { await loadData() }
                    }
                    .onChange(of: selectedIntolerances) { _ in
                        Task { await loadData() }
                    }
                    .padding(.bottom, 60)
                }
                
                BottomTabBar()
            }
        }
        .sheet(isPresented: $showingAddIngredientView) {
            AddIngredientView(ingredients: $ingredientsManager.ingredients)
        }
        .sheet(isPresented: $showDietFilter) {
            DietFilterView(
                selectedDiets: $selectedDiets,
                selectedIntolerances: $selectedIntolerances
            )
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
                        recipeAPIManager.searchRecipes(
                            query: newValue,
                            diets: selectedDiets.map { formatForAPI($0) },
                            intolerances: selectedIntolerances.map { formatForAPI($0) }
                        )
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
            
            switch recipeAPIManager.loadingState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            case .error(let message):
                Text(message)
                    .foregroundColor(.red)
                    .padding(.leading, 20)
            default:
                if recipeAPIManager.searchResults.isEmpty {
                    Text("No recipes found")
                        .foregroundColor(.gray)
                        .padding(.leading, 20)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(recipeAPIManager.searchResults) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                                RecipeCard(recipe: recipe.title, image: recipe.image, recipeId: recipe.id)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // Default Home Content View
    private var defaultContentView: some View {
        VStack {
            if ingredientsManager.ingredients.isEmpty {
                // Show a message when no ingredients are in the pantry
                VStack {
                    Text("Add Ingredients to Get Recipe Recommendations")
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { showingAddIngredientView = true }) {
                        Text("Add Ingredients")
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                switch recipeAPIManager.loadingState {
                case .loading:
                    LoadingView()
                case .error(let message):
                    VStack {
                        RecommendedRecipesView(recipes: [])
                        QuickRecipesView(quickrecipes: [])
                        ErrorMessageView(message: message) {
                            Task { await loadData() }
                        }
                    }
                case .idle, .success:
                    RecommendedRecipesView(recipes: recipeAPIManager.recipes)
                    QuickRecipesView(quickrecipes: recipeAPIManager.quickrecipes)
                }
            }
        }
    }
    
    private func loadData() async {
        await ingredientsManager.fetchIngredients()
        splitPantryItems()
        
        // Only load these if not searching and there are ingredients
        if !isSearching && !ingredientsManager.ingredients.isEmpty {
            recipeAPIManager.fetchRecipes(
                ingredients: ingredientsManager.ingredients.map { $0.name },
                diets: selectedDiets.map { formatForAPI($0) },
                intolerances: selectedIntolerances.map { formatForAPI($0) }
            )
            
            recipeAPIManager.fetchQuickMeals(
                ingredients: ingredientsManager.ingredients.map { $0.name },
                diets: selectedDiets.map { formatForAPI($0) },
                intolerances: selectedIntolerances.map { formatForAPI($0) }
            )
        }
    }
    

    
    private func formatForAPI(_ string: String) -> String {
        // Convert "Gluten Free" to "gluten-free" for API
        return string.lowercased().replacingOccurrences(of: " ", with: "-")
    }
    
    private func splitPantryItems() {
        let midpoint = ingredientsManager.ingredients.count / 2
        row1Items = ingredientsManager.ingredients.prefix(midpoint).map { $0.name }
        row2Items = ingredientsManager.ingredients.suffix(from: midpoint).map { $0.name }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(IngredientsManager(recipeAPIManager: RecipeAPIManager()))
    }
}

// Existing subviews from the previous implementation
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

                Button(action: {
                    showingAddIngredientView = true
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
    var recipes: [Recipe]

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
                        RecipeCard(recipe: recipe.title, image: recipe.image, recipeId: recipe.id)
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Meals")
                .font(.custom("Cochin", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.horizontal, 20)
            
            if quickrecipes.isEmpty {
                HStack {
                    Text("No quick meals available")
                        .font(.custom("Cochin", size: 18))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(quickrecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                            RecipeCard(recipe: recipe.title, image: recipe.image, recipeId: recipe.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
