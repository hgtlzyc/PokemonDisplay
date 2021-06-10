//
//  PokemonViewModel.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/9/21.
//

import SwiftUI


struct PokemonViewModel: Identifiable, Codable {
    //Data
    let pokemonDataModel: PokemonDataModel
    
    //Values
    var id: Int {
        pokemonDataModel.id
    }
    var name: String {
        pokemonDataModel.name
    }
    
    init(dataModel: PokemonDataModel) {
        self.pokemonDataModel = dataModel
    }
    
}
