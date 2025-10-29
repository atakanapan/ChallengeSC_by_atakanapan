import Foundation

// MARK: - UsersCacheAsync
protocol UsersCache {
    func write(_ data: Data, for key: String) async
    func read(for key: String) async -> Data?
    func touch(key: String) async
}

// MARK: - DiskUsersCache
actor DiskUsersCache: UsersCache {
    // MARK: - Properties
    private let cacheDirectory: URL
    private let maximumBytes: Int64
    private let maximumFileCount: Int
    /// Time To Live (TTL): maximum age a cache file is considered valid.
    private let timeToLive: TimeInterval?

    // MARK: - Initialization
    init(
        directoryName: String = "UsersCache",
        maximumBytes: Int64 = 50 * 1024 * 1024,   // 50 MB
        maximumFileCount: Int = 300,
        timeToLive: TimeInterval? = 7 * 24 * 60 * 60 // 7 days
    ) {
        self.maximumBytes = maximumBytes
        self.maximumFileCount = maximumFileCount
        self.timeToLive = timeToLive

        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent(directoryName, isDirectory: true)
        self.cacheDirectory = dir

        // One-time directory setup (actor isolation ensures single-threaded access).
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            // Exclude from iCloud backups (do not back up cache files).
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            var mutableDir = dir
            try mutableDir.setResourceValues(resourceValues)
        } catch {
            // Non-fatal; cache just won't be available if this fails.
            AppLogger.log("⚠️ DiskUsersCache directory setup failed: \(error)")
        }
    }

    // MARK: - UsersCacheAsync
    func write(_ data: Data, for key: String) async {
        let fileURL = fileURL(for: key)
        pruneIfNeeded(addingBytes: Int64(data.count))
        do {
            try data.write(to: fileURL, options: .atomic)
            // Mark as recently used right after write.
            try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
        } catch {
            AppLogger.log("⚠️ DiskUsersCache write failed for \(fileURL.lastPathComponent): \(error)")
        }
        // Run another prune pass after write.
        pruneIfNeeded(addingBytes: 0)
    }

    func read(for key: String) async -> Data? {
        let fileURL = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        // TTL check: if expired, remove and return nil.
        if let timeToLive = timeToLive {
            let cutoff = Date().addingTimeInterval(-timeToLive)
            if let values = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
               let modificationDate = values.contentModificationDate,
               modificationDate < cutoff {
                try? FileManager.default.removeItem(at: fileURL)
                return nil
            }
        }

        if let data = try? Data(contentsOf: fileURL) {
            // LRU bump to keep this file as "recently used".
            try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
            return data
        }
        return nil
    }

    func touch(key: String) async {
        let fileURL = fileURL(for: key)
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
    }

    // MARK: - Helpers
    private func fileURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent("\(key).json")
    }

    /// Returns all cache files with size and modification date, sorted oldest to newest.
    private func cacheFilesSortedOldestFirst() -> [(url: URL, size: Int64, modificationDate: Date)] {
        guard let enumerator = FileManager.default.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return [] }

        var files: [(url: URL, size: Int64, modificationDate: Date)] = []

        for case let fileURL as URL in enumerator {
            do {
                let values = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey])
                if values.isDirectory == true { continue }
                let size = Int64(values.fileSize ?? 0)
                let modificationDate = values.contentModificationDate ?? .distantPast
                files.append((url: fileURL, size: size, modificationDate: modificationDate))
            } catch {
                continue
            }
        }

        files.sort { lhs, rhs in
            lhs.modificationDate < rhs.modificationDate // oldest first
        }

        return files
    }

    /// Evicts oldest files until size/count limits are satisfied (and purges TTL-expired items).
    private func pruneIfNeeded(addingBytes: Int64) {
        var files = cacheFilesSortedOldestFirst()

        // TTL (Time To Live): remove entries older than the cutoff time.
        if let timeToLive = timeToLive {
            let cutoff = Date().addingTimeInterval(-timeToLive)
            for (url, _, modificationDate) in files where modificationDate < cutoff {
                try? FileManager.default.removeItem(at: url)
            }
            files = cacheFilesSortedOldestFirst()
        }

        var totalBytes: Int64 = files.reduce(0) { $0 + $1.size }
        var totalCount = files.count

        func removeOldestOne() {
            guard let oldest = files.first else { return }
            try? FileManager.default.removeItem(at: oldest.url)
            totalBytes -= oldest.size
            totalCount -= 1
            files.removeFirst()
        }

        // Size control (LRU effect by removing oldest first).
        while (totalBytes + addingBytes) > maximumBytes, !files.isEmpty {
            removeOldestOne()
        }
        // Count control.
        while totalCount > maximumFileCount, !files.isEmpty {
            removeOldestOne()
        }
    }
}

