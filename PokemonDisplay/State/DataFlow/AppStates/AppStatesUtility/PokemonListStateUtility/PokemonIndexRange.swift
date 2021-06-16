//
//  PokemonIndexRange.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/11/21.
//

import Foundation

struct PokemonIndexRange: Codable {
    var lowerBound: Int
    var upperInclusiveBound: Int
    
    init(lowerBound: Int, upperInclusiveBound: Int) {
        if lowerBound <= upperInclusiveBound {
            self.lowerBound = lowerBound
            self.upperInclusiveBound = upperInclusiveBound
        } else {
            self.lowerBound = lowerBound
            self.upperInclusiveBound = lowerBound
        }
    }
}
