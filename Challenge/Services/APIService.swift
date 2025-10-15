//
//  APIService.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import Foundation
import UIKit

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
    
    // MARK: - Search Users
    func searchUsers(query: String, page: Int, results: Int = 25, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        // For search, we'll fetch users and filter locally since the API doesn't support search directly
        fetchUsers(page: page, results: results) { result in
            switch result {
            case .success(let response):
                let filteredUsers = response.results.filter { user in
                    let searchText = query.lowercased()
                    return user.fullName.lowercased().contains(searchText) ||
                           user.email.lowercased().contains(searchText) ||
                           user.location.city.lowercased().contains(searchText) ||
                           user.location.country.lowercased().contains(searchText)
                }
                completion(.success(filteredUsers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Image Loading Service
class ImageLoadingService {
    static let shared = ImageLoadingService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration)
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                      let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                
                // Cache the image
                self?.cache.setObject(image, forKey: cacheKey)
                completion(image)
            }
        }.resume()
    }
}