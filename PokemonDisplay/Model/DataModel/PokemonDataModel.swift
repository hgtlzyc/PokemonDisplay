//
//  PokemonDataModel.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/9/21.
//

import Foundation

struct PokemonDataModel: Codable {
    let id: Int
    let species: SpeciesContainer
    let sprites: SpritesContainer
    
    internal struct SpritesContainer: Codable {
        let frontDefault: String?
    }
    
    internal struct SpeciesContainer: Codable {
        let name: String
        let url: String
    }
    
}
