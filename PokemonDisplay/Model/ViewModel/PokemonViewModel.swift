//
//  PokemonViewModel.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/9/21.
//

import SwiftUI


struct PokemonViewModel: Identifiable, Codable {
    
    var id: Int {
        pokemonDataModel.id
    }
    
    var name: String {
        pokemonDataModel.species.name
    }
    
    //Data
    let pokemonDataModel: PokemonDataModel
    
}
