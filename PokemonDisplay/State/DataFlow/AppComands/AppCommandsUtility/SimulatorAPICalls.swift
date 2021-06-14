//
//  SimulatorAPICalls.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/13/21.
//

import Foundation
import Combine

//For Testing
struct SimulatorPokemonLoadingProcess {
    let maxTasks: Int
    let delayInSeconds: Double
    
    init?( maxTasks: Int, delayInSeconds: Double) {
        //set the back pressure Limits here
        guard maxTasks > 0 && delayInSeconds > 0 else {return nil}
        self.maxTasks = maxTasks
        self.delayInSeconds = delayInSeconds
    }
    
    func process <C: Collection>(in stateCenter: StateCenter, sourceCollection: C, reloadAll: Bool) -> Void where C.Element == Int{
        var baseArray = [(Int,String)]()
        if reloadAll == false, let currentBaseDic = stateCenter.appState.pokemonListState.pokemonsDic {
            baseArray = currentBaseDic.map{($0, $1.name)}
        }
        
        //simulate network calls with random arrive time
        let stringBase = ["picapica", "dragon", "bird", "cat", "dog"]
        let tupleBaseArray = Array(sourceCollection)
            .map { ( $0, (stringBase.randomElement() ?? "nobase") + "   \($0)") }
            .shuffled()
        
        tupleBaseArray
            .publisher
            //backpressure management
            .flatMap(maxPublishers: .max(maxTasks) ) { tuple in
                Just(tuple).delay(for: .seconds(delayInSeconds) , scheduler: DispatchQueue(label: "\(tuple.0)") )
            }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .scan(baseArray) { $0 + [$1] }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: {
                stateCenter.executeAction(
                    .receivedPokemons(.failure(.subscriptionCancelled), isFinished: true)
                )
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
                    result[nextTuple.0] =
                        PokemonViewModel(
                            pokemonDataModel:
                                PokemonDataModel(id: nextTuple.0, species: PokemonDataModel.SpeciesContainer(name: nextTuple.1, url: "n"),
                                    sprites: PokemonDataModel.SpritesContainer(frontDefault: nil))
                        )
                }
                
                stateCenter.executeAction(
                    .receivedPokemons( .success(viewModelDic) ,isFinished: false)
                )
            })
            .store(in: &stateCenter.subscriptions[.loadingPokemonDM]!)
    }

}
