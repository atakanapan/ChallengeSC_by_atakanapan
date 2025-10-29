import Foundation

// MARK: - BookmarkManager
class BookmarkManager {
    static let shared = BookmarkManager()
    
    private let userDefaults = UserDefaults.standard
    private let bookmarksKey = "BookmarkedUsers"
    
    // Notification for bookmark changes
    static let bookmarkDidChangeNotification = NSNotification.Name("BookmarkDidChange")
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get all bookmarked users
    var bookmarkedUsers: [UserEntity] {
        guard let data = userDefaults.data(forKey: bookmarksKey),
              let users = try? JSONDecoder().decode([UserEntity].self, from: data) else {
            return []
        }
        return users
    }
    
    /// Check if a user is bookmarked
    func isBookmarked(_ user: UserEntity) -> Bool {
        return bookmarkedUsers.contains(where: { $0.uniqueID == user.uniqueID })
    }
    
    /// Add a user to bookmarks
    func addBookmark(_ user: UserEntity) {
        var currentBookmarks = bookmarkedUsers
        
        // Avoid duplicates
        if !currentBookmarks.contains(where: { $0.uniqueID == user.uniqueID }) {
            currentBookmarks.append(user)
            saveBookmarks(currentBookmarks)
            
            print("✅ Added bookmark for \(user.fullName)")
            
            // Post notification
            NotificationCenter.default.post(name: BookmarkManager.bookmarkDidChangeNotification,
                                          object: nil,
                                          userInfo: ["action": "added", "user": user])
        }
    }
    
    /// Remove a user from bookmarks
    func removeBookmark(_ user: UserEntity) {
        var currentBookmarks = bookmarkedUsers
        currentBookmarks.removeAll { $0.uniqueID == user.uniqueID }
        saveBookmarks(currentBookmarks)
        
        print("🗑️ Removed bookmark for \(user.fullName)")
        
        // Post notification
        NotificationCenter.default.post(name: BookmarkManager.bookmarkDidChangeNotification,
                                      object: nil,
                                      userInfo: ["action": "removed", "user": user])
    }
    
    /// Toggle bookmark status for a user
    func toggleBookmark(_ user: UserEntity) {
        if isBookmarked(user) {
            removeBookmark(user)
        } else {
            addBookmark(user)
        }
    }
    
    /// Get count of bookmarked users
    var bookmarkedCount: Int {
        return bookmarkedUsers.count
    }
    
    /// Clear all bookmarks
    func clearAllBookmarks() {
        userDefaults.removeObject(forKey: bookmarksKey)
        
        print("🗑️ Cleared all bookmarks")
        
        // Post notification
        NotificationCenter.default.post(name: BookmarkManager.bookmarkDidChangeNotification,
                                      object: nil,
                                      userInfo: ["action": "cleared"])
    }
    
    // MARK: - Private Methods
    
    private func saveBookmarks(_ users: [UserEntity]) {
        do {
            let data = try JSONEncoder().encode(users)
            userDefaults.set(data, forKey: bookmarksKey)
            userDefaults.synchronize()
        } catch {
            print("❌ Failed to save bookmarks: \(error)")
        }
    }
}
