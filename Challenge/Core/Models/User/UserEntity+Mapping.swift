import Foundation

extension UserEntity {
    /// Rebuild the exact original `UserEntity` from the stored JSON.
    static func from(record: BookmarkRecord) -> UserEntity? {
        guard let data = record.rawUser else { return nil }
        return try? JSONDecoder().decode(UserEntity.self, from: data)
    }
}
