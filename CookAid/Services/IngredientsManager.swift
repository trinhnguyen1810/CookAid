import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class IngredientsManager: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    private var recipeAPIManager: RecipeAPIManager?
    
    init(recipeAPIManager: RecipeAPIManager) {
        self.recipeAPIManager = recipeAPIManager
        Task {
            await fetchIngredients()
        }
    }

    init() {
        Task {
            await fetchIngredients()
        }
    }

    @MainActor
    func fetchIngredients() async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .getDocuments()
            
            self.ingredients = snapshot.documents.compactMap { document in
                try? document.data(as: Ingredient.self)
            }
        } catch {
            print("Error fetching ingredients: \(error.localizedDescription)")
        }
    }

    func addIngredient(_ ingredient: Ingredient) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        do {
            try await db.collection("users")
                .document(currentUser.uid)
                .collection("ingredients")
                .document(ingredient.id)
                .setData(from: ingredient)
            
            await MainActor.run {
                ingredients.append(ingredient)
            }
            
            if let recipeAPIManager = recipeAPIManager {
                await recipeAPIManager.fetchRecipes(ingredients: ingredients.map { $0.name })
            }
        } catch {
            print("Error adding ingredient: \(error.localizedDescription)")
        }
    }
}
