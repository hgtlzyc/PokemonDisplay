//
//  PokemonListStateTracker.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/11/21.
//

import Foundation


struct  PokemonListProgressTracker: ProgressTrackable {
    typealias ValueType = Int
    
    var lowerValueBound: Int
    var upperInclusiveBound: Int
    var currentListValue: Int
    
    init?(_ lowerBound: Int?, _ upperInclusiveBound: Int?, _ currentCount: Int?) {
        guard let lowerBound = lowerBound, let upperBound = upperInclusiveBound, let currentCount = currentCount else {
            return nil
        }
        guard lowerBound >= 0 && upperBound >= 0, upperBound >= lowerBound else {
            print("[TRACKER] pokemon bound error")
            return nil
        }
        guard currentCount >= 0, (lowerBound...upperBound + 1).contains(lowerBound + currentCount) else {
            print(lowerBound, currentCount, upperBound)
            print("[TRACKER] pokemon currentCount error")
            return nil
        }
        
        self.lowerValueBound = lowerBound
        self.upperInclusiveBound = upperBound
        
        self.currentListValue = lowerBound + currentCount
        
    }
    
    var currentProgress: Double? {
        let valueDistance = upperInclusiveBound - lowerValueBound + 1
        guard valueDistance > 0 else { return nil }
        return  Double(currentListValue) / Double(valueDistance)
    }
}
