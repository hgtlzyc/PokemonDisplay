//
//  HomeViewBottom.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/10/21.
//

import SwiftUI

struct HomeViewBottom: View {
    @ObservedObject var stateCenter: StateCenter
    var range: ClosedRange<Int>
    
    let cornerRadius = 12.0
    
    var body: some View {
        HStack{
            let isLoading = stateCenter.appState.pokemonListState.currentlyLoadingPokemons
            let isListEmpty = stateCenter.appState.pokemonListState.pokemonsDic == nil
            
            Button(action: {
                stateCenter.executeAction(.reloadAllPokemons(withIndexRange: range))
            }, label: {
                Text( stateCenter.appState.pokemonListState.homeViewLoadStatusString)
                    .frame(width: 100, height: 50, alignment: .center)
                    .background(Color(isLoading ? .red : .blue).opacity(0.2))
            })
            .cornerRadius(CGFloat(cornerRadius))
            
            
            if isLoading {
                Button(action: {
                    stateCenter.executeAction(.cancelPokemonLoading)
                }, label: {
                    Text("Cancel Loading")
                        .frame(width: 150, height: 50, alignment: .center)
                        .background(Color(.red).opacity(0.5))
                })
                .cornerRadius(CGFloat(cornerRadius))
                .padding(.leading)
            }
            
            if !isLoading && !isListEmpty{
                Button(action: {
                    stateCenter.executeAction(.deletePokemonViewModelCache)
                }, label: {
                    Text("Clear Cache")
                        .frame(width: 120, height: 50, alignment: .center)
                        .background(Color(.red).opacity(0.5))
                })
                .cornerRadius(CGFloat(cornerRadius))
                .padding(.leading)
                .disabled( isLoading && !isListEmpty)
                
            }
        }
        .animation(.easeInOut)
        
    }
}

struct HomeViewBottom_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewBottom(stateCenter: StateCenter(), range: (1...20))
    }
}
