//
//  ContentView.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var stateCenter: StateCenter
    @State var range: ClosedRange<Int> = (0...99)
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack{
                    ForEach(stateCenter.appState.pokemonListState.sortdPokemonList) { viewModel in
                        Text(viewModel.name ?? "no name").id(UUID())
                            
                    }
                    
                }
                .animation(.easeIn)
                
            }
            
            
            let listState = stateCenter.appState.pokemonListState
                        
            if let progress = listState.currentLoadProgress {
                if let percentString = listState.progressTextString{
                    Text(percentString)
                }
                if listState.shouldShowProgressBar {
                    ProgressBar(value: progress)
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
            
            HomeViewBottom(stateCenter: stateCenter, range: $range).padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StateCenter())
    }
}
