//
//  Measures.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/9/24.
//

import Foundation

struct Measures: Codable {
    let us: UnitMeasure
    let metric: UnitMeasure
}

struct UnitMeasure: Codable {
    let amount: Double
    let unitShort: String
    let unitLong: String
}
