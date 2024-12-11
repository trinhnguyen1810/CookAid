import SwiftUI
import Firebase

@main
struct CookAidApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject private var ingredientsManager = IngredientsManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(ingredientsManager)
        }
    }
}

