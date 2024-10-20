import SwiftUI

struct BottomTabBar: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            TabBarButton(imageName: "house.fill", label: "Home") {
                HomeView() // Navigate to HomeView
            }
            Spacer()
            TabBarButton(imageName: "cart.fill", label: "Pantry") {
                PantryView() // Navigate to PantryView
            }
            Spacer()
            TabBarButton(imageName: "sparkles", label: "Recommender") {
                RecommenderView()
            }
            Spacer()
            TabBarButton(imageName: "clipboard.fill", label: "Grocery") {
                GroceryView()
            }
            Spacer()
            TabBarButton(imageName: "person.fill", label: "Profile") {
                ProfileView()
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

