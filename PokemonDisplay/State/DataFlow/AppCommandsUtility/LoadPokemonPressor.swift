//
//  LoadPokemonPressor.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/12/21.
//

import Foundation
import Combine

//Real API
struct PokemonLoadingPressor {
    let maxTasks: Int?
    let delayInSeconds: Double?
    let controlled: Bool
    
    init?(controlled: Bool, maxTasks: Int?, delayInSeconds: Double?) {
        switch controlled {
        case true:
            guard let maxTasks = maxTasks,
                  let delayInSeconds = delayInSeconds,
                  maxTasks > 0 && delayInSeconds >= 0 else {return nil}
            self.controlled = true
            self.maxTasks = maxTasks
            self.delayInSeconds = delayInSeconds
        case false:
            self.controlled = false
            self.maxTasks = kAPIURLs.maxBackPressureLimit
            self.delayInSeconds = 0
        }
    }
    
    func process (in stateCenter: StateCenter, targetRange: ClosedRange<Int>, reloadAll: Bool) -> Void {
        let urlRangeBaseString = kAPIURLs.urlBaseForRangeOfPokemons(limit: targetRange.count, offset: targetRange.lowerBound)
        
        if reloadAll == false, let currentBaseDic = stateCenter.appState.pokemonListState.pokemonsDic {
            baseArray = currentBaseDic.map{($0, $1.name ?? "no name")}
        }
        
        //simulates indivual API calls
        let passThrough = PassthroughSubject<PokemonDataModel.PokemonAPIResult,Never>()
        
        do {
            let publisher = try generatePokemonResultsPublisher(urlRangeBaseString)
            publisher
                .handleEvents(receiveCancel: {
                    stateCenter.executeAction(
                        .receivedPokemons(
                            .failure(.subscriptionCancelled),
                            isFinished: true
                        )
                    )
                })
                .sink { completion in
                    switch completion {
                    case .finished:
                        passThrough.send(completion: .finished)
                    case .failure(let error):
                        stateCenter.executeAction(
                            .receivedPokemons(
                                .failure(.networkError(error)),
                                isFinished: true
                            )
                        )
                    }
                } receiveValue: { array in
                    print(array.count)
                    array.forEach { pokemonResult in
                        passThrough.send(pokemonResult)
                    }
                }
                .store(in: &stateCenter.subscriptions[.loadingPokemon]!)
        } catch let error {
            stateCenter.executeAction(.receivedPokemons(.failure(.networkError(error)), isFinished: true))
        }
        
        passThrough
            .flatMap(maxPublishers: .max(maxTasks ?? 1)) { result in
                Just(result).delay(for: .seconds(delayInSeconds ?? 0), scheduler: DispatchQueue(label: result.url))
            }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .scan(baseArray) { $0 + [$1] }
            .receive(on: DispatchQueue.main)
            
            
            
        
        
        
    }
    
    func process (in stateCenter: StateCenter, selectedSet: Set<Int>, reloadAll: Bool) -> Void {

            
    }
    
    private func generatePokemonResultsPublisher(_ urlString: String) throws -> AnyPublisher<[PokemonDataModel.PokemonAPIResult], AppError> {
        guard let url = URL(string: urlString) else {
            throw AppError.inValidURL("invaild url: \(urlString)")
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map{$0.data}
            .decode(type: PokemonDataModel.self, decoder: FileHelper.appDecoder)
            .map {$0.results}
            .mapError{ AppError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
}



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
            baseArray = currentBaseDic.map{($0, $1.name ?? "no name")}
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
                            id: nextTuple.0,
                            pokemonDataModel:
                                PokemonDataModel(
                                     results: [PokemonDataModel.PokemonAPIResult(name: nextTuple.1, url: nextTuple.1)]
                                )
                        )
                }
                
                stateCenter.executeAction(
                    .receivedPokemons( .success(viewModelDic) ,isFinished: false)
                )
            })
            .store(in: &stateCenter.subscriptions[.loadingPokemon]!)
    }

}
