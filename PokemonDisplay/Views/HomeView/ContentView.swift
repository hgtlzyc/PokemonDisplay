//
//  ContentView.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var stateCenter: StateCenter
    
    @State var range: ClosedRange<Int> = (1...100)
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack{
                    ForEach(stateCenter.appState.pokemonListState.sortdPokemonList) { viewModel in
                        Text(viewModel.name)
                    }
                }
            }
            .animation(.easeIn)
            
            let listState = stateCenter.appState.pokemonListState
            if let progress = listState.currentLoadProgress {
                if let text = listState.progressTextString {
                    Text(text)
                }
                
                if listState.shouldShowProgressBar {
                    ProgressBar(value: progress)
                            .padding(.horizontal)
                            .frame(height: 10)
                }
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
