//
//  PokemonViewModel.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/9/21.
//

import SwiftUI
import Kingfisher


struct PokemonViewModel: Identifiable, Codable {
    
    var id: Int {
        pokemonDataModel.id
    }
    
    var name: String {
        pokemonDataModel.species.name
    }
        
    var imageURL: URL? {
        
        guard let imageURLString = pokemonDataModel.sprites.frontDefault,
              let imageURL = URL(string: imageURLString) else {
            print("invalid image url for \(pokemonDataModel.id)")
            return nil
        }
        return imageURL
    }
    
    //Data
    let pokemonDataModel: PokemonDataModel
    
}
