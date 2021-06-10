//
//  AppAction.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

enum AppAction {
    
    case loadPokemons
    case receivedPokemons(Result<[PokemonViewModel], AppError>)
}
