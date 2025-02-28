//
//  RecipeDetail.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/9/24.
//
public struct RecipeDetail: Codable {
    let vegetarian: Bool
    let vegan: Bool
    let glutenFree: Bool
    let dairyFree: Bool
    let title: String
    let readyInMinutes: Int
    let servings: Int
    let image: String
    let summary: String?
    let instructions: String?
    let extendedIngredients: [RecipeIngredient]
    let analyzedInstructions: [AnalyzedInstruction]
    let id: Int
}

struct AnalyzedInstruction: Codable {
    let name: String
    let steps: [Step]
}

struct Step: Codable {
    let number: Int
    let step: String
    let ingredients: [StepIngredient]
    let equipment: [Equipment]
}

struct StepIngredient: Codable {
    let id: Int
    let name: String
    let localizedName: String
    let image: String
}

struct Equipment: Codable {
    let id: Int
    let name: String
    let localizedName: String
    let image: String
}
