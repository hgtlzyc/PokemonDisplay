//
//  StateControlCenter.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

enum StateCenterSubType: Hashable, CaseIterable{
    case loadingPokemon
}


class StateCenter: ObservableObject {
    @Published var appState = AppStates()
    
    var subscriptions = [StateCenterSubType : Set<AnyCancellable>]()
    
    init() {
        cancelAndResetSubscritions(types: StateCenterSubType.allCases)
    }
    
    
    func executeAction(_ action: AppAction) {
       // print("[action] start \(action)")
        let result = self.reduce(state: self.appState, action: action)
        self.appState = result.newState
        guard let command = result.newCommand else { return }
       // print("[command] start command \(command)")
        command.execute(in: self)
    }
    
    private func cancelAndResetSubscritions(types: [StateCenterSubType]) {
        types.forEach { subType in
            subscriptions[subType]?.forEach{$0.cancel()}
            subscriptions[subType] =  Set<AnyCancellable>()
        }
    }
    
    private func reduce(state: AppStates, action: AppAction) -> (newState: AppStates, newCommand: AppCommand?) {
        var appState = state
        var appCommand: AppCommand? = nil
        
        switch action {
        case .reloadAllPokemons(let range) :
            if appState.pokemonListState.currentlyLoadingPokemons {
                print("[ACTION] load break in reload all")
                break
            }
            appState.pokemonListState.targetPokemonRange = PokemonIndexRange(lowerBound: range.lowerBound, upperInclusiveBound: range.upperBound)
            appState.pokemonListState.pokemonsDic = nil
            appState.pokemonListState.currentlyLoadingPokemons = true
            appState.pokemonListState.loadPokemonError = nil
            appCommand = ReloadALLPokemonsCommand(closedIndexRange: range)
            
        case .loadSelectedPokemons(let indexSet):
            guard !appState.pokemonListState.currentlyLoadingPokemons else {
                print("[ACTION] load break in load missing")
                break
            }
            
            guard let targetRange = appState.pokemonListState.targetPokemonRange,
                  let indexSet = indexSet,
                  Set((targetRange.lowerBound...targetRange.upperInclusiveBound)).isStrictSuperset(of: indexSet) else {
                appState.pokemonListState.loadPokemonError = .selectedIndexNotInRange(index: indexSet?.first)
                break
            }
            
            appState.pokemonListState.currentlyLoadingPokemons = true
            appState.pokemonListState.loadPokemonError = nil
            appCommand = LoadSelectedPokemonsCommand(selectedIndexesSet: indexSet)
            
            
        case let .receivedPokemons( result, isFinished):
            appState.pokemonListState.currentlyLoadingPokemons = !isFinished
            guard let result = result else { break }
            switch result {
            case .failure(let error):
                print(error)
                appState.pokemonListState.loadPokemonError = error
            case .success(let pokemonViewModelDic):
                appState.pokemonListState.pokemonsDic = pokemonViewModelDic
            }
            
        case .cancelPokemonLoading:
            guard appState.pokemonListState.currentlyLoadingPokemons else { break }
            cancelAndResetSubscritions(types: [.loadingPokemon])
            appState.pokemonListState.currentlyLoadingPokemons = false
            
        case .deletePokemonCache:
            appState.pokemonListState.pokemonsDic = nil
            
        }
        
        return (newState: appState, newCommand: appCommand)
    }
        
}

