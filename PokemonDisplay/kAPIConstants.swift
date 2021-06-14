//
//  kAPIURLs.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/13/21.
//

import Foundation


struct kAPIConstants{
    
    //default backpressure limit when reload all or loadselected uncontrolled
    static let uncontrolledMaxTasksPressureLimit: Int = 3
    
    //TODO: featch the upperlimit from API
    static let pokemonUpperInclusiveBound: Int = 1000
    
    static func urlBaseForSinglePokemonDM(index: Int) -> String {
        return "https://pokeapi.co/api/v2/pokemon/\(index)"
    }
    
    static func urlBaseForRangeOfPokemonsDM(limit: Int, offset: Int) -> String {
        return "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)"
    }
}
