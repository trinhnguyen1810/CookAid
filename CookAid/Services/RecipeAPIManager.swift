import Foundation
import Combine

class RecipeAPIManager: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var quickrecipes: [QuickRecipe] = []
    @Published var searchResults: [QuickRecipe] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    // RapidAPI headers
    private let headers: [String: String] = [
        "x-rapidapi-key": "37b06fda77mshe40431fceb7661cp1422b0jsn4c45f640fc89",
        "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    ]
    
    @MainActor
    func fetchRecipes(ingredients: [String], diets: [String] = [], intolerances: [String] = []) {
        let ingredientsString = ingredients.joined(separator: "%2C")
        
        guard var urlComponents = URLComponents(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/findByIngredients") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "ingredients", value: ingredientsString),
            URLQueryItem(name: "number", value: "1"),
            URLQueryItem(name: "ignorePantry", value: "true"),
            URLQueryItem(name: "ranking", value: "1")
        ]
        
        guard let url = urlComponents.url else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                    // Print raw JSON for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Response: \(jsonString)")
                    }
                }
            }
        }.resume()
    }
    
    func fetchRecipeDetail(id: Int) async -> RecipeDetail? {
        guard let url = URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/\(id)/information") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return nil
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            await MainActor.run {
                self.isLoading = false
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(RecipeDetail.self, from: data)
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Error fetching recipe detail: \(error.localizedDescription)"
            }
            print("Error decoding recipe detail: \(error)")
            return nil
        }
    }
    
    @MainActor
    func fetchQuickMeals(ingredients: [String], diets: [String] = [], intolerances: [String] = []) {
        let ingredientsString = ingredients.joined(separator: "%2C")
        
        guard var urlComponents = URLComponents(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "includeIngredients", value: ingredientsString),
            URLQueryItem(name: "maxReadyTime", value: "30"),
            URLQueryItem(name: "number", value: "5"),
            URLQueryItem(name: "ranking", value: "2")
        ]
        
        // Add optional diet and intolerances
        if !diets.isEmpty {
            urlComponents.queryItems?.append(URLQueryItem(name: "diet", value: diets.joined(separator: "%2C")))
        }
        
        if !intolerances.isEmpty {
            urlComponents.queryItems?.append(URLQueryItem(name: "intolerances", value: intolerances.joined(separator: "%2C")))
        }
        
        guard let url = urlComponents.url else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                    // Print raw JSON for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Response: \(jsonString)")
                    }
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
        
        guard var urlComponents = URLComponents(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "addRecipeInformation", value: "true")
        ]
        
        // Add optional diet and intolerances
        if !diets.isEmpty {
            queryItems.append(URLQueryItem(name: "diet", value: diets.joined(separator: "%2C")))
        }
        
        if !intolerances.isEmpty {
            queryItems.append(URLQueryItem(name: "intolerances", value: intolerances.joined(separator: "%2C")))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        print("Search URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
