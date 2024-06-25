//  Endpoint.swift
//
//  Copyright (c) 2024 Andrea Scuderi
//

import Foundation

enum Endpoint {
    case breed(String)
    case all
    case randomImage(String)
    
    var endpoint: String {
        switch self {
        case .breed(let value):
            return "/breed/\(value)/images"
        case .all:
            return "/breeds/list/all"
        case .randomImage(let value):
            return "/breed/\(value)/images/random"
        }
    }

    func request(baseUrl: String) throws -> URL {
        let stringURL = "\(baseUrl)\(endpoint)"
        guard let url = URL(string: stringURL) else {
            throw ServiceError.invalidURL
        }
        return url
    }
}
