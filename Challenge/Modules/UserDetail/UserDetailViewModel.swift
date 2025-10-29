import Foundation
import UIKit

protocol UserDetailViewModelDelegate: AnyObject {
    func didUpdateBookmarkStatus()
    func didLoadProfileImage(_ image: UIImage)
}

@MainActor
final class UserDetailViewModel {

    // MARK: - Properties
    weak var delegate: UserDetailViewModelDelegate?

    private(set) var user: UserEntity
    private let imageLoadingService = ImageLoadingService.shared
    private let bookmarkManager = BookmarkManager.shared

    private var bookmarkObserver: NSObjectProtocol?

    // MARK: - Init / Deinit
    init(user: UserEntity) {
        self.user = user
        setupNotifications()
    }

    deinit {
        if let token = bookmarkObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }

    // MARK: - Public API

    var displayName: String { user.fullName }

    var ageLocationText: String {
        "\(user.age) years old • \(user.location.city), \(user.location.country)"
    }

    var bookmarkButtonConfiguration: (title: String, backgroundColor: UIColor) {
        isBookmarked ? ("Remove Bookmark", .systemRed) : ("Add Bookmark", .systemBlue)
    }
    
    /// Check if user is currently bookmarked
    var isBookmarked: Bool {
        bookmarkManager.isBookmarked(user)
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
            guard let self, let image else { return }
            self.delegate?.didLoadProfileImage(image)
        }
    }
    
    /// Toggle bookmark status
    func toggleBookmark() {
        bookmarkManager.toggleBookmark(user)
    }
    
    /// Get share text for the user
    func getShareText() -> String {
        "Check out \(user.fullName) from \(user.location.city), \(user.location.country)!"
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
        // The closure here is @Sendable. Don’t touch @MainActor state inside it directly.
        bookmarkObserver = NotificationCenter.default.addObserver(
            forName: BookmarkManager.bookmarkDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // Hop to the main actor before using self / delegate.
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.handleBookmarkChange(notification)
            }
        }
    }
    
    @MainActor
    private func handleBookmarkChange(_ notification: Notification) {
        if let info = notification.userInfo,
           let action = info["action"] as? String {
            if action == "cleared" {
                delegate?.didUpdateBookmarkStatus()
                return
            }
            if let changedUser = info["user"] as? UserEntity,
               changedUser.uniqueID == user.uniqueID {
                delegate?.didUpdateBookmarkStatus()
            }
        } else {
            delegate?.didUpdateBookmarkStatus()
        }
    }

    // MARK: - Helpers
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
