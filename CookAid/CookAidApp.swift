import SwiftUI
import Firebase

@main
struct CookAidApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject private var ingredientsManager = IngredientsManager()
    @StateObject private var collectionsManager = CollectionsManager()
    @StateObject private var recipeAPIManager = RecipeAPIManager()
    @StateObject var mealPlanManager = MealPlanManager()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(ingredientsManager)
                .environmentObject(collectionsManager)
                .environmentObject(mealPlanManager)
                .environmentObject(recipeAPIManager)
            
        }
    }
}
