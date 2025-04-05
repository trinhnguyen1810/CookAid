import SwiftUI
import Firebase

@main
struct CookAidApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject private var recipeAPIManager = RecipeAPIManager()
    @StateObject private var ingredientsManager: IngredientsManager
    @StateObject private var collectionsManager: CollectionsManager
    @StateObject var mealPlanManager = MealPlanManager()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Create recipeAPIManager first
        let apiManager = RecipeAPIManager()
        
        // Create ingredientsManager with recipeAPIManager
        let ingredients = IngredientsManager(recipeAPIManager: apiManager)
        
        // Create collectionsManager with recipeAPIManager
        let collections = CollectionsManager(recipeAPIManager: apiManager)
        
        // Use _StateObject to initialize the properties
        _recipeAPIManager = StateObject(wrappedValue: apiManager)
        _ingredientsManager = StateObject(wrappedValue: ingredients)
        _collectionsManager = StateObject(wrappedValue: collections)
    }
    
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
