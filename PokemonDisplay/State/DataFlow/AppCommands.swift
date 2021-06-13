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


struct ReloadALLPokemonsCommand: AppCommand {
    let closedIndexRange : ClosedRange<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        switch kCurrentEnvironment.networkEnvironment{
        case .realAPI:
            if let processor = PokemonLoadingPressor(controlled: true, maxTasks: 1, delayInSeconds: 0.1) {
                processor.process(in: stateCenter, targetRange: closedIndexRange, reloadAll: true)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate RealAPI in reload all command")
                print("unable Load pressor")
            }
            
        case .simulator:
            if let processor = SimulatorPokemonLoadingProcess(maxTasks: 2, delayInSeconds: 0.2) {
                processor.process(in: stateCenter, sourceCollection: closedIndexRange, reloadAll: true)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate Simulator in reload all command")
            }
        }
    }
}


struct LoadSelectedPokemonsCommand: AppCommand {
    let selectedIndexesSet: Set<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        switch kCurrentEnvironment.networkEnvironment{
        case .realAPI:
            if let processor = PokemonLoadingPressor(controlled: true, maxTasks: 1, delayInSeconds: 0.1) {
                processor.process(in: stateCenter, selectedSet: selectedIndexesSet, reloadAll: false)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate realAPI in reload all command")
                print("unable Load pressor")
            }
        case .simulator:
            if let processor = SimulatorPokemonLoadingProcess(maxTasks: 2, delayInSeconds: 0.2) {
                processor.process(in: stateCenter, sourceCollection: selectedIndexesSet, reloadAll: false )
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate Simulator in load selected command")
            }
        }
    }
}



