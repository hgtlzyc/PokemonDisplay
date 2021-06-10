//
//  AppError.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

enum AppError: Error {
    
    
    //Network Related
    case networkError(Error)
    
    //FileStorage Related
    case unableAccessFileDirectory(FileManager.SearchPathDirectory)
}
