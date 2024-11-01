import Foundation

struct Recipe: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var ingredients: String
    var instructions: String
    var imageName: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case ingredients = "Ingredients"
        case instructions = "Instructions"
        case imageName = "Image_Name"
    }
}

