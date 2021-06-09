//
//  FileStorageWrapper.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

@propertyWrapper
struct FileStorage<T: Codable> {
    var value: T?

    let directory: FileManager.SearchPathDirectory
    let fileName: String

    let queue = DispatchQueue(label: (UUID().uuidString))

    init(directory: FileManager.SearchPathDirectory, fileName: String) {
        value = try? FileHelper.loadJSON(from: directory, fileName: fileName)
        self.directory = directory
        self.fileName = fileName
    }

    var wrappedValue: T? {
        set {
            value = newValue
            let directory = self.directory
            let fileName = self.fileName
            queue.async {
                if let value = newValue {
                    do {
                        try FileHelper.writeJSON(value, to: directory, fileName: fileName)
                    } catch let error {
                        print(error)
                    }
                } else {
                    do {
                        try FileHelper.delete(from: directory, fileName: fileName)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
        
        get { value }
    }
}
