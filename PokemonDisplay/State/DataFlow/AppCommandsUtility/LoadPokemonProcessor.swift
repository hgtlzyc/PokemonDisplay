//
//  LoadPokemonProcessor.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/12/21.
//

import Foundation
import Combine

//Real API
struct PokemonLoadingProcessor {
    let maxTasks: Int
    let delayInSeconds: Double
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
            self.maxTasks = kAPIConstants.maxBackPressureLimit
            self.delayInSeconds = 0
        }
    }
    
    func process (in stateCenter: StateCenter, targetRange: ClosedRange<Int>, reloadAll: Bool) -> Void {
        let baseUrlStrings = targetRange.map { index in
            kAPIConstants.urlBaseForSinglePokemon(index: index)
        }

        changeStateCenterBasedOnURLArray(in: stateCenter,
                             urlStringArray: baseUrlStrings,
                             reloadAll: reloadAll)
        
    }
    
    func process (in stateCenter: StateCenter, selectedSet: Set<Int>, reloadAll: Bool) -> Void {
        let baseUrlStrings = selectedSet.map { index in
            kAPIConstants.urlBaseForSinglePokemon(index: index)
        }

        changeStateCenterBasedOnURLArray(in: stateCenter,
                             urlStringArray: baseUrlStrings,
                                reloadAll: reloadAll)
    }
    
    private func changeStateCenterBasedOnURLArray(in stateCenter: StateCenter, urlStringArray: [String], reloadAll: Bool) {
        
        var baseViewModelArray = [PokemonViewModel]()
        
        if reloadAll == false, let currentBaseDic = stateCenter.appState.pokemonListState.pokemonsDic {
            baseViewModelArray = currentBaseDic.map{$0.value}
        }
        
        urlStringArray
            .publisher
            .flatMap(maxPublishers: .max(maxTasks)) { urlString -> AnyPublisher<PokemonDataModel, AppError> in
                do {
                    let publisher = try generateSinglePokemonDMPublisher(urlString)
                    return publisher
                        .delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue(label: urlString))
                        .eraseToAnyPublisher()
                    
                } catch let err {
                    return Fail<PokemonDataModel, AppError>(error: AppError.networkError(err)).eraseToAnyPublisher()
                }
            }
            .map{PokemonViewModel(pokemonDataModel: $0)}
            .scan(baseViewModelArray){$0 + [$1]}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .handleEvents(receiveCancel: {
                stateCenter.executeAction(
                    .receivedPokemons(.failure(.subscriptionCancelled), isFinished: true)
                )
            })
            .sink { completion in
                switch completion {
                case .failure(let error):
                    stateCenter.executeAction(
                        .receivedPokemons( .failure(error) ,isFinished: false)
                    )
                case .finished:
                    stateCenter.executeAction(
                        .receivedPokemons( nil ,isFinished: true)
                    )
                }
            } receiveValue: { modelArray in
                let viewModelDic = modelArray.reduce(into: [Int: PokemonViewModel]()) { result, nextViewModel in
                    result[nextViewModel.id] = nextViewModel
                }
                stateCenter.executeAction(
                    .receivedPokemons( .success(
                        viewModelDic
                    ) ,isFinished: false)
                )
            }
            .store(in: &stateCenter.subscriptions[.loadingPokemon]!)
    }
    
    private func generateSinglePokemonDMPublisher(_ urlString: String) throws -> AnyPublisher<PokemonDataModel, AppError> {
        guard let url = URL(string: urlString) else {
            throw AppError.inValidURL("invaild url: \(urlString)")
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue(label: urlString))
            .map{$0.data}
            .decode(type: PokemonDataModel.self, decoder: FileHelper.appDecoder)
            .mapError{ AppError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
}



