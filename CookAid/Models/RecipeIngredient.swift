// CookAid/Models/RecipeIngredient.swift
import Foundation

struct RecipeIngredient: Identifiable, Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let measures: Measures
}
