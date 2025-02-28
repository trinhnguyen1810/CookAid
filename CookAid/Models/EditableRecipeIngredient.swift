import Foundation

struct EditableRecipeIngredient: Identifiable {
    var id: Int
    var name: String
    var amount: Double
    var unit: String
    
    // Default initializer
    init(id: Int, name: String, amount: Double, unit: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }
    
    // Initialize from a RecipeIngredient
    init(from ingredient: RecipeIngredient) {
        self.id = ingredient.id
        self.name = ingredient.name
        self.amount = ingredient.amount
        self.unit = ingredient.unit
    }
    
    // Convert back to RecipeIngredient
    func toRecipeIngredient() -> RecipeIngredient {
        return RecipeIngredient(
            id: id,
            name: name,
            amount: amount,
            unit: unit,
            measures: Measures(
                us: UnitMeasure(amount: amount, unitShort: unit, unitLong: unit),
                metric: UnitMeasure(amount: amount, unitShort: unit, unitLong: unit)
            )
        )
    }
    
    // Create a new empty ingredient
    static func empty() -> EditableRecipeIngredient {
        return EditableRecipeIngredient(
            id: Int.random(in: 1000...9999),
            name: "",
            amount: 0,
            unit: ""
        )
    }
}
