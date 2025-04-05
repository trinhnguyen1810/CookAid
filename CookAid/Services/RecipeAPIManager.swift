import Foundation
import Combine

class RecipeAPIManager: ObservableObject, NetworkErrorHandler {
    @Published var recipes: [Recipe] = []
    @Published var quickrecipes: [QuickRecipe] = []
    @Published var searchResults: [QuickRecipe] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var loadingState: LoadingState = .idle
    
    // Get API headers from APIConfig
    private var headers: [String: String] {
        return APIConfig.shared.headers(for: .spoonacular)
    }
    
    @MainActor
    func fetchRecipes(ingredients: [String], diets: [String] = [], intolerances: [String] = []) {
        // First, sanitize ingredient names to remove any problematic characters
        let sanitizedIngredients = ingredients.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
             .replacingOccurrences(of: ",", with: " ")
        }.filter { !$0.isEmpty }
        
        // Debug: Print cleaned ingredients list going to API
        print("DEBUG - Sending ingredients to API: \(sanitizedIngredients)")
        
        // Only proceed if we have ingredients
        guard !sanitizedIngredients.isEmpty else {
            self.loadingState = .error("No valid ingredients to search with")
            return
        }
        
        // Properly encode ingredients for URL
        let ingredientsString = sanitizedIngredients.joined(separator: ",")
        
        // Debug: Print the final ingredient string
        print("DEBUG - Final ingredients string: \(ingredientsString)")
        
