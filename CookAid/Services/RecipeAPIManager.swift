import Foundation
import Combine

class RecipeAPIManager: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorMessage: String? = nil
    
    func fetchRecipes(ingredients: [String]) {
        // Instead of manually joining with ",+", just join with comma
        let ingredientsString = ingredients.joined(separator: ",")
        
        // Use URLComponents to properly handle URL encoding
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/findByIngredients")!
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: "f1c8e26a6f554159ab2714022bbee9c7"),
            URLQueryItem(name: "ingredients", value: ingredientsString),
            URLQueryItem(name: "number", value: "1"),
            URLQueryItem(name: "ignorePantry", value: "true")
        ]
        
        guard let url = components.url else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        // Print the final URL for debugging
        print("Final URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching recipes: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                DispatchQueue.main.async {
                    self.recipes = recipes
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error decoding recipes: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
