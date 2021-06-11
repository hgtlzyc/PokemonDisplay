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
    
    let closedIndexRange : ClosedRange<Int>
    
    func execute(in stateCenter: StateCenter) {
        
        //simulate network calls with random arrive time
        let stringBase = ["picapica", "dragon", "bird", "cat", "dog"]
        let tupleBaseArray = Array(closedIndexRange)
            .map { ( $0, (stringBase.randomElement() ?? "nobase") + "   \($0)") }
            .shuffled()
        
        tupleBaseArray
            .publisher
            //backpressure management
            .flatMap(maxPublishers: .max(2) ) { tuple in
                Just(tuple).delay(for: .seconds(0.1) , scheduler: DispatchQueue.global(qos: .background) )
                    
            }
            .scan([(Int,String)]()) { $0 + [$1] }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: {
                print("cancelled")
            })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    stateCenter.executeAction(
                        .receivedPokemons( nil ,isFinished: true)
                    )
                }
            }, receiveValue: { tupleArray in
                let viewModelDic = tupleArray.reduce(into: [Int: PokemonViewModel]()) { result, nextTuple in
                    result[nextTuple.0] = PokemonViewModel(dataModel: PokemonDataModel(id: nextTuple.0, name: nextTuple.1))
                }
                
                stateCenter.executeAction(
                    .receivedPokemons( .success(viewModelDic) ,isFinished: false)
                )
            })
            .store(in: &stateCenter.subscriptions[.loadingPokemon]!)
    }
}
