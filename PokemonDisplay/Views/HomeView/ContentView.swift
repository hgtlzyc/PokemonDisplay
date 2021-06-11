//
//  ContentView.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var stateCenter: StateCenter
    @State var range: ClosedRange<Int> = (1...50)
    
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
            HStack{
                
            }
            
            HomeViewBottom(stateCenter: stateCenter, range: $range)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StateCenter())
    }
}
