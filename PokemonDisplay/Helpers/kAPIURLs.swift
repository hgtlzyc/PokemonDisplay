//
//  kAPIURLs.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/13/21.
//

import Foundation


struct kAPIURLs{
    
    static let maxBackPressureLimit: Int = 100
    
    static func urlBaseForSinglePokemon(index: Int) -> String {
        return "https://pokeapi.co/api/v2/pokemon?limit=1&offset=\(index)"
    }
    
    static func urlBaseForRangeOfPokemons(limit: Int, offset: Int) -> String {
        return "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)"
    }
}
