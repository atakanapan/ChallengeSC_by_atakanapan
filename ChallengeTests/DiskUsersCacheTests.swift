import Foundation
import Testing
@testable import Challenge

@Suite("DiskUsersCache")
struct DiskUsersCacheTests {

    /// Creates a cache instance with the provided constraints so tests can tune limits precisely.
    private func makeDiskUsersCache(
        directoryName: String = "UnitTests-\(UUID().uuidString)",
        maximumBytes: Int64 = 1_000_000,
        maximumFileCount: Int = 100,
        timeToLive: TimeInterval? = nil
    ) -> DiskUsersCache {
        DiskUsersCache(
            directoryName: directoryName,
            maximumBytes: maximumBytes,
            maximumFileCount: maximumFileCount,
            timeToLive: timeToLive
        )
    }

    /// Constructs the expected on-disk URL for a given cache key (mirrors production naming).
    private func cacheFileURL(directoryName: String, key: String) -> URL {
        let baseCachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return baseCachesDirectory
            .appendingPathComponent(directoryName, isDirectory: true)
            .appendingPathComponent("\(key).json")
    }

    /// Ensures that when TTL is set and a file is older than the cutoff, it is removed and read returns nil.
    @Test
    func read_removesExpiredEntriesBasedOnTimeToLive() async throws {
        let directoryName = "UnitTests-\(UUID().uuidString)"
        let diskUsersCacheUnderTest = makeDiskUsersCache(directoryName: directoryName, timeToLive: 60) // 1 minute TTL
        let cacheKey = "expired-key"

        await diskUsersCacheUnderTest.write(Data("A".utf8), for: cacheKey)

        // Artificially age the file so it is well beyond TTL.
        let fileURL = cacheFileURL(directoryName: directoryName, key: cacheKey)
        try FileManager.default.setAttributes([.modificationDate: Date.distantPast], ofItemAtPath: fileURL.path)

        let readData = await diskUsersCacheUnderTest.read(for: cacheKey)
        #expect(readData == nil)
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
    }

    /// Verifies size-based pruning acts like LRU by removing the oldest file first when capacity is exceeded.
    @Test
    func pruneBySize_removesOldestFirst_andKeepsNewerIfTheyFitAfterPrune() async throws {
        let directoryName = "UnitTests-\(UUID().uuidString)"
        let maximumBytes: Int64 = 12
        let diskUsersCacheUnderTest = makeDiskUsersCache(
            directoryName: directoryName,
            maximumBytes: maximumBytes,
            maximumFileCount: 10,
            timeToLive: nil
        )
        // Write "old" (6 bytes) and make it the oldest by backdating its modification time.
        await diskUsersCacheUnderTest.write(Data("AAAAAA".utf8), for: "old")
        let oldFileURL = cacheFileURL(directoryName: directoryName, key: "old")
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSinceNow: -3600)], ofItemAtPath: oldFileURL.path)
        // Write "new" (3 bytes), which should coexist with "old" for now (total = 9 bytes).
        await diskUsersCacheUnderTest.write(Data("BBB".utf8), for: "new")
        // Writing "incoming" (6 bytes) forces a prune: total would be 15, so the cache removes the **oldest** ("old"),
        // then 3 + 6 = 9 <= 12, so both "new" and "incoming" should remain.
        await diskUsersCacheUnderTest.write(Data("CCCCCC".utf8), for: "incoming")
        let newFileURL = cacheFileURL(directoryName: directoryName, key: "new")
        let incomingFileURL = cacheFileURL(directoryName: directoryName, key: "incoming")
        #expect(!FileManager.default.fileExists(atPath: oldFileURL.path)) // oldest evicted
        #expect(FileManager.default.fileExists(atPath: newFileURL.path)) // newer kept
        #expect(FileManager.default.fileExists(atPath: incomingFileURL.path)) // incoming written
    }
    

    /// Verifies count-based pruning keeps the most recent file and removes older ones when the max count is exceeded.
    @Test
    func pruneByCount_keepsMostRecentFile() async throws {
        let directoryName = "UnitTests-\(UUID().uuidString)"
        let diskUsersCacheUnderTest = makeDiskUsersCache(directoryName: directoryName, maximumBytes: 1_000_000, maximumFileCount: 1, timeToLive: nil)

        await diskUsersCacheUnderTest.write(Data("first".utf8), for: "first")
        let firstFileURL = cacheFileURL(directoryName: directoryName, key: "first")
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSinceNow: -3600)], ofItemAtPath: firstFileURL.path)

        await diskUsersCacheUnderTest.write(Data("second".utf8), for: "second")

        #expect(!FileManager.default.fileExists(atPath: firstFileURL.path))
        #expect(FileManager.default.fileExists(atPath: cacheFileURL(directoryName: directoryName, key: "second").path))
    }
}
