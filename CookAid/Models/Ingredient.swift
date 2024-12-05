import Foundation

struct Ingredient: Identifiable, Codable {
    let id: String
    let name: String
    let dateBought: Date? 
    let category: String
    
}
