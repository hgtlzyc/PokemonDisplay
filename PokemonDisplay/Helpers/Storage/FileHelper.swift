//
//  FileHelper.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import Foundation

enum FileHelper {
    
    //Read File and Decoding related
    static func loadJSON<T: Decodable>(
        from directory: FileManager.SearchPathDirectory,
        fileName: String
    ) throws -> T
    {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            throw AppError.unableAccessFileDirectory(directory)
        }
        return try loadJSON(from: url.appendingPathComponent(fileName))
    }
    
    private static func loadJSON<T: Decodable>(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try appDecoder.decode(T.self, from: data)
    }
    
    static let appDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    //Write file and Encoding related
    static func writeJSON<T: Encodable>(
        _ value: T,
        to directory: FileManager.SearchPathDirectory,
        fileName: String
    ) throws
    {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            throw AppError.unableAccessFileDirectory(directory)
        }
        try writeJSON(value, to: url.appendingPathComponent(fileName))
    }
    
    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try appEncoder.encode(value)
        try data.write(to: url)
    }
    
    static let appEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

   
    //File delete
    static func delete(from directory: FileManager.SearchPathDirectory, fileName: String) throws {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            throw AppError.unableAccessFileDirectory(directory)
        }
        try? FileManager.default.removeItem(at: url.appendingPathComponent(fileName))
    }
}
