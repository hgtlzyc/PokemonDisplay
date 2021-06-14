//
//  AdjustTargetRangeCommand.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/14/21.
//

import Foundation

struct AdjustTargetRangeCommand: AppCommand {
    let newTargetLowerBound: Int?
    let newTargetUpperInculsiveBound: Int?
    
    init(_ lowerTarget: Int?, _ upperInclusiveTarget: Int?) {
        self.newTargetLowerBound = lowerTarget
        self.newTargetUpperInculsiveBound = upperInclusiveTarget
    }
    
    func execute(in stateCenter: StateCenter) {
        if let currentTarget = stateCenter.appState.pokemonListState.targetPokemonRange {
            
            switch (newTargetLowerBound, newTargetUpperInculsiveBound) {
            case let (.some( newLowerBound ), .some( newUpperBound ) ):
                guard Set((1...kAPIConstants.pokemonUpperInclusiveBound)).isStrictSuperset(of: Set((newLowerBound...newUpperBound))) else {
                    print("[Command]bound reached in AdjustTargetRangeCommand")
                    break
                }
                let newRange = PokemonIndexRange(
                    lowerBound: newLowerBound,
                    upperInclusiveBound: newUpperBound
                )
                stateCenter.appState.pokemonListState.targetPokemonRange = newRange
                
            case let ( nil, .some( newUpperBound ) ):
                guard (1...kAPIConstants.pokemonUpperInclusiveBound).contains(newUpperBound) else {
                    //print("[Command]bound\(newUpperBound) reached in AdjustTargetRangeCommand")
                    break
                }
                
                let newRange = PokemonIndexRange(
                    lowerBound: currentTarget.lowerBound,
                    upperInclusiveBound: newUpperBound
                )
                
                stateCenter.appState.pokemonListState.targetPokemonRange = newRange
                
            case let (.some( newLowerBound ), nil ):
                guard (1...kAPIConstants.pokemonUpperInclusiveBound).contains(newLowerBound) else {
                    //print("[Command]bound \(newLowerBound)reached in AdjustTargetRangeCommand")
                    break
                }
                let newRange = PokemonIndexRange(
                    lowerBound: newLowerBound,
                    upperInclusiveBound: currentTarget.upperInclusiveBound
                )
                stateCenter.appState.pokemonListState.targetPokemonRange = newRange
                
            case (nil, nil):
                break
            }
        } else {
            print("[Command]Unexpect behivor in AdjustTargetRangeCommand")
        }
    }
}
