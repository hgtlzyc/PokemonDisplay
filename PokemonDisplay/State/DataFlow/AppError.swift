//
//  AppError.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

enum AppError: Error {
    
    //Status Related
    case selectedIndexSetNotExpected(index: Int?)
    case targetIndexBoundError(String)
    
    //Subscriptions
    case subscriptionCancelled
    
    //Network Related
    case unableInitiateProcessor(String?)
    case inValidURL(String)
    case networkError(Error)
    
    //FileStorage Related
    case unableAccessFileDirectory(FileManager.SearchPathDirectory)
}
