//
//  HomeViewBottom.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/10/21.
//

import SwiftUI

struct HomeViewBottom: View {
    @ObservedObject var stateCenter: StateCenter
    @Binding var range: ClosedRange<Int>
    var body: some View {
        HStack{
            let isLoading = stateCenter.appState.pokemonListState.currentlyLoadingPokemons
            let isListEmpty = stateCenter.appState.pokemonListState.pokemonsDic == nil
            
            Button(action: {
                stateCenter.executeAction(.loadPokemons(withIndexRange: range))
            }, label: {
                Text( stateCenter.appState.pokemonListState.homeViewLoadStatusString)
                    .frame(width: 100, height: 50, alignment: .center)
                    .background(Color(isLoading ? .red : .blue).opacity(0.2))
            })
            
            


            if isLoading {
                Button(action: {
                    stateCenter.executeAction(.cancelPokemonLoading)
                }, label: {
                    Text("Cancel Loading")
                        .frame(width: 150, height: 50, alignment: .center)
                        .background(Color(.red).opacity(0.5))
                })
            }
            
            if !isLoading && !isListEmpty{
                Button(action: {
                    stateCenter.executeAction(.deletePokemonCache)
                }, label: {
                    Text("Clear Cache")
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Color(.red).opacity(0.5))
                })
                .disabled( isLoading && !isListEmpty)
                
            }
        }
        .animation(.easeInOut)
        
    }
}

struct HomeViewBottom_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewBottom(stateCenter: StateCenter(), range: Binding.constant((1...20)))
    }
}