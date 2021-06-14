//
//  AppAction.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

enum AppAction {
    
    //user preference related
    case adjustTargetRange(lowerTo:Int? , upperInclusiveTo:Int?)
    
    //Cache Related
    case deletePokemonViewModelCache
    
    //loading reloading related
    case receivedPokemons(Result<[Int:PokemonViewModel], AppError>?, isFinished: Bool)
    case cancelPokemonLoading
    case reloadAllPokemons(withIndexRange: ClosedRange<Int>)
    case loadSelectedPokemons(withIndexSet: Set<Int>?)
}
