//
//  StateControlCenter.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Combine

class StateCenter: ObservableObject {
    @Published var appState = AppState()
}

