//
//  Service.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 06/05/2024.
//

import Foundation

enum ServiceError: Error {
    case invalidURL
    case response(ErrorDTO)
}

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

struct Service {
    let baseURL = "https://dog.ceo/api"
    let session = URLSession(configuration: .default)
    let decoder = JSONDecoder()
    
    func fetchBreedList(breed: String) async throws -> BreedListDTO {
        let url = try Endpoint.breed(breed).request(baseUrl: baseURL)
        let request = URLRequest(url: url)
        let response = try await session.data(for: request)
        let decodedValue = try decoder.decode(BreedListResponseDTO.self, from: response.0)
        switch decodedValue {
        case .success(let dto):
            return dto
        case .error(let error):
            throw ServiceError.response(error)
        }
    }
    
    func randomImage(breed: String) async throws -> URL? {
        let url = try Endpoint.randomImage(breed).request(baseUrl: baseURL)
        let request = URLRequest(url: url)
        let response = try await session.data(for: request)
        let decodedValue = try decoder.decode(RandomImageResponseDTO.self, from: response.0)
        switch decodedValue {
        case .success(let dto):
            return URL(string: dto.message)
        case .error(let error):
            throw ServiceError.response(error)
        }
    }
    
    func fetchAllBreeds() async throws -> AllBreedsDTO {
        let url = try Endpoint.all.request(baseUrl: baseURL)
        let request = URLRequest(url: url)
        let response = try await session.data(for: request)
        let decodedValue = try decoder.decode(AllBreedsResponseDTO.self, from: response.0)
        switch decodedValue {
        case .success(let dto):
            return dto
        case .error(let error):
            throw ServiceError.response(error)
        }
    }
}
