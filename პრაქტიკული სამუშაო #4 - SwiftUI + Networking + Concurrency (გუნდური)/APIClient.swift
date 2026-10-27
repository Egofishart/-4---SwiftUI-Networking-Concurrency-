//
//  Untitled.swift
//  პრაქტიკული სამუშაო #4 - SwiftUI + Networking + Concurrency (გუნდური)
//
//  Created by NikoDanelia on 27/10/2026.
//
import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "არასწორი URL მისამართი."
        case .invalidResponse:
            return "სერვერიდან არასწორი პასუხი მოვიდა."
        case .decodingError:
            return "მონაცემთა დამუშავება ვერ მოხერხდა."
        case .serverError(let statusCode):
            return "სერვერის შეცდომა: კოდი \(statusCode)"
        }
    }
}

protocol APIClientProtocol {
    func fetchPosts() async throws -> [Post]
}

class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode([Post].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

