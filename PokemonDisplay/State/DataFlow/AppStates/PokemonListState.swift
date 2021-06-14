//
//  PokemonListState.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/11/21.
//

import Foundation

//PokemonList State

struct PokemonListState {
    
    //MARK: - Data
    @FileStorage(directory: .cachesDirectory,
                 fileName: kJsonFileNames.pokemonRangeJsonFileName)
    var targetPokemonRange : PokemonIndexRange?
    
    @FileStorage(directory: .cachesDirectory,
                 fileName: kJsonFileNames.pokemonsJsonFileName)
    var pokemonsDic: [Int: PokemonViewModel]?
    
    
    //MARK: - States
    var loadPokemonError: AppError?
    var currentlyLoadingPokemons = false
    
    var currentPokemonsCount: Int? {
        guard let count = pokemonsDic?.count else { return nil }
        return count
    }
    
    //MARK: - Range Display related
    var upperPokemonsLimit: Int {
        guard let upperBound = targetPokemonRange?.upperInclusiveBound else {
            return 30
        }
        guard upperBound <= kAPIConstants.pokemonUpperInclusiveBound else {
            return kAPIConstants.pokemonUpperInclusiveBound
        }
        return upperBound
    }
    
    //MARK: - load missing related
    var loadMissingButtonString: String? {
        guard let missingSet = missingIndexSet else { return nil }
        
        switch missingSet.first {
        case nil :
            return nil
        default:
            return "Click to Load the missing \(missingSet.count) Pokemons" 
        }
    }
    
    var missingIndexSet: Set<Int>? {
        guard let lower = targetPokemonRange?.lowerBound,
              let upper = targetPokemonRange?.upperInclusiveBound,
              currentlyLoadingPokemons == false else {
            return nil
        }
        
        let targetIndexes = Set(lower...upper)
        let loadedIndexes = pokemonsDic?.values.map{$0.id}
        
        guard let loadedIndexs = loadedIndexes else { return nil }
        return targetIndexes.subtracting(loadedIndexs)
    }
    
    //MARK: - progress bar related
    var progressTextString: String? {
        guard let progress = currentLoadProgress else { return nil }
        let percent = progress * 100
        switch percent {
        case let x where x == 100.0:
            guard let lower = targetPokemonRange?.lowerBound,
                  let upper = targetPokemonRange?.upperInclusiveBound else {
                return nil
            }
            return "\(lower) to \(upper) All Loaded"
        case let x where x <= 0.0:
            return nil
        default:
            return String(Int(percent)) + "%"
        }
    }
    
    var currentLoadProgress: Double? {
        get{
            return PokemonListProgressTracker(targetPokemonRange?.lowerBound, targetPokemonRange?.upperInclusiveBound, sortedAndFilteredPokemonList.count)?.currentProgress
        }
    }
    
    var shouldShowProgressBar: Bool {
        guard let progress = currentLoadProgress else { return false }
        return currentlyLoadingPokemons || (progress != 1.0)
    }
    
    //MARK: - buttons display logic related
    var buttonShouldDisplayLoading: Bool {
        currentlyLoadingPokemons
    }
    
    var homeViewLoadStatusString: String {
        guard let pokeDic = pokemonsDic else {
            return "Load All"
        }
        switch (currentlyLoadingPokemons, pokeDic.count > 0 ) {
        case (true, _):
            return "Loading..."
        case (false, true):
            return "Reload All"
        case (false, false):
            print("unexpected case in homeViewLoadStatusString")
            return "Load All"
        }
    }
    
    var sortedAndFilteredPokemonList: [PokemonViewModel] {
        guard let pokemonDic = pokemonsDic else { return [] }
        let sortedList = pokemonDic.keys.sorted(by: < ).reduce(into: []) { $0 = $0 + [pokemonDic[$1]!] }
        guard let lowerBound = targetPokemonRange?.lowerBound,
              let higherBound = targetPokemonRange?.upperInclusiveBound else {
            return sortedList
        }
        
        guard lowerBound <= higherBound else { return [] }
        let sortedAndFilteredList = sortedList.filter{ (lowerBound...higherBound).contains($0.id) }
        
        return sortedAndFilteredList
    }
    
}

