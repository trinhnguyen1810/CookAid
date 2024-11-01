import Foundation

class RecipeManager {
    static let shared = RecipeManager()
    
    private init() {}
    
    func loadRecipes() -> [Recipe] {
        guard let url = Bundle.main.url(forResource: "recipesapp", withExtension: "json") else {
            print("Failed to find recipes.json in the bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let recipes = try decoder.decode([Recipe].self, from: data)
            print("Loaded recipes: \(recipes)") // Debugging line
            return recipes
        } catch {
            print("Error loading recipes: \(error)")
            return []
        }
    }

}

