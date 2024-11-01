import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var allPantryItems: [String] = [
        "chicken", "basil", "salt", "flour", "paprika", "kiwis", "milk", "matcha",
        "tomatoes", "olive oil", "sugar", "pepper", "sesame oil", "soda"
    ]
    
    @State private var row1Items: [String] = []
    @State private var row2Items: [String] = []
    @State private var displayedRecipes: [Recipe] = []
    @State private var isLoadingMore = false
    @State private var recipes: [Recipe] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        HeaderView()
                        MyPantryView(row1Items: $row1Items, row2Items: $row2Items)
                        RecommendedRecipesView(recipes: displayedRecipes)
                        
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    if geometry.frame(in: .global).maxY < UIScreen.main.bounds.size.height {
                                        loadMoreRecipes()
                                    }
                                }
                        }
                        .frame(height: 0)
                        Spacer()
                    }
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        splitPantryItems()
                        self.recipes = RecipeManager.shared.loadRecipes()
                        displayedRecipes = Array(recipes.prefix(8))
                    }
                    .padding(.bottom, 60)
                }
                BottomTabBar()
            }
        }
    }
    
    private func splitPantryItems() {
        let midpoint = allPantryItems.count / 2
        row1Items = Array(allPantryItems.prefix(midpoint))
        row2Items = Array(allPantryItems.suffix(from: midpoint))
    }
    
    private func loadMoreRecipes() -> [Recipe] {
        guard !isLoadingMore, displayedRecipes.count < recipes.count else { return [] }
        isLoadingMore = true
        
        let currentCount = displayedRecipes.count
        let nextCount = min(currentCount + 8, recipes.count)
        
        // Load the recipes for the next set
        let newRecipes = Array(recipes[currentCount..<nextCount])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            displayedRecipes.append(contentsOf: newRecipes)
            isLoadingMore = false
        }
        
        // Return the new recipes added
        return newRecipes
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
                        
                        Button(action: {
                            // Action for adding item
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
        var recipes: [Recipe]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Recommended Recipes")
                    .font(.custom("Cochin", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    

    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView().environmentObject(AuthViewModel())
        }
    }
}
