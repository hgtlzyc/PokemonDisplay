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
    static let networkEnvironment: kDevelopmentEnvironment = .realAPI
    
    //Limit the calls to API
    static let maxTasksBackPressure: Int = 1
    static let delayInSecondsBackPressure: Double = 0.1
    
}
