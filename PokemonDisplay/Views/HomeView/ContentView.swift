//
//  ContentView.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var stateCenter: StateCenter

    var body: some View {
        VStack{
            ScrollView{
                LazyVStack{
                    ForEach(stateCenter.appState.pokemonListState.sortdPokemonList) { viewModel in
                        Text("\(viewModel.id)  " + viewModel.name)
                            
                            
                    }
                    .animation(.easeIn)
                }
                
            }
            //UI not refined will finish later
            let listState = stateCenter.appState.pokemonListState
                        
            if let progress = listState.currentLoadProgress {
                if let percentString = listState.progressTextString{
                    Text(percentString)
                }
                if listState.shouldShowProgressBar {
                    ProgressView(value: progress)
                            .padding(.horizontal)
                            .frame(height: 10)
                }
            }
            
            if let loadMissingString = listState.loadMissingButtonString {
                Button(
                    action: {
                        stateCenter.executeAction(.loadSelectedPokemons(withIndexSet:
                                listState.missingIndexSet
                            )
                        )
                    }, label: {
                        Text(loadMissingString)
                            .padding()
                            .background(Color.orange.opacity(0.4))
                        
                    }
                )
                .cornerRadius(12.0)
            }
            if !listState.currentlyLoadingPokemons {
                HStack{
                    let upperIndex = listState.upperPokemonsLimit
                    Text("up to index \(upperIndex)")
                    Stepper("") {
                        stateCenter.appState.pokemonListState.targetPokemonRange?.upperInclusiveBound += 1
                    } onDecrement: {
                        stateCenter.appState.pokemonListState.targetPokemonRange?.upperInclusiveBound -= 1
                    }
                    
                }
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
            }
            
            HomeViewBottom(stateCenter: stateCenter, range: (1...listState.upperPokemonsLimit) ).padding()
        }
        .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StateCenter())
    }
}
