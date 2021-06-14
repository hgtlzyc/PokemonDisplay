//
//  LoadSelectedPokemonsCommand.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/14/21.
//

import Foundation

struct LoadSelectedPokemonsCommand: AppCommand {
    let selectedIndexesSet: Set<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        switch kCurrentEnvironment.networkEnvironment{
        case .realAPI:
            if let processor = PokemonLoadingProcessor(controlled: true, maxTasks: kCurrentEnvironment.maxTasksBackPressure, delayInSeconds: kCurrentEnvironment.delayInSecondsBackPressure
            ) {
                processor.process(in: stateCenter, selectedSet: selectedIndexesSet, reloadAll: false)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate realAPI in reload all command")
                print("unable Load pressor")
            }
        case .simulator:
            if let processor = SimulatorPokemonLoadingProcess(maxTasks: 2, delayInSeconds: 0.5
            ) {
                processor.process(in: stateCenter, sourceCollection: selectedIndexesSet, reloadAll: false )
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate Simulator in load selected command")
            }
        }
    }
}


