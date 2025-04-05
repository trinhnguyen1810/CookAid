import Foundation

// Use a class for a singleton pattern
class APIConfig {
    static let shared = APIConfig()
    
    private var apiKeys: [String: String] = [:]
    
    private init() {
        loadAPIKeys()
    }
    
    private func loadAPIKeys() {
        // Try to load from environment variables 
        if let rapidAPIKey = ProcessInfo.processInfo.environment["RAPIDAPI_KEY"] {
            apiKeys["RAPIDAPI_KEY"] = rapidAPIKey
            return
        }
        
        // Try to load from plist file
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path) as? [String: String] {
            apiKeys = keys
            return
        }
        
        // If no keys are found, log a warning
        print("WARNING: No API keys found. API functionality may be limited.")
    }
    
    func apiKey(for service: APIService) -> String? {
        return apiKeys[service.rawValue]
    }
    
    func headers(for service: APIService) -> [String: String] {
        switch service {
        case .spoonacular:
            guard let apiKey = apiKey(for: .spoonacular) else {
                return [:]
            }
            
            return [
                "x-rapidapi-key": apiKey,
                "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
            ]
        }
    }
}

enum APIService: String {
    case spoonacular = "RAPIDAPI_KEY"
}
