import Foundation

// MARK: - APIService
final class APIService {
    // MARK: - Singleton
    static let shared = APIService()
    
    // MARK: - Properties
    private let baseURL = "https://randomuser.me/api/"
    private let session: URLSession
    
    // Cache limits
    private let maxCacheBytes: Int64 = 50 * 1024 * 1024 // 50 MB
    private let maxCacheFileCount: Int = 300
    private let cacheTTL: TimeInterval? = 7 * 24 * 60 * 60 // 7 days
    
    // Disk I/O synchronization: use a dedicated serial queue to avoid race conditions
    private let cacheQueue = DispatchQueue(label: "APIService.DiskCache.Queue")
    
    // File cache directory for offline fallback
    private let cacheDirectory: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UsersCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        // Exclude from iCloud backups (do not back up cache files)
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var mutableDir = dir
        try? mutableDir.setResourceValues(resourceValues)
        
        return dir
    }()
    
    // MARK: - Initialization
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public API (Async)
    /// Fetches a page of users using async/await. Supports seed for stable pagination
    func fetchUsers(
        page: Int,
        results: Int = 25,
        seed: String? = nil
    ) async throws -> RandomUserResponse {
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
            throw NetworkError.invalidURL
        }
        
        print("🌐 Fetching users from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                print("❌ HTTP error: \(httpResponse.statusCode)")
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoded = try JSONDecoder().decode(RandomUserResponse.self, from: data)
            print("✅ Successfully fetched \(decoded.results.count) users (page: \(page))")
            
            // Write cache for offline usage (without exceed limits)
            let file = makeCacheURL(seed: seed, page: page, results: results)
            cacheQueue.sync {
                pruneCacheIfNeeded(addingBytes: Int64(data.count))
                do {
                    try data.write(to: file, options: .atomic)
                    // Set modification date to current time
                    try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: file.path)
                } catch {
                    print("⚠️ Cache write failed: \(error)")
                }
                // Control cache after write
                pruneCacheIfNeeded(addingBytes: 0)
            }
            
            return decoded
        } catch {
            // Offline fallback: try cache if network/decoding fails
            let file = makeCacheURL(seed: seed, page: page, results: results)
            if let data = try? Data(contentsOf: file),
               let decodedData = try? JSONDecoder().decode(RandomUserResponse.self, from: data) {
                // Least Recently Used bump: update modification date so this file counts as "recently used".
                cacheQueue.async {
                    try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: file.path)
                }
                print("📦 Offline cache hit for page \(decodedData.info.page)")
                return decodedData
            }
            
            print("❌ Network/Decode error: \(error)")
            if let networkError = error as? NetworkError {
                throw networkError
            }
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Helpers
    private func makeCacheURL(
        seed: String?,
        page: Int,
        results: Int
    ) -> URL {
        let seedKey = seed ?? "noseed"
        return cacheDirectory.appendingPathComponent("\(seedKey)_p\(page)_r\(results).json")
    }
    
    /// Returns all cache files with size and modification date, sorted oldest to newest.
    private func cacheFilesSortedOldestFirst() -> [(url: URL, size: Int64, modificationDate: Date)] {
        guard let enumerator = FileManager.default.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return [] }
        
        var files: [(URL, Int64, Date)] = []
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey])
                if resourceValues.isDirectory == true { continue }
                let size = Int64(resourceValues.fileSize ?? 0)
                let modificationDate = resourceValues.contentModificationDate ?? Date.distantPast
                files.append((fileURL, size, modificationDate))
            } catch {
                continue
            }
        }
        
        files.sort { $0.2 < $1.2 } // oldest first
        return files
    }
    
    private func currentCacheSizeAndCount() -> (bytes: Int64, count: Int) {
        var total: Int64 = 0
        var count: Int = 0
        for file in cacheFilesSortedOldestFirst() {
            total += file.size
            count += 1
        }
        return (total, count)
    }
    
    /// Evicts oldest files until size/count limits are satisfied.
    private func pruneCacheIfNeeded(addingBytes: Int64) {
        var files = cacheFilesSortedOldestFirst()
        
        // Time To Live: remove entries older than the cutoff time.
        if let ttl = cacheTTL {
            let cutoff = Date().addingTimeInterval(-ttl)
            for (url, _, modificationDate) in files where modificationDate < cutoff {
                try? FileManager.default.removeItem(at: url)
            }
            // Update list
            files = cacheFilesSortedOldestFirst()
        }
        
        // Size and count check
        var totalBytes: Int64 = 0
        for file in files { totalBytes += file.size }
        
        var totalCount = files.count
        
        func removeOldestOne() {
            guard let oldest = files.first else { return }
            try? FileManager.default.removeItem(at: oldest.url)
            totalBytes -= oldest.size
            totalCount -= 1
            files.removeFirst()
        }
        
        // Size control
        while (totalBytes + addingBytes) > maxCacheBytes, !files.isEmpty {
            removeOldestOne()
        }
        // Limit control
        while totalCount > maxCacheFileCount, !files.isEmpty {
            removeOldestOne()
        }
    }
}
