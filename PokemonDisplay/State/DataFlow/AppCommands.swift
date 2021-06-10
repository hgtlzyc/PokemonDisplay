//
//  AppCommands.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation
import Combine

protocol AppCommand {
    func execute(in stateCenter: StateCenter)
}

struct LoadPokemonsCommand: AppCommand {
    func execute(in stateCenter: StateCenter) {
        let subscritionToken = [(1,"picapica"), (2,"dragon"), (3, "bird")]
            .publisher
            .flatMap(maxPublishers: .max(1) ) { tuple in
                Just(tuple).delay(for: .seconds(2) , scheduler: DispatchQueue.global(qos: .userInitiated) )
                    
            }
            .scan([(0,"")]) { $0 + [$1] }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { tupleArray in
                let viewModelArray = Array(tupleArray[1...]).map {
                    PokemonViewModel(
                        dataModel:
                            PokemonDataModel(id: $0.0, name: $0.1)
                    )
                }
                stateCenter.executeAction(
                    .receivedPokemons(
                        .success(
                            viewModelArray
                        )
                    )
                )
            }
        
        stateCenter.subscriptions[UUID()] = subscritionToken
        
    }
}
