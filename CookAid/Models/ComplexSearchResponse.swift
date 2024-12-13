//
//  ComplexSearchResponse.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/11/24.
//

import Foundation
struct ComplexSearchResponse: Codable {
    let results: [QuickRecipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}
