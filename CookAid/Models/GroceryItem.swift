import Foundation

struct GroceryItem: Identifiable, Codable {
    let id: String // Unique identifier
    let name: String
    let category: String
}
