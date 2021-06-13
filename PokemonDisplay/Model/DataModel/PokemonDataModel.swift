//
//  PokemonDataModel.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/9/21.
//

import Foundation

struct PokemonDataModel: Codable {
    struct PokemonAPIResult: Codable {
        let name: String
        let url:String
    }
    
    let results: [PokemonAPIResult]
    
}
