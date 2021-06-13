//
//  PokemonViewModel.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/9/21.
//

import SwiftUI


struct PokemonViewModel: Identifiable, Codable {
    //Values
    let id: Int
    
    //Data
    let pokemonDataModel: PokemonDataModel
    
    var name: String? {
        pokemonDataModel.results.first?.name
    }
    
}
