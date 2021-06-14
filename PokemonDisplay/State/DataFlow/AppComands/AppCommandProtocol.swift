//
//  AppCommandProtocol.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

protocol AppCommand {
    func execute(in stateCenter: StateCenter)
}


