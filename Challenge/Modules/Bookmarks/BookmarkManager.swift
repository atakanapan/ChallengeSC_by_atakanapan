import Foundation
import SwiftData

// MARK: - BookmarkManager
@MainActor
final class BookmarkManager {

    // MARK: - Singleton
    static let shared = BookmarkManager(modelContext: BookmarksPersistenceController.shared.context)

    // MARK: - Notifications
    static let bookmarkDidChangeNotification = NSNotification.Name("BookmarkDidChange")

    // MARK: - Dependencies
    private let modelContext: ModelContext

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public API

    /// Returns all bookmarked users, newest first.
    var bookmarkedUsers: [UserEntity] {
        do {
            var descriptor = FetchDescriptor<BookmarkRecord>()
            descriptor.sortBy = [SortDescriptor(\.updatedAt, order: .reverse)]
            let records = try modelContext.fetch(descriptor)
            return records.compactMap(UserEntity.from(record:))
        } catch {
            AppLogger.log("❌ Fetch bookmarks failed: \(error)")
            return []
        }
    }

    /// Returns the count of bookmarked users.
    var bookmarkedCount: Int {
        bookmarkedUsers.count
    }

    /// Returns `true` if the given user is already bookmarked.
    func isBookmarked(_ user: UserEntity) -> Bool {
        record(for: user.uniqueID) != nil
    }

    /// Adds the given user to bookmarks if not already present.
    func addBookmark(_ user: UserEntity) {
        guard record(for: user.uniqueID) == nil else { return }

        let record = BookmarkRecord(from: user)
        modelContext.insert(record)
        saveContext()

        AppLogger.log("✅ Added bookmark for \(user.fullName)")
        notify(action: "added", user: user)
    }

    /// Removes the given user from bookmarks if present.
    func removeBookmark(_ user: UserEntity) {
        guard let record = record(for: user.uniqueID) else { return }

        modelContext.delete(record)
        saveContext()

        AppLogger.log("🗑️ Removed bookmark for \(user.fullName)")
        notify(action: "removed", user: user)
    }

    /// Toggles bookmark status for the given user.
    func toggleBookmark(_ user: UserEntity) {
        isBookmarked(user) ? removeBookmark(user) : addBookmark(user)
    }

    /// Removes all bookmarks.
    func clearAllBookmarks() {
        do {
            let all = try modelContext.fetch(FetchDescriptor<BookmarkRecord>())
            all.forEach { modelContext.delete($0) }
            saveContext()

            AppLogger.log("🗑️ Cleared all bookmarks")
            NotificationCenter.default.post(
                name: Self.bookmarkDidChangeNotification,
                object: nil,
                userInfo: ["action": "cleared"]
            )
        } catch {
            AppLogger.log("❌ Clear all bookmarks failed: \(error)")
        }
    }

    // MARK: - Private Helpers

    /// Looks up a bookmark record by uniqueID.
    private func record(for uniqueID: String) -> BookmarkRecord? {
        do {
            let predicate = #Predicate<BookmarkRecord> { $0.uniqueID == uniqueID }
            var descriptor = FetchDescriptor<BookmarkRecord>(predicate: predicate)
            descriptor.fetchLimit = 1
            return try modelContext.fetch(descriptor).first
        } catch {
            AppLogger.log("❌ Lookup failed for uniqueID=\(uniqueID): \(error)")
            return nil
        }
    }

    /// Saves the SwiftData context.
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            AppLogger.log("❌ SwiftData save failed: \(error)")
        }
    }

    /// Posts a change notification.
    private func notify(action: String, user: UserEntity) {
        NotificationCenter.default.post(
            name: Self.bookmarkDidChangeNotification,
            object: nil,
            userInfo: ["action": action, "user": user]
        )
    }
}
