//
//  ReloadAllPokemonsCommand.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/14/21.
//

import Foundation

struct ReloadALLPokemonsCommand: AppCommand {
    let closedIndexRange : ClosedRange<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        switch kCurrentEnvironment.networkEnvironment{
        case .realAPI:
            if let processor = PokemonLoadingProcessor (
                controlled: true,
                maxTasks: kCurrentEnvironment.maxTasksBackPressure,
                delayInSeconds: kCurrentEnvironment.delayInSecondsBackPressure
            ) {
                processor.process(in: stateCenter, targetRange: closedIndexRange, reloadAll: true)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate RealAPI in reload all command")
                print("unable Load pressor")
            }
            
        case .simulator:
            if let processor = SimulatorPokemonLoadingProcess(
                maxTasks: 2,
                delayInSeconds: 0.5
            ) {
                processor.process(in: stateCenter, sourceCollection: closedIndexRange, reloadAll: true)
            } else {
                stateCenter.appState.pokemonListState.loadPokemonError = .unableInitiateProcessor("unable initiate Simulator in reload all command")
            }
        }
    }
}

