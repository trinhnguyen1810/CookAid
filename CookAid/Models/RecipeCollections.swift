import Foundation
import SwiftUI

// Enum to distinguish recipe source
public enum RecipeSource: String, Codable, Hashable {
    case imported
    case custom
    case apiRecipe
}

public enum RecipeCollections {
    public struct Recipe: Identifiable, Codable, Hashable, Equatable {
        public let id: UUID
            public var title: String
            public var image: String?
            public var ingredients: [RecipeIngredient]
            public var instructions: [String]
            public var tags: [String]
            public var source: RecipeSource
            public var originalRecipeId: Int? // For API recipes
            public var collectionId: UUID
            public var vegetarian: Bool?
            public var vegan: Bool?
            public var glutenFree: Bool?
            public var dairyFree: Bool?
            
            // Add this Equatable conformance method
            public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
                return lhs.id == rhs.id &&
                       lhs.title == rhs.title &&
                       lhs.image == rhs.image &&
                       lhs.ingredients == rhs.ingredients &&
                       lhs.instructions == rhs.instructions &&
                       lhs.tags == rhs.tags &&
                       lhs.source == rhs.source &&
                       lhs.originalRecipeId == rhs.originalRecipeId &&
                       lhs.collectionId == rhs.collectionId &&
                       lhs.vegetarian == rhs.vegetarian &&
                       lhs.vegan == rhs.vegan &&
                       lhs.glutenFree == rhs.glutenFree &&
                       lhs.dairyFree == rhs.dairyFree
            }
            
        
        // Initializer to convert from RecipeDetail
        public init(from recipeDetail: RecipeDetail, collectionId: UUID) {
            self.id = UUID()
            self.title = recipeDetail.title
            self.image = recipeDetail.image
            self.ingredients = recipeDetail.extendedIngredients
            
            // Combine instructions from different sources
            self.instructions = recipeDetail.analyzedInstructions.first?.steps.map { $0.step } ??
                                (recipeDetail.instructions?.components(separatedBy: ".").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? [])
            
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
        public init(from quickRecipe: QuickRecipe, collectionId: UUID) {
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
        
        // Original initializer (keep as is)
        public init(id: UUID = UUID(),
             title: String,
             image: String? = nil,
             ingredients: [RecipeIngredient] = [],
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
    public struct Collection: Identifiable, Codable, Hashable, Equatable {
        public let id: UUID
        public var name: String
        public var recipes: [Recipe]
        public var description: String?
        public var coverImage: String?
        public var dateCreated: Date
        
        // Hashable conformance
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(dateCreated)
        }
        
        // Equatable conformance
        public static func == (lhs: Collection, rhs: Collection) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.name == rhs.name &&
                   lhs.dateCreated == rhs.dateCreated
        }
        
        public init(id: UUID = UUID(),
             name: String,
             recipes: [Recipe] = [],
             description: String? = nil,
             coverImage: String? = nil,
             dateCreated: Date = Date()) {
            self.id = id
            self.name = name
            self.recipes = recipes
            self.description = description
            self.coverImage = coverImage
            self.dateCreated = dateCreated
        }
    }
}
