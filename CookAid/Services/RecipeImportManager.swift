import Foundation
import Combine

class RecipeImportManager: ObservableObject {
    private var headers: [String: String] {
        return APIConfig.shared.headers(for: .spoonacular)
    }
    
    func extractRecipeFromURL(urlString: String, completion: @escaping (Result<ImportedRecipeDetail, Error>) -> Void) {
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/extract?url=\(encodedURL)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let extractedRecipe = try decoder.decode(ImportedRecipeDetail.self, from: data)
                completion(.success(extractedRecipe))
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
