import Foundation
import UIKit

// MARK: - ImageLoaderActor
actor ImageLoaderActor {
    // MARK: - Properties
    private let session: URLSession
    private let cache: NSCache<NSString, UIImage>
    
    // MARK: - Initialization
    init(session: URLSession) {
        self.session = session
        self.cache = NSCache<NSString, UIImage>()
        self.cache.countLimit = 100
        self.cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
    }
    
    // MARK: - Public
    func image(for urlString: String) async -> UIImage? {
        if let cached = cache.object(forKey: urlString as NSString) {
            return cached
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            // cost helps NSCache eviction accuracy
            let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
            cache.setObject(image, forKey: urlString as NSString, cost: cost)
            return image
        } catch {
            return nil
        }
    }
}

// MARK: - ImageLoadingService
class ImageLoadingService {
    static let shared = ImageLoadingService()
    
    private let actor: ImageLoaderActor
    
    private init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)
        self.actor = ImageLoaderActor(session: session)
    }
    
    /// Keeps the same completion-based API used by your cells.
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        Task { [actor] in
            let image = await actor.image(for: urlString)
            await MainActor.run {
                completion(image)
            }
        }
    }
}
