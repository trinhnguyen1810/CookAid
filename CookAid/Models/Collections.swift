import Foundation
import SwiftUI

// Enum to distinguish recipe source
enum RecipeSource: String, Codable {
    case imported
    case custom
    case apiRecipe
}

// Recipe Model for Collections
struct CollectionRecipe: Identifiable, Codable {
    let id: UUID
    var title: String
    var image: String?
    var ingredients: [String]
    var instructions: [String]
    var tags: [String]
    var source: RecipeSource
    var originalRecipeId: Int? // For API recipes
    var collectionId: UUID
    var vegetarian: Bool?
    var vegan: Bool?
    var glutenFree: Bool?
    var dairyFree: Bool?
    
    // Initializer to convert from RecipeDetail
    init(from recipeDetail: RecipeDetail, collectionId: UUID) {
        self.id = UUID()
        self.title = recipeDetail.title
        self.image = recipeDetail.image
        self.ingredients = recipeDetail.extendedIngredients.map { ingredient in
            "\(ingredient.amount) \(ingredient.unit) \(ingredient.name)"
        }
        self.instructions = recipeDetail.analyzedInstructions.first?.steps.map { $0.step } ?? []
        self.tags = []
        self.source = .apiRecipe
        self.originalRecipeId = recipeDetail.id
        self.collectionId = collectionId
        self.vegetarian = recipeDetail.vegetarian
        self.vegan = recipeDetail.vegan
        self.glutenFree = recipeDetail.glutenFree
        self.dairyFree = recipeDetail.dairyFree
    }
    
    // Initializer to convert from QuickRecipe
    init(from quickRecipe: QuickRecipe, collectionId: UUID) {
        self.id = UUID()
        self.title = quickRecipe.title
        self.image = quickRecipe.image
        self.ingredients = []
        self.instructions = []
        self.tags = []
        self.source = .apiRecipe
        self.originalRecipeId = quickRecipe.id
        self.collectionId = collectionId
        self.vegetarian = nil
        self.vegan = nil
        self.glutenFree = nil
        self.dairyFree = nil
    }
    
    // Original initializer
    init(id: UUID = UUID(),
         title: String,
         image: String? = nil,
         ingredients: [String] = [],
         instructions: [String] = [],
         tags: [String] = [],
         source: RecipeSource = .custom,
         originalRecipeId: Int? = nil,
         collectionId: UUID,
         vegetarian: Bool? = nil,
         vegan: Bool? = nil,
         glutenFree: Bool? = nil,
         dairyFree: Bool? = nil) {
        self.id = id
        self.title = title
        self.image = image
        self.ingredients = ingredients
        self.instructions = instructions
        self.tags = tags
        self.source = source
        self.originalRecipeId = originalRecipeId
        self.collectionId = collectionId
        self.vegetarian = vegetarian
        self.vegan = vegan
        self.glutenFree = glutenFree
        self.dairyFree = dairyFree
    }
}

// Collection Model
struct RecipeCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var recipes: [CollectionRecipe]
    var description: String?
    var coverImage: String?
    
    init(id: UUID = UUID(),
         name: String,
         recipes: [CollectionRecipe] = [],
         description: String? = nil,
         coverImage: String? = nil) {
        self.id = id
        self.name = name
        self.recipes = recipes
        self.description = description
        self.coverImage = coverImage
    }
}
