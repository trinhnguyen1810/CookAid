import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home // Track the selected tab

    var body: some View {
        NavigationView {
            VStack {
                switch selectedTab {
                case .home:
                    HomeView()
                case .pantry:
                    PantryView()
                case .recommender:
                    RecommenderView()
                case .recipes:
                    Text("Recipes View")
                case .profile:
                    ProfileView()
                }
                
                // Bottom Tab Bar
                BottomTabBar()
            }
            .navigationBarHidden(true)
        }
    }
}

// Define the tab enumeration
enum Tab {
    case home, pantry, recommender, recipes, profile
}

