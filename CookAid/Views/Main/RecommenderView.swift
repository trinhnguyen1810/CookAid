import SwiftUI

struct RecommenderView: View {
    @State private var searchText: String = ""
    
    private let recipes: [Recipe] = [
        Recipe(title: "Spaghetti Carbonara", ingredients: "Spaghetti, Eggs, Parmesan, Bacon", instructions: "Cook spaghetti. Mix eggs and cheese. Combine.", imageName: "carbonara"),
        Recipe(title: "Chicken Alfredo", ingredients: "Fettuccine, Chicken, Cream, Parmesan", instructions: "Cook fettuccine. Cook chicken. Mix with cream and cheese.", imageName: "alfredo"),
        Recipe(title: "Vegetable Stir Fry", ingredients: "Mixed Vegetables, Soy Sauce, Garlic", instructions: "Stir fry vegetables with soy sauce and garlic.", imageName: "stir_fry"),
        Recipe(title: "Beef Tacos", ingredients: "Ground Beef, Taco Shells, Lettuce, Tomato", instructions: "Cook beef. Fill taco shells with beef and toppings.", imageName: "tacos"),
        Recipe(title: "Pancakes", ingredients: "Flour, Milk, Eggs, Baking Powder", instructions: "Mix ingredients and cook on a skillet.", imageName: "pancakes"),
        Recipe(title: "Chocolate Cake", ingredients: "Flour, Sugar, Cocoa, Eggs", instructions: "Mix ingredients and bake.", imageName: "chocolate_cake")
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                ScrollView {
                    VStack {
                        Text("Recipe Recommender")
                            .font(.custom("Cochin", size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.bottom, 15)

                        HStack {
                            TextField("Search Recipes By Ingredients", text: $searchText)
                                .padding(12)
                                .font(.custom("Cochin", size: 18))
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                        Text("Insert ingredients separated by a comma for recipe recommendations")
                            .font(.custom("Cochin", size: 14))
                            .italic()
                            .foregroundColor(Color.gray)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 15)

                        RecipesRecommendedView(recipes: recipes)
                            .padding(.bottom, 15)
                    }
                }
                BottomTabBar()
            }
        }
    }
}

struct RecipesRecommendedView: View {
    var recipes: [Recipe]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommended Recipes")
                .font(.custom("Cochin", size: 22))
                .fontWeight(.bold)
                .foregroundColor(.black)
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

struct RecommenderView_Previews: PreviewProvider {
    static var previews: some View {
        RecommenderView()
    }
}
