import Foundation

struct Ingredient: Identifiable, Codable {
    let id: String
    let name: String
    let dateBought: String?
    let category: String
    
}
