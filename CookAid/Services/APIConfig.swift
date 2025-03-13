import Foundation

struct APIConfig {
    static let shared = APIConfig()
    
    private var apiKeys: [String: String] = [:]
    
    private init() {
        loadAPIKeys()
    }
    
    private mutating func loadAPIKeys() {
        if let rapidAPIKey = ProcessInfo.processInfo.environment["RAPIDAPI_KEY"] {
            apiKeys["RAPIDAPI_KEY"] = rapidAPIKey
            return
        }
        
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path) as? [String: String] {
            apiKeys = keys
            return
        }
        
 
        loadFromKeychain()
    }
    
    private mutating func loadFromKeychain() {

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
