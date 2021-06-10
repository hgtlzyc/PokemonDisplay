//
//  StateControlCenter.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

class StateCenter: ObservableObject {
    @Published var appState = AppState()
    
    
    func executeAction(_ action: AppAction) {
        //print("[action] starting \(action)")
        
        let result = StateCenter.reduce(state: self.appState, action: action)
        self.appState = result.newState
        guard let command = result.newCommand else { return }
        print("[command] start command \(command)")
        command.execute(in: self)
    }
    
    
    private static func reduce(state: AppState, action: AppAction) -> (newState: AppState, newCommand: AppCommand?) {
        var appState = state
        var appCommand: AppCommand? = nil
        
        switch action {
        case .loadPokemons:
            if appState.pokemonListState.currentlyLoadingPokemons {
                break
            }
            appState.pokemonListState.loadPokemonError = nil
            appState.pokemonListState.currentlyLoadingPokemons = true
            appCommand = LoadPokemonsCommand()
            
        case .receivedPokemons(let result):
            appState.pokemonListState.currentlyLoadingPokemons = false
            switch result {
            case .failure(let error):
                appState.pokemonListState.loadPokemonError = error
            case .success(let pokemonViewModelArray):
                print(pokemonViewModelArray)
            //appState.pokemonListState.pokemonsDic =
            }
        }
        
        return (newState: appState, newCommand: appCommand)
    }
    
    //Subscritions related
    var subscriptions = [UUID : AnyCancellable]()
    
}

