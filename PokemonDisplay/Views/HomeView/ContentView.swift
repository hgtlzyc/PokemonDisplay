//
//  ContentView.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @EnvironmentObject var stateCenter: StateCenter

    var body: some View {
        VStack{
            GeometryReader{ prox in
                ScrollView{
                    LazyVStack{
                        ForEach(stateCenter.appState.pokemonListState.sortedAndFilteredPokemonList) { viewModel in
                            //use Kinfisher for now, might be modify later
                            HStack {
                                KFImage(viewModel.imageURL)
                                    .cancelOnDisappear(false)
                                    .loadImmediately()
                                
                                Text("\(viewModel.id)  " + viewModel.name)
                                    
                            }
                        }
                        .animation(.easeIn)
                    }
                    .frame(width: prox.size.width, alignment: .center)
                    
                }
            }
            
            //UI not refined will finish later
            let listState = stateCenter.appState.pokemonListState
            
            //MARK: progress bar
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
            
            //MARK: - Load Missing
            if let loadMissingString = listState.loadMissingButtonString {
                Button(
                    action: {
                        stateCenter.executeAction(.loadSelectedPokemons(withIndexSet:
                                listState.missingIndexSet
                            )
                        )
                    }, label: {
                        Text(loadMissingString)
                            .font(.system(.body))
                            .padding()
                            .lineLimit(1)
                            .background(Color.orange.opacity(0.4))
                        
                    }
                )
                .cornerRadius(12.0)
            }
            if !listState.currentlyLoadingPokemons {
                HStack{
                    let lowerIndex = listState.lowerPokemonsLimit
                    Text("from \(lowerIndex)")
                    Stepper("") {
                        stateCenter.executeAction(.adjustTargetRange(lowerTo: lowerIndex + 1, upperInclusiveTo: nil))
                    } onDecrement: {
                        stateCenter.executeAction(.adjustTargetRange(lowerTo: lowerIndex - 1, upperInclusiveTo: nil))
                    }
                    
                    let upperIndex = listState.upperPokemonsLimit
                    Text("up to \(upperIndex)")
                    Stepper("") {
                        stateCenter.executeAction(.adjustTargetRange(lowerTo: nil, upperInclusiveTo: upperIndex + 1))
                    } onDecrement: {
                        stateCenter.executeAction(.adjustTargetRange(lowerTo: nil, upperInclusiveTo: upperIndex - 1))
                    }
                    
                }
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
            }
            
            //MARK: reload
            
            HomeViewBottom(stateCenter: stateCenter, range: (listState.lowerPokemonsLimit...listState.upperPokemonsLimit) ).padding()
        }
        .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StateCenter())
    }
}
