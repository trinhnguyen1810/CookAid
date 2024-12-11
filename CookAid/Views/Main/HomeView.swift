import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var ingredientsManager: IngredientsManager
    @StateObject private var recipeAPIManager = RecipeAPIManager()
    @State private var showingAddIngredientView = false
    
    @State private var row1Items: [String] = []
    @State private var row2Items: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        HeaderView()
                        
                        // Pass the state variable to MyPantryView
                        MyPantryView(row1Items: $row1Items, row2Items: $row2Items, showingAddIngredientView: $showingAddIngredientView)
                        
                        if let errorMessage = recipeAPIManager.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            RecommendedRecipesView(recipes: recipeAPIManager.recipes)
                        }
                        
                        Spacer()
                    }
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .task {
                        await ingredientsManager.fetchIngredients()
                        splitPantryItems()
                        await recipeAPIManager.fetchRecipes(ingredients: ingredientsManager.ingredients.map { $0.name })
                    }
                    .onChange(of: ingredientsManager.ingredients.count) { _ in
                        splitPantryItems()
                        Task {
                            await recipeAPIManager.fetchRecipes(ingredients: ingredientsManager.ingredients.map { $0.name })
                        }
                    }
                    .padding(.bottom, 60)
                }
                BottomTabBar()
            }
        }
        .sheet(isPresented: $showingAddIngredientView) { // Corrected this line
            AddIngredientView(ingredients: $ingredientsManager.ingredients) // Present the AddIngredientView
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
    @Binding var showingAddIngredientView: Bool // Add this line
    
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
                        RecipeCard(recipe: recipe.title, image: recipe.image) // Pass the image to the RecipeCard
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct RecipeCard: View {
    var recipe: String
    var image: String

    var body: some View {
        VStack(alignment: .leading) {  // Changed to .leading alignment
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)  // Increased height from 100
                    .cornerRadius(8)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)  // Increased height from 100
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Text(recipe)
                .font(.custom("Cochin", size: 18))  // Increased from 15
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(height: 50)  // Fixed height for text area
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Spacer()
                Button(action: {
                    // Handle 3 dots actions (add/delete/save)
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 4)  // Reduced from 8 to accommodate larger text area
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .frame(height: 220)  // Fixed total height
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AuthViewModel())
            .environmentObject(IngredientsManager(recipeAPIManager: RecipeAPIManager())) // Provide a mock AuthViewModel for preview
    }
}
