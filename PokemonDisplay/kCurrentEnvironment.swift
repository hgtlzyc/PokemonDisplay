//
//  kCurrentEnvironment.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/13/21.
//

import Foundation


struct kCurrentEnvironment {
    enum kDevelopmentEnvironment {
        case simulator
        case realAPI
    }
    static let networkEnvironment: kDevelopmentEnvironment = .simulator
}
