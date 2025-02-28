import Foundation

// Imported Recipe Detail Model
public struct ImportedRecipeDetail: Codable {
    let id: Int?
    let title: String
    let image: String?
    let servings: Int?
    let readyInMinutes: Int?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let aggregateLikes: Int?
    let healthScore: Double?
    let spoonacularScore: Double?
    let pricePerServing: Double?
    
    let extendedIngredients: [ImportedRecipeIngredient]
    let instructions: String?
    
    // Computed property to get ingredients as strings
    var ingredientStrings: [String] {
        return extendedIngredients.map {
            "\($0.amount) \($0.unit) \($0.name)"
        }
    }
    
    // Computed property to get instructions as steps
    var instructionSteps: [String] {
        return instructions?.components(separatedBy: ".").compactMap {
            let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed + "."
        } ?? []
    }
}

// Imported Recipe Ingredient to match your RecipeIngredient structure
public struct ImportedRecipeIngredient: Identifiable, Codable {
    public let id: Int
    let name: String
    let amount: Double
    let unit: String
    let measures: ImportedMeasures
}

// Measures structure to match your Measures
public struct ImportedMeasures: Codable {
    let us: ImportedUnitMeasure
    let metric: ImportedUnitMeasure
}

public struct ImportedUnitMeasure: Codable {
    let amount: Double
    let unitShort: String
    let unitLong: String
}
