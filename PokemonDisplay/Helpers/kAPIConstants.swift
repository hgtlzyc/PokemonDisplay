//
//  kAPIURLs.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/13/21.
//

import Foundation


struct kAPIConstants{
    
    static let maxBackPressureLimit: Int = 10
    
    static func urlBaseForSinglePokemon(index: Int) -> String {
        return "https://pokeapi.co/api/v2/pokemon/\(index)"
    }
    
    static func urlBaseForRangeOfPokemons(limit: Int, offset: Int) -> String {
        return "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)"
    }
}
