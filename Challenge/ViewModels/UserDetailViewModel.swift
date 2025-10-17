import Foundation
import UIKit

protocol UserDetailViewModelDelegate: AnyObject {
    func didUpdateBookmarkStatus()
    func didLoadProfileImage(_ image: UIImage)
}

class UserDetailViewModel {
    
    // MARK: - Properties
    weak var delegate: UserDetailViewModelDelegate?
    
    private(set) var user: User
    private let imageLoadingService = ImageLoadingService.shared
    private let bookmarkManager = BookmarkManager.shared
    
    // MARK: - Initialization
    init(user: User) {
        self.user = user
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Get user's display name
    var displayName: String {
        return user.fullName
    }
    
    /// Get user's age and location string
    var ageLocationText: String {
        return "\(user.age) years old • \(user.location.city), \(user.location.country)"
    }
    
    /// Get bookmark button title and style
    var bookmarkButtonConfiguration: (title: String, backgroundColor: UIColor) {
        if isBookmarked {
            return ("Remove Bookmark", .systemRed)
        } else {
            return ("Add Bookmark", .systemBlue)
        }
    }
    
    /// Check if user is currently bookmarked
    var isBookmarked: Bool {
        return bookmarkManager.isBookmarked(user)
    }
    
    /// Get placeholder image with user initials
    var placeholderImage: UIImage? {
        let firstInitial = user.name.first.first.map(String.init) ?? ""
        let lastInitial = user.name.last.first.map(String.init) ?? ""
        let initials = "\(firstInitial)\(lastInitial)"
        return UIImage.placeholder(initials: initials, size: CGSize(width: 150, height: 150))
    }
    
    /// Load profile image
    func loadProfileImage() {
        imageLoadingService.loadImage(from: user.picture.large) { [weak self] image in
            if let image = image {
                self?.delegate?.didLoadProfileImage(image)
            }
        }
    }
    
    /// Toggle bookmark status
    func toggleBookmark() {
        bookmarkManager.toggleBookmark(user)
    }
    
    /// Get share text for the user
    func getShareText() -> String {
        return "Check out \(user.fullName) from \(user.location.city), \(user.location.country)!"
    }
    
    // MARK: - Contact Information
    func getContactInformation() -> [(String, String, String)] {
        return [
            ("Email", user.email, "envelope"),
            ("Phone", user.phone, "phone"),
            ("Cell", user.cell, "phone.fill")
        ]
    }
    
    // MARK: - Location Information
    func getLocationInformation() -> [(String, String, String)] {
        return [
            ("Address", user.fullAddress, "location"),
            ("City", user.location.city, "building.2"),
            ("State", user.location.state, "map"),
            ("Country", user.location.country, "globe"),
            ("Postcode", user.location.postcode.stringValue, "number")
        ]
    }
    
    // MARK: - Personal Information
    func getPersonalInformation() -> [(String, String, String)] {
        return [
            ("Gender", user.gender.capitalized, "person"),
            ("Date of Birth", formatDate(user.dob.date), "calendar"),
            ("Age", "\(user.age) years old", "clock"),
            ("Nationality", user.nat, "flag")
        ]
    }
    
    // MARK: - Account Information
    func getAccountInformation() -> [(String, String, String)] {
        return [
            ("Username", user.login.username, "person.circle"),
            ("UUID", user.login.uuid, "key")
        ]
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bookmarkDidChange),
            name: BookmarkManager.bookmarkDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func bookmarkDidChange(_ notification: Notification) {
        // Check if the notification is for this specific user
        if let userInfo = notification.userInfo,
           let notificationUser = userInfo["user"] as? User,
           notificationUser.uniqueID == user.uniqueID {
            delegate?.didUpdateBookmarkStatus()
        } else if notification.userInfo?["action"] as? String == "cleared" {
            // Handle clear all bookmarks
            delegate?.didUpdateBookmarkStatus()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}