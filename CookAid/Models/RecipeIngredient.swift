// CookAid/Models/RecipeIngredient.swift
import Foundation

public struct RecipeIngredient: Identifiable, Codable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let amount: Double
    public let unit: String
    public let measures: Measures

    // Equatable conformance
    public static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.amount == rhs.amount &&
               lhs.unit == rhs.unit &&
               lhs.measures == rhs.measures
    }

    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount)
        hasher.combine(unit)
        hasher.combine(measures)
    }
}
