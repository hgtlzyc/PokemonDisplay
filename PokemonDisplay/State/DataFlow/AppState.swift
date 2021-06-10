//
//  AppState.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Combine

struct AppState {
    var pokemonListState = PokemonListState()
}

//PokemonList State
extension AppState {
    struct PokemonListState {
        
        //States
        var loadPokemonError: AppError?
        var currentlyLoadingPokemons = false
        
        //Data
        @FileStorage(directory: .cachesDirectory, fileName: "pokemons.json")
        var pokemonsDic: [Int: PokemonViewModel]?
        
    }
}
