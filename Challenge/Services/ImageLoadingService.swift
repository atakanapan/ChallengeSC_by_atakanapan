//
//  ImageLoadingService.swift
//  Challenge
//
//  Created by Taras Nikulin on 16/10/2025.
//

import Foundation
import UIKit

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
