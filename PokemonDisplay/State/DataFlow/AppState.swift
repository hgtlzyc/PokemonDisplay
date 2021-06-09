//
//  AppState.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Combine

struct AppState {
    var pokemonList = PokemonList()
    //for testing
    var currentStatus = String()
}

extension AppState {
    struct PokemonList {
        var pokemonsNameDic: [Int: String]?
        
    }
}
