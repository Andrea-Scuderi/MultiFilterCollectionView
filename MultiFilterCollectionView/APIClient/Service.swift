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

protocol APIServing {
    func fetchBreedList(breed: String) async throws -> BreedListDTO
    func randomImage(breed: String) async throws -> URL?
    func fetchAllBreeds() async throws -> AllBreedsDTO
}

struct Service: APIServing {
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
