//
//  StateControlCenter.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Combine

class StateCenter: ObservableObject {
    @Published var appState = AppState()
    
    func tempDebugPrintInStateCenter(_ string: String){
        print(string)
    }
    
    func executeAction(_ action: AppAction) {
        print("starting \(action)")
        let result = StateCenter.reduce(state: self.appState, action: action)
        self.appState = result.newState
        guard let command = result.newCommand else { return }
        print("start command \(command)")
        command.execute(in: self)
    }
    
    
    static func reduce(state: AppState, action: AppAction) -> (newState: AppState, newCommand: AppCommand?) {
        var appState = state
        var appCommand: AppCommand? = nil
        
        switch action {
        case .loadPokemons:
            appCommand = LoadPokemonsCommand()
            appState.currentStatus = "loadPokemons"
        }
        
        return (newState: appState, newCommand: appCommand)
    }
    
}

