//
//  AppCommands.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

protocol AppCommand {
    func execute(in stateCenter: StateCenter)
}


//Will be replaced with network calls in the end
struct ReloadALLPokemonsCommand: AppCommand {
    let closedIndexRange : ClosedRange<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        switch kCurrentEnvironment.networkEnvironment{
        case .realAPI:
            break
        case .simulator:
            if let processor = SimulatorPokemonLoadingProcess(maxTasks: 2, delay: 0.2) {
                processor.process(in: stateCenter, sourceCollection: closedIndexRange, reloadAll: true)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate Simulator in reload all command")
            }
        }
    }
}

//Will be replaced with network calls in the end
struct LoadSelectedPokemonsCommand: AppCommand {
    let selectedIndexesSet: Set<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        switch kCurrentEnvironment.networkEnvironment{
        case .realAPI:
            break
        case .simulator:
            if let processor = SimulatorPokemonLoadingProcess(maxTasks: 2, delay: 0.2) {
                processor.process(in: stateCenter, sourceCollection: selectedIndexesSet, reloadAll: false )
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate Simulator in load selected command")
            }
        }
    }
}



