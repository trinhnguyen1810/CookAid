//
//  QuickRecipe.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/11/24.
//

import Foundation
struct QuickRecipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String
    let imageType: String
}
