//  DTOs.swift
//
//  Copyright (c) 2024 Andrea Scuderi
//

import Foundation

struct BreedListDTO: Decodable {
    let message: [String]
    let status: String
}

struct AllBreedsDTO: Decodable {
    let message: [String: [String]]
}

struct ImageDTO: Decodable {
    let message: String
    let status: String
}

struct ErrorDTO: Decodable {
    let message: String
    let status: String
    let code: Int
}

enum ResponseStatus: String {
    case success
    case error
}

enum ResponseDecodingError: Error {
    case invalidStatus
}

enum ResponseDTO<Output: Decodable>: Decodable {
    case success(Output)
    case error(ErrorDTO)
    
    enum CodingKeys: String, CodingKey {
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statusValue = try container.decode(String.self, forKey: CodingKeys.status)
        guard let status = ResponseStatus(rawValue: statusValue) else {
            throw ResponseDecodingError.invalidStatus
        }
        switch status {
        case .success:
            let value = try Output(from: decoder)
            self = .success(value)
        case .error:
            let value = try ErrorDTO(from: decoder)
            self = .error(value)
        }
    }
}

typealias BreedListResponseDTO = ResponseDTO<BreedListDTO>
typealias AllBreedsResponseDTO = ResponseDTO<AllBreedsDTO>
typealias RandomImageResponseDTO = ResponseDTO<ImageDTO>
