//
//  APIService.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import Foundation

// MARK: - NetworkError
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        }
    }
}

// MARK: - APIService
class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://randomuser.me/api/"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Fetch Users
    func fetchUsers(page: Int, results: Int = 25, seed: String? = nil, completion: @escaping (Result<RandomUserResponse, NetworkError>) -> Void) {
        var components = URLComponents(string: baseURL)
        
        var queryItems = [
            URLQueryItem(name: "results", value: "\(results)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        // Use seed for consistent pagination
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: seed))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Fetching users from: \(url.absoluteString)")
        
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let randomUserResponse = try JSONDecoder().decode(RandomUserResponse.self, from: data)
                    print("✅ Successfully fetched \(randomUserResponse.results.count) users")
                    completion(.success(randomUserResponse))
                } catch {
                    print("❌ Decoding error: \(error)")
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
}
