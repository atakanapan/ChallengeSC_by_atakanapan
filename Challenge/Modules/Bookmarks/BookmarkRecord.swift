import Foundation
import SwiftData

/// SwiftData model for a bookmarked user.
@Model
final class BookmarkRecord {
    // Business identity
    var uniqueID: String

    // Primary display
    var fullName: String
    var email: String
    var city: String
    var country: String

    // Avatar urls for list/detail
    var thumbnailURL: String
    var largeImageURL: String

    // Keep original object to reconstruct `UserEntity` exactly
    @Attribute(.externalStorage)
    var rawUser: Data?

    var createdAt: Date
    var updatedAt: Date

    init(
        uniqueID: String,
        fullName: String,
        email: String,
        city: String,
        country: String,
        thumbnailURL: String,
        largeImageURL: String,
        rawUser: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.uniqueID = uniqueID
        self.fullName = fullName
        self.email = email
        self.city = city
        self.country = country
        self.thumbnailURL = thumbnailURL
        self.largeImageURL = largeImageURL
        self.rawUser = rawUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension BookmarkRecord {
    convenience init(from user: UserEntity) {
        let rawUser = try? JSONEncoder().encode(user)
        self.init(
            uniqueID: user.uniqueID,
            fullName: user.fullName,
            email: user.email,
            city: user.location.city,
            country: user.location.country,
            thumbnailURL: user.picture.thumbnail,
            largeImageURL: user.picture.large,
            rawUser: rawUser
        )
    }
}
