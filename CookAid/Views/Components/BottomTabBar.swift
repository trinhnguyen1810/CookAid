import SwiftUI

struct BottomTabBar: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            TabBarButton(imageName: "house.fill", label: "Home") {
                HomeView().navigationBarBackButtonHidden()
            }
            Spacer()
            TabBarButton(imageName: "cart.fill", label: "Pantry") {
                PantryView().navigationBarBackButtonHidden()
            }
            Spacer()
            TabBarButton(imageName: "calendar", label: "Meal Plan") {
                MealPlannerView().navigationBarBackButtonHidden()
            }
            Spacer()
            TabBarButton(imageName: "clipboard.fill", label: "Grocery") {
                GroceryView().navigationBarBackButtonHidden()
            }
            Spacer()
            TabBarButton(imageName: "square.stack", label: "Collections") {
                CollectionsView().navigationBarBackButtonHidden()
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
