import Foundation

// Model to represent a meal plan
struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var meals: [MealType: [MealItem]]
    
    init(date: Date, meals: [MealType: [MealItem]] = [:]) {
        self.date = date
        self.meals = meals
        
        // Initialize empty arrays for all meal types
        for type in MealType.allCases {
            if self.meals[type] == nil {
                self.meals[type] = []
            }
        }
    }
}

// Model to represent a meal item (recipe in the meal plan)
struct MealItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var recipeId: UUID
    var title: String
    var image: String?
    
    static func == (lhs: MealItem, rhs: MealItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// Enum for meal types
enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case others = "Others"
}
