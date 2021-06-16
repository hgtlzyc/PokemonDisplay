//
//  PokemonIndexRange.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/11/21.
//

import Foundation

enum PokemonIndexChangeFrom {
    case lower
    case upper
}

struct PokemonIndexRange: Codable {
    var lowerBound: Int
    var upperInclusiveBound: Int
    
    init(lowerBound: Int, upperInclusiveBound: Int, changeFrom: PokemonIndexChangeFrom ) {
        switch (lowerBound, upperInclusiveBound, changeFrom) {
        case let (lower , upper, _ ) where lower < upper:
            self.lowerBound = lower
            self.upperInclusiveBound = upper
        case let (lower , upper, .lower ) where lower >= upper:
            self.lowerBound = lower
            self.upperInclusiveBound = lower
        case let (lower , upper, .upper ) where lower <= upper:
            self.lowerBound = upper
            self.upperInclusiveBound = upper
        default:
            print(Date(),"PokemonIndexRange unexpected")
            self.lowerBound = upperInclusiveBound
            self.upperInclusiveBound = upperInclusiveBound
        }
    }
}
