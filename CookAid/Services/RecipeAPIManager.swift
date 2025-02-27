
import Foundation
import Combine

class RecipeAPIManager: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var quickrecipes: [QuickRecipe] = []
    @Published var searchResults: [QuickRecipe] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    @MainActor
    func fetchRecipes(ingredients: [String], diets: [String] = [], intolerances: [String] = []) {
        let ingredientsString = ingredients.joined(separator: ",")
        
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/findByIngredients")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: "8c097f2cc79d46ecb543f3b99e67ab04"),
            URLQueryItem(name: "ingredients", value: ingredientsString),
            URLQueryItem(name: "number", value: "2"),
            URLQueryItem(name: "ignorePantry", value: "true")
        ]

        if !diets.isEmpty {
            let dietString = diets.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "diet", value: dietString))
        }
        
        if !intolerances.isEmpty {
            let intolerancesString = intolerances.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "intolerances", value: intolerancesString))
        }
        
        components.queryItems = queryItems

        guard let url = components.url else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching recipes: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    self.recipes = recipes
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Error decoding recipes: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    @MainActor
    func fetchQuickMeals(ingredients: [String], diets: [String] = [], intolerances: [String] = []) {
        let ingredientsString = ingredients.joined(separator: ",")
        let maxReadyTime = 30
        
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: "8c097f2cc79d46ecb543f3b99e67ab04"),
            URLQueryItem(name: "includeIngredients", value: ingredientsString),
            URLQueryItem(name: "maxReadyTime", value: "\(maxReadyTime)"),
            URLQueryItem(name: "number", value: "2")
        ]
              
        if !diets.isEmpty {
            let dietString = diets.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "diet", value: dietString))
        }
        
        if !intolerances.isEmpty {
            let intolerancesString = intolerances.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "intolerances", value: intolerancesString))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching quick meals: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                    self.quickrecipes = response.results
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Error decoding quick meals: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    @MainActor
    func searchRecipes(query: String, diets: [String] = [], intolerances: [String] = []) {
        // Reset search results
        self.searchResults = []
        self.isLoading = true
        self.errorMessage = nil
        
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: "8c097f2cc79d46ecb543f3b99e67ab04"),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "addRecipeInformation", value: "true")
        ]
        
        if !diets.isEmpty {
            let dietString = diets.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "diet", value: dietString))
        }
        
        if !intolerances.isEmpty {
            let intolerancesString = intolerances.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "intolerances", value: intolerancesString))
        }
        
        components.queryItems = queryItems

        guard let url = components.url else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        print("Search URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error searching recipes: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                    self.searchResults = response.results
                    self.errorMessage = nil
                    print("Search results count: \(response.results.count)")
                } catch {
                    self.errorMessage = "Error decoding search results: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                    
                    // Print raw JSON for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Response: \(jsonString)")
                    }
                }
            }
        }.resume()
    }
}