        guard var urlComponents = URLComponents(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/findByIngredients") else {
            self.loadingState = .error("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "ingredients", value: ingredientsString),
            URLQueryItem(name: "number", value: "2"),
            URLQueryItem(name: "ignorePantry", value: "true"),
            URLQueryItem(name: "ranking", value: "1")
        ]
        
        // Add additional parameters if needed
        if !diets.isEmpty {
            print("DEBUG - Adding diets: \(diets)")
            // Note: For this endpoint, additional params may be needed depending on API changes
        }
        
        if !intolerances.isEmpty {
            print("DEBUG - Adding intolerances: \(intolerances)")
            // Note: For this endpoint, additional params may be needed depending on API changes
        }
        
        guard let url = urlComponents.url else {
            self.loadingState = .error("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        // Debug: Print full request details
        print("DEBUG - Request URL: \(url.absoluteString)")
        print("DEBUG - Headers: \(String(describing: headers))")
        
        // Update loading state
        self.loadingState = .loading
        self.errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    self.errorMessage = "Error fetching recipes: \(error.localizedDescription)"
                    self.loadingState = .error(self.handleNetworkError(error))
                    print("DEBUG - Network error: \(error)")
                    return
                }
                
                // Check HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    print("DEBUG - HTTP Status: \(httpResponse.statusCode)")
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        self.errorMessage = "HTTP \(httpResponse.statusCode) error"
                        self.loadingState = .error(self.handleHTTPError(httpResponse.statusCode))
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.loadingState = .error("No data received")
                    return
                }
                
                do {
                    let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    print("DEBUG - Received \(recipes.count) recipes")
                    
                    // Update loading state based on results
                    if recipes.isEmpty {
                        self.loadingState = .error("No recipes found")
                    } else {
                        self.recipes = recipes
                        self.loadingState = .success
                    }
                    
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Error decoding recipes: \(error.localizedDescription)"
                    self.loadingState = .error("Failed to decode recipes")
                    print("DEBUG - Decoding error: \(error)")
                    
                    // Print raw JSON for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("DEBUG - Raw JSON Response (first 500 chars): \(String(jsonString.prefix(500)))...")
                    }
                }
            }
        }.resume()
    }
    
    func fetchRecipeDetail(id: Int) async -> RecipeDetail? {
        // Update loading state
        await MainActor.run {
            self.loadingState = .loading
            self.errorMessage = nil
        }
        
        guard let url = URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/\(id)/information") else {
            await MainActor.run {
                self.loadingState = .error("Invalid URL")
                self.errorMessage = "Invalid URL"
            }
            return nil
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    await MainActor.run {
                        self.loadingState = .error(handleHTTPError(httpResponse.statusCode))
                        self.errorMessage = "HTTP \(httpResponse.statusCode) error"
                    }
                    return nil
                }
            }
            
            let decoder = JSONDecoder()
            let recipeDetail = try decoder.decode(RecipeDetail.self, from: data)
            
            await MainActor.run {
                self.loadingState = .success
            }
            
            return recipeDetail
        } catch {
            await MainActor.run {
                self.loadingState = .error(handleNetworkError(error))
                self.errorMessage = "Error fetching recipe detail: \(error.localizedDescription)"
            }
            print("Error decoding recipe detail: \(error)")
            return nil
        }
    }
    
    @MainActor
    func fetchQuickMeals(ingredients: [String], diets: [String] = [], intolerances: [String] = []) {
        let ingredientsString = ingredients.joined(separator: ",")
        
        guard var urlComponents = URLComponents(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex") else {
            self.loadingState = .error("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "includeIngredients", value: ingredientsString),
            URLQueryItem(name: "maxReadyTime", value: "30"),
            URLQueryItem(name: "number", value: "2"),
            URLQueryItem(name: "ranking", value: "1")
        ]
        
        // Add optional diet and intolerances
        if !diets.isEmpty {
            urlComponents.queryItems?.append(URLQueryItem(name: "diet", value: diets.joined(separator: ",")))
        }
        
        if !intolerances.isEmpty {
            urlComponents.queryItems?.append(URLQueryItem(name: "intolerances", value: intolerances.joined(separator: ",")))
        }
        
        guard let url = urlComponents.url else {
            self.loadingState = .error("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        // Update loading state
        self.loadingState = .loading
        self.errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    self.errorMessage = "Error fetching quick meals: \(error.localizedDescription)"
                    self.loadingState = .error(self.handleNetworkError(error))
                    return
                }
                
                // Check HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        self.errorMessage = "HTTP \(httpResponse.statusCode) error"
                        self.loadingState = .error(self.handleHTTPError(httpResponse.statusCode))
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.loadingState = .error("No data received")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                    self.quickrecipes = response.results
                    
                    // Update loading state based on results
                    if response.results.isEmpty {
                        self.loadingState = .error("No quick meals found")
                    } else {
                        self.loadingState = .success
                    }
                    
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Error decoding quick meals: \(error.localizedDescription)"
                    self.loadingState = .error("Failed to decode quick meals")
                    
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
        // Reset search results and update loading state
        self.searchResults = []
        self.loadingState = .loading
        self.errorMessage = nil
        
        guard var urlComponents = URLComponents(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex") else {
            self.loadingState = .error("Invalid URL")
            return
        }
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "addRecipeInformation", value: "true")
        ]
        
        // Add optional diet and intolerances
        if !diets.isEmpty {
            queryItems.append(URLQueryItem(name: "diet", value: diets.joined(separator: ",")))
        }
        
        if !intolerances.isEmpty {
            queryItems.append(URLQueryItem(name: "intolerances", value: intolerances.joined(separator: ",")))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            self.loadingState = .error("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        print("Search URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    self.errorMessage = "Error searching recipes: \(error.localizedDescription)"
                    self.loadingState = .error(self.handleNetworkError(error))
                    return
                }
                
                // Check HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        self.errorMessage = "HTTP \(httpResponse.statusCode) error"
                        self.loadingState = .error(self.handleHTTPError(httpResponse.statusCode))
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.loadingState = .error("No data received")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                    self.searchResults = response.results
                    
                    // Update loading state based on results
                    if response.results.isEmpty {
                        self.loadingState = .error("No recipes found")
                    } else {
                        self.loadingState = .success
                    }
                    
                    self.errorMessage = nil
                    print("Search results count: \(response.results.count)")
                } catch {
                    self.errorMessage = "Error decoding search results: \(error.localizedDescription)"
                    self.loadingState = .error("Failed to decode search results")
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
