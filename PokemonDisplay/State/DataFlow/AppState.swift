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
        
        
        
        //calclated values
        var sortdPokemonList: [PokemonViewModel] {
            guard let pokemonDic = pokemonsDic else { return [] }
            return pokemonDic.keys.sorted(by: < ).reduce(into: []) { $0 = $0 + [pokemonDic[$1]!] }
        }
        
        var homeViewLoadStatusString: String {
            guard let pokeDic = pokemonsDic else {
                return "Load"
            }
            switch (currentlyLoadingPokemons, pokeDic.count > 0 ) {
            case (true, _):
                return "Loading"
            case (false, true):
                return "Reload"
            case (false, false):
                print("unexpected case in homeViewLoadStatusString")
                return "Load"
            }
        }
        
        //Data
        @FileStorage(directory: .cachesDirectory,
                     fileName: kJsonFileNames.pokemonJsonFileName)
        var pokemonsDic: [Int: PokemonViewModel]?
        
    }
}
