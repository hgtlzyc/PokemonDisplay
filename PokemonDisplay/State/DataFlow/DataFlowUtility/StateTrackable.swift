//
//  StateTrackable.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/11/21.
//

import Foundation

protocol StateProgressTrackable {
    associatedtype ValueType
    var lowerValueBound: ValueType { get set }
    var upperInclusiveBound: ValueType { get set }
    var currentProgress: Double? { get }
}
