import Foundation
import Combine

class RecipeAPIManager: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var quickrecipes : [QuickRecipe] = []
    @Published var errorMessage: String? = nil
    
    @MainActor
    func fetchRecipes(ingredients: [String]) {
        let ingredientsString = ingredients.joined(separator: ",")
        
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/findByIngredients")!
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: "8c097f2cc79d46ecb543f3b99e67ab04"),
            URLQueryItem(name: "ingredients", value: ingredientsString),
            URLQueryItem(name: "number", value: "4"),
            URLQueryItem(name: "ignorePantry", value: "true")
        ]
        
        guard let url = components.url else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        //print("Final URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
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
    
    @MainActor
        func fetchQuickMeals(ingredients: [String]) {
            let ingredientsString = ingredients.joined(separator: ",")
            let maxReadyTime = 30
            
            var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
            components.queryItems = [
                URLQueryItem(name: "apiKey", value: "8c097f2cc79d46ecb543f3b99e67ab04"),
                URLQueryItem(name: "includeIngredients", value: ingredientsString),
                URLQueryItem(name: "maxReadyTime", value: "\(maxReadyTime)"),
                URLQueryItem(name: "number", value: "3")
            ]
            
            guard let url = components.url else {
                errorMessage = "Invalid URL"
                return
            }
            
            print("Full URL being called: \(url.absoluteString)")
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
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
                
                // Print raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                do {
                    let response = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.quickrecipes = response.results
                        self.errorMessage = nil
                        print("Successfully fetched \(response.results.count) quick recipes")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error decoding recipes: \(error.localizedDescription)"
                        print("Decoding error: \(error)")
                    }
                }
            }.resume()
        }
    }
   
