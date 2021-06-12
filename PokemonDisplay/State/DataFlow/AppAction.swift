//
//  AppAction.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

enum AppAction {
    case deletePokemonCache
    case cancelPokemonLoading
    case reloadAllPokemons(withIndexRange: ClosedRange<Int>)
    case loadSelectedPokemons(withIndexSet: Set<Int>?)
    case receivedPokemons(Result<[Int:PokemonViewModel], AppError>?, isFinished: Bool)
}
