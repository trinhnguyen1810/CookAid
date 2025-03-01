import Foundation
import Combine
import SwiftUI

class MealPlanManager: ObservableObject {
    @Published var mealPlans: [Date: MealPlan] = [:]
    private let storageKey = "userMealPlans"
    
    init() {
        loadMealPlans()
    }
        
    // Add a recipe to a meal plan
    func addRecipe(recipeId: UUID, title: String, image: String?, date: Date, mealType: MealType) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        
        // Create MealItem
        let mealItem = MealItem(recipeId: recipeId, title: title, image: image)
        
        // Check if we already have a meal plan for this date
        if let index = mealPlans.index(forKey: dateOnly) {
            // Add to existing meal plan
            mealPlans[dateOnly]?.meals[mealType]?.append(mealItem)
        } else {
            // Create new meal plan for this date
            var meals: [MealType: [MealItem]] = [:]
            for type in MealType.allCases {
                meals[type] = type == mealType ? [mealItem] : []
            }
            let newMealPlan = MealPlan(date: dateOnly, meals: meals)
            mealPlans[dateOnly] = newMealPlan
        }
        
        // Notify UI of changes
        objectWillChange.send()
        saveMealPlans()
    }
    
    // Remove a recipe from a meal plan
    func removeRecipe(id: UUID, date: Date, mealType: MealType) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        
        if let index = mealPlans.index(forKey: dateOnly) {
            mealPlans[dateOnly]?.meals[mealType]?.removeAll { $0.id == id }
            
            // Explicitly notify observers
            objectWillChange.send()
            saveMealPlans()
        }
    }
    
    // Move a recipe from one meal type to another or one date to another
    func moveRecipe(item: MealItem, fromDate: Date, fromMealType: MealType, toDate: Date, toMealType: MealType) {
        let fromDateOnly = Calendar.current.startOfDay(for: fromDate)
        let toDateOnly = Calendar.current.startOfDay(for: toDate)
        
        // Remove from source
        if var fromMealPlan = mealPlans[fromDateOnly],
           let itemIndex = fromMealPlan.meals[fromMealType]?.firstIndex(where: { $0.id == item.id }) {
            
            let movedItem = fromMealPlan.meals[fromMealType]![itemIndex]
            fromMealPlan.meals[fromMealType]?.remove(at: itemIndex)
            mealPlans[fromDateOnly] = fromMealPlan
            
            // Add to destination
            if var toMealPlan = mealPlans[toDateOnly] {
                toMealPlan.meals[toMealType]?.append(movedItem)
                mealPlans[toDateOnly] = toMealPlan
            } else {
                // Create new meal plan for destination date
                var meals: [MealType: [MealItem]] = [:]
                for type in MealType.allCases {
                    meals[type] = type == toMealType ? [movedItem] : []
                }
                let newMealPlan = MealPlan(date: toDateOnly, meals: meals)
                mealPlans[toDateOnly] = newMealPlan
            }
            
            // Notify UI of changes
            objectWillChange.send()
            saveMealPlans()
        }
    }
    
    // Get meals for a specific date and meal type
    func getMeals(for date: Date, mealType: MealType) -> [MealItem] {
        let dateOnly = Calendar.current.startOfDay(for: date)
        return mealPlans[dateOnly]?.meals[mealType] ?? []
    }
    
    // Check if a meal plan exists for a specific date
    func hasMealPlan(for date: Date) -> Bool {
        let dateOnly = Calendar.current.startOfDay(for: date)
        return mealPlans[dateOnly] != nil
    }
    
    // MARK: - Private Methods
    
    private func saveMealPlans() {
        // Convert dictionary to array for encoding
        let mealPlansArray = Array(mealPlans.values)
        
        if let encoded = try? JSONEncoder().encode(mealPlansArray) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadMealPlans() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decodedPlans = try? JSONDecoder().decode([MealPlan].self, from: data) else {
            return
        }
        
        // Convert array back to dictionary
        mealPlans = Dictionary(uniqueKeysWithValues: decodedPlans.map { (Calendar.current.startOfDay(for: $0.date), $0) })
    }
}
