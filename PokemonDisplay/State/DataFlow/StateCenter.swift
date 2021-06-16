//
//  StateControlCenter.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

enum StateCenterSubType: Hashable, CaseIterable{
    case loadingPokemonDM
}

class StateCenter: ObservableObject {
    @Published var appState = AppStates()
    
    var subscriptions = [StateCenterSubType : Set<AnyCancellable>]()
    
    init() {
        cancelAndResetSubscritions(types: StateCenterSubType.allCases)
    }
            
    func executeAction(_ action: AppAction) {
        DispatchQueue.main.async {
            let result = self.reduce(state: self.appState, action: action)
            self.appState = result.newState
            guard let command = result.newCommand else { return }
            command.execute(in: self)
        }
    }
    
    private func reduce(state: AppStates, action: AppAction) -> (newState: AppStates, newCommand: AppCommand?) {
        var appState = state
        var appCommand: AppCommand? = nil
        
        switch action {
        //MARK: user preference related
        case let .adjustTargetRange(newlowerBound, newUpperInclusiveBound):
            appCommand = AdjustTargetRangeCommand(
                newlowerBound, newUpperInclusiveBound
            )
        
        //MARK: Cache Related
        case .deletePokemonViewModelCache:
            //property wrapper will clean the cache
            appState.pokemonListState.pokemonsDic = nil
            
        //MARK: - loading PokemonDM related
        case let .receivedPokemons( result, isFinished):
            appState.pokemonListState.currentlyLoadingPokemons = !isFinished
            guard let result = result else { break }
            switch result {
            case .failure(let error):
                print(error, Date().description(with: .current))
                appState.pokemonListState.loadPokemonError = error
            case .success(let pokemonViewModelDic):
                appState.pokemonListState.pokemonsDic = pokemonViewModelDic
            }
        
        case .cancelPokemonLoading:
            guard appState.pokemonListState.currentlyLoadingPokemons else { break }
            cancelAndResetSubscritions(types: [.loadingPokemonDM])
            appState.pokemonListState.currentlyLoadingPokemons = false
        
        
        case .reloadAllPokemons(let range) :
            if appState.pokemonListState.currentlyLoadingPokemons {
                break
            }
            appState.pokemonListState.targetPokemonRange = PokemonIndexRange(lowerBound: range.lowerBound, upperInclusiveBound: range.upperBound, changeFrom: .lower)
            appState.pokemonListState.pokemonsDic = nil
            appState.pokemonListState.currentlyLoadingPokemons = true
            appState.pokemonListState.loadPokemonError = nil
            appCommand = ReloadALLPokemonsCommand(closedIndexRange: range)
            
        case .loadSelectedPokemons(let indexSet):
            guard !appState.pokemonListState.currentlyLoadingPokemons else {
                break
            }
            
            guard let indexSet = indexSet else {
                appState.pokemonListState.loadPokemonError = .selectedIndexSetNotExpected(index: indexSet?.first)
                break
            }
            
            appState.pokemonListState.currentlyLoadingPokemons = true
            appState.pokemonListState.loadPokemonError = nil
            appCommand = LoadSelectedPokemonsCommand(selectedIndexesSet: indexSet)
            
        }
        
        return (newState: appState, newCommand: appCommand)
    }
        
    private func cancelAndResetSubscritions(types: [StateCenterSubType]) {
        types.forEach { subType in
            subscriptions[subType]?.forEach{$0.cancel()}
            subscriptions[subType] =  Set<AnyCancellable>()
        }
    }
}

