import SwiftUI

struct HomeView: View {
    @State private var allPantryItems: [String] = [
        "chicken", "basil", "salt", "flour", "paprika", "kiwis", "milk", "matcha",
        "tomatoes", "olive oil", "sugar", "pepper", "sesame oil", "soda"
    ]
    
    @State private var row1Items: [String] = []
    @State private var row2Items: [String] = []
    
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var recipeAPIManager = RecipeAPIManager()

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        HeaderView()
                        
                        MyPantryView(row1Items: $row1Items, row2Items: $row2Items)
                        
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
                    .onAppear {
                        splitPantryItems()
                        recipeAPIManager.fetchRecipes(ingredients: allPantryItems)
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
}

struct HeaderView: View {
    @EnvironmentObject var viewModel: AuthViewModel // Add this line to access the viewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Safely unwrap user name
                if let user = viewModel.currentUser {
                    Text("Hi, \(user.fullname)") // Use string interpolation
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
                    NavigationLink(destination: RecipeDetailView(recipe: recipe.title)) {
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
        VStack {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .cornerRadius(8)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Text(recipe)
                .font(.custom("Cochin", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.black)

            HStack {
                Spacer()
                Button(action: {
                    // Handle 3 dots actions (add/delete/save)
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .frame(minHeight: 180)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
    }
}


struct RecipeDetailView: View {
    var recipe: String

    var body: some View {
        VStack {
            Text("Full Recipe for \(recipe)")
                .font(.largeTitle)
            Spacer()
        }
        .padding()
        .navigationTitle(recipe)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AuthViewModel()) // Provide a mock AuthViewModel for preview
    }
}

