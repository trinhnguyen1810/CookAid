import Foundation
import Combine

class RecipeImportManager: ObservableObject {
    func extractRecipeFromURL(urlString: String, completion: @escaping (Result<ImportedRecipeDetail, Error>) -> Void) {
        // RapidAPI headers
        let headers = [
            "x-rapidapi-key": "98b3e1fa50mshc692e9435ce549bp1a91aajsn27f97bf0ac6d",
            "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
        ]
        
        // Encode the URL
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/extract?url=\(encodedURL)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Error handling
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check response
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // Decode the recipe
                let decoder = JSONDecoder()
                let extractedRecipe = try decoder.decode(ImportedRecipeDetail.self, from: data)
                completion(.success(extractedRecipe))
            } catch {
                // Print raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
