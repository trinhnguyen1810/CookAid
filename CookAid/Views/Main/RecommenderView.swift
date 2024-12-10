import SwiftUI

struct RecommenderView: View {
    @State private var searchText: String = "" // State for the search bar

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                ScrollView {
                    VStack {
                        // Header
                        Text("Recipe Recommender")
                            .font(.custom("Cochin", size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.bottom,15)

                        // Search Bar
                        HStack {
                            TextField("Search Recipes By Ingredients", text: $searchText)
                                .padding(12)
                                .font(.custom("Cochin", size: 18))
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        .padding(.bottom,10)

                        // Disclaimer
                        Text("Insert ingredients separated by a comma for recipe recommendations")
                            .font(.custom("Cochin", size: 14))
                            .italic()
                            .foregroundColor(Color.gray)
                            .padding(.horizontal, 20)
                            .padding(.bottom,15)

                        // Recommended Recipes Section
                        RecipesRecommendedView()
                        .padding(.bottom,15)
                    }
                }
                BottomTabBar()
            }
        }
    }
}

// RecommendedRecipesView
struct RecipesRecommendedView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommended Recipes")
                .font(.custom("Cochin", size: 22))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 20)

        }
    }
}


// Preview
struct RecommenderView_Previews: PreviewProvider {
    static var previews: some View {
        RecommenderView()
    }
}

