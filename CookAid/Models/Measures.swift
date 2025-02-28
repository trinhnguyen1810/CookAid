//
//  Measures.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/9/24.
//

import Foundation

public struct Measures: Codable, Hashable, Equatable {
    public let metric: MeasureUnit
    public let us: MeasureUnit
}

public struct MeasureUnit: Codable, Hashable, Equatable {
    public let amount: Double
    public let unitShort: String
    public let unitLong: String
}
