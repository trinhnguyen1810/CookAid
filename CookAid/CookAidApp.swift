import SwiftUI
import Firebase

@main
struct CookAidApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject private var ingredientsManager = IngredientsManager()
    @StateObject private var collectionsManager = CollectionsManager() // Add this line
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(ingredientsManager)
                .environmentObject(collectionsManager) // Add this line
        }
    }
}
