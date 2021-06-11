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
    case loadPokemons(withIndexRange: ClosedRange<Int>)
    case receivedPokemons(Result<[Int:PokemonViewModel], AppError>?, isFinished: Bool)
}
