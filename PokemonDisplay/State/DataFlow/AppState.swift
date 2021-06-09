//
//  AppState.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Combine

struct AppState {
    var pokemonList = PokemonList()
}

extension AppState {
    struct PokemonList {
        
        var pokemonsDic: [Int: String]?
        
    }
}
