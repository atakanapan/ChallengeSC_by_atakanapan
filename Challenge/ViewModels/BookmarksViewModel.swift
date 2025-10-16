//
//  BookmarksViewModel.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import Foundation

protocol BookmarksViewModelDelegate: AnyObject {
    func didUpdateBookmarks()
    func didReceiveError(_ message: String)
}

class BookmarksViewModel {
    
    // MARK: - Properties
    weak var delegate: BookmarksViewModelDelegate?
    
    private(set) var bookmarkedUsers: [User] = []
    private let bookmarkManager = BookmarkManager.shared
    
    // MARK: - Computed Properties
    
    /// Check if bookmarks list is empty
    var isEmpty: Bool {
        return bookmarkedUsers.isEmpty
    }
    
    /// Get number of bookmarked users
    var bookmarkCount: Int {
        return bookmarkedUsers.count
    }
    
    /// Check if clear all button should be enabled
    var canClearAll: Bool {
        return !isEmpty
    }
    
    // MARK: - Initialization
    init() {
        loadBookmarks()
    }
    
    // MARK: - Public Methods
    
    /// Load bookmarks from storage
    func loadBookmarks() {
        bookmarkedUsers = bookmarkManager.bookmarkedUsers
        delegate?.didUpdateBookmarks()
    }
    
    /// Get user at specific index
    func user(at index: Int) -> User? {
        guard index >= 0 && index < bookmarkedUsers.count else { return nil }
        return bookmarkedUsers[index]
    }
    
    /// Remove bookmark at specific index
    func removeBookmark(at index: Int) {
        guard let user = user(at: index) else { return }
        bookmarkManager.removeBookmark(user)
        // Note: bookmarks will be updated automatically via notification
    }
    
    /// Toggle bookmark for user at index
    func toggleBookmark(at index: Int) {
        guard let user = user(at: index) else { return }
        bookmarkManager.toggleBookmark(user)
    }
    
    /// Check if user at index is bookmarked (should always be true in this context)
    func isBookmarked(at index: Int) -> Bool {
        guard let user = user(at: index) else { return false }
        return bookmarkManager.isBookmarked(user)
    }
    
    /// Clear all bookmarks
    func clearAllBookmarks() {
        bookmarkManager.clearAllBookmarks()
        // Note: bookmarks will be updated automatically via notification
    }
    
    /// Get confirmation message for removing specific bookmark
    func getRemoveConfirmationMessage(at index: Int) -> String {
        guard let user = user(at: index) else { return "Remove bookmark?" }
        return "Remove \(user.fullName) from bookmarks?"
    }
    
    /// Get empty state configuration
    func getEmptyStateConfiguration() -> (imageName: String, title: String, subtitle: String) {
        return (
            imageName: "bookmark.slash",
            title: "No Bookmarks Yet",
            subtitle: "Start bookmarking users to see them here"
        )
    }
}
