//
//  AppCommands.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Combine

protocol AppCommand {
    func execute(in stateCenter: StateCenter)
}

struct LoadPokemonsCommand: AppCommand {
    func execute(in stateCenter: StateCenter) {
        stateCenter.tempDebugPrintInStateCenter("load pokemond command running")
    }
}
