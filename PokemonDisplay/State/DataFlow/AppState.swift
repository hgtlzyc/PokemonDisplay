//
//  AppState.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

struct AppState {
    var pokemonListState = PokemonListState()
}

//PokemonList State
extension AppState {
    struct PokemonListState {
        
        //States
        @FileStorage(directory: .cachesDirectory,
                     fileName: kJsonFileNames.pokemonRangeJsonFileName)
        var pokemonRange : PokemonIndexRange?
        
        //var listLowerBound: Int?
        //var listUpperInclusiveBound: Int?
        
        var loadPokemonError: AppError?
        var currentlyLoadingPokemons = false
        
        var currentValuesCount: Int? {
            guard let count = pokemonsDic?.count else { return nil }
            return count
        }
        
        //load missing related
        var shouldShowLoadRestButton: Bool {
            guard let progress = currentLoadProgress else { return false }
            switch progress {
            case let x where x == 0 || x == 100:
                return false
            default:
                return true
            }
        }
        
        var missingIndexSet: Set<Int>? {
            guard let lower = pokemonRange?.lowerBound,
                  let upper = pokemonRange?.upperInclusiveBound,
                  currentlyLoadingPokemons == false else {
                return nil
            }
            
            let targetIndexes = Set(lower...upper)
            let loadedIndexes = pokemonsDic?.values.compactMap{$0.id}
            
            guard let loadedIndexArray = loadedIndexes else { return nil }
            return targetIndexes.subtracting(loadedIndexArray)
        }
        
        //progress bar related
        var progressTextString: String? {
            guard let progress = currentLoadProgress else { return nil }
            let percent = progress * 100
            switch percent {
            case let x where x == 100:
                guard let lower = pokemonRange?.lowerBound,
                      let upper = pokemonRange?.upperInclusiveBound else {
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
                return PokemonListStateTracker(pokemonRange?.lowerBound, pokemonRange?.upperInclusiveBound, currentValuesCount)?.currentProgress
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
                     fileName: kJsonFileNames.pokemonsJsonFileName)
        var pokemonsDic: [Int: PokemonViewModel]?
        
    }
}
