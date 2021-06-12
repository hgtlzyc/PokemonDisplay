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
        var listLowerBound: Int?
        var listUpperInclusiveBound: Int?
        var loadPokemonError: AppError?
        var currentlyLoadingPokemons = false
        
        var currentValuesCount: Int? {
            guard let count = pokemonsDic?.count else { return nil }
            return count
        }
        
        //progress bar related
        var progressTextString: String? {
            guard let progress = currentLoadProgress else { return nil }
            let percent = progress * 100
            switch percent {
            case let x where x == 100:
                guard let lower = listLowerBound,
                      let upper = listUpperInclusiveBound else {
                    return "All Finished"
                }
                return "\(lower) to \(upper) All Finished"
            case let x where x == 0.0:
                return nil
            default:
                return String(Int(percent)) + "%"
            }
        }
        
        var currentLoadProgress: Double? {
            get{
                return PokemonListStateTracker(listLowerBound, listUpperInclusiveBound, currentValuesCount)?.currentProgress
            }
        }
        
        var shouldShowProgressBar: Bool {
            guard let progress = currentLoadProgress else { return false }
            return currentlyLoadingPokemons || (progress != 1.0)
        }
        
        //buttons related
        var buttonShouldDisplayLoading: Bool {
            currentlyLoadingPokemons
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
        
        
        //calclated data values
        var sortdPokemonList: [PokemonViewModel] {
            guard let pokemonDic = pokemonsDic else { return [] }
            return pokemonDic.keys.sorted(by: < ).reduce(into: []) { $0 = $0 + [pokemonDic[$1]!] }
        }
        
        
        //Data
        @FileStorage(directory: .cachesDirectory,
                     fileName: kJsonFileNames.pokemonJsonFileName)
        var pokemonsDic: [Int: PokemonViewModel]?
        
    }
}
