import Foundation
import SwiftData
import Testing
@testable import Challenge

@MainActor
@Suite("BookmarkManager")
struct BookmarkManagerTests {

    /// Builds an in-memory SwiftData context so tests do not touch disk and remain fast.
    private func makeInMemoryModelContext() throws -> ModelContext {
        let dataModelSchema = Schema([BookmarkRecord.self])
        let modelConfiguration = ModelConfiguration(schema: dataModelSchema, isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: dataModelSchema, configurations: [modelConfiguration])
        return ModelContext(modelContainer)
    }

    /// Convenience: Generates a realistic `UserEntity` with a unique suffix so we can create multiple distinct users in tests.
    private func makeUserEntity(suffix: String) -> UserEntity {
        UserEntity(
            gender: "male",
            name: .init(title: "Mr", first: "John\(suffix)", last: "Doe"),
            location: .init(
                street: .init(number: 1, name: "Main"),
                city: "Istanbul", state: "Marmara", country: "Turkey",
                postcode: .int(34000),
                coordinates: .init(latitude: "0", longitude: "0"),
                timezone: .init(offset: "+03:00", description: "TRT")
            ),
            email: "john\(suffix)@example.com",
            login: .init(uuid: "uuid-\(suffix)", username: "john\(suffix)", password: "p", salt: "s", md5: "m", sha1: "s1", sha256: "s256"),
            dob: .init(date: "1990-01-01T00:00:00Z", age: 34),
            registered: .init(date: "2020-01-01T00:00:00Z", age: 4),
            phone: "0", cell: "1",
            id: .init(name: "TC", value: "id-\(suffix)"),
            picture: .init(large: "L", medium: "M", thumbnail: "T"),
            nat: "TR"
        )
    }

    /// Ensures adding bookmarks increments count, `isBookmarked` returns true,
    /// and ordering is newest-first by `updatedAt`.
    @Test
    func addBookmarks_updatesCount_checksMembership_andOrdersNewestFirst() throws {
        let modelContext = try makeInMemoryModelContext()
        let bookmarkManagerUnderTest = BookmarkManager(modelContext: modelContext)

        let firstUser = makeUserEntity(suffix: "A")
        let secondUser = makeUserEntity(suffix: "B")

        bookmarkManagerUnderTest.addBookmark(firstUser)
        bookmarkManagerUnderTest.addBookmark(secondUser)

        #expect(bookmarkManagerUnderTest.isBookmarked(firstUser))
        #expect(bookmarkManagerUnderTest.bookmarkedCount == 2)

        let fullNamesInOrder = bookmarkManagerUnderTest.bookmarkedUsers.map(\.fullName)
        #expect(fullNamesInOrder.first == secondUser.fullName) // newest first
        #expect(fullNamesInOrder.last == firstUser.fullName)
    }

    /// Ensures toggling a not-bookmarked user adds it, and toggling again removes it.
    @Test
    func toggleBookmark_addsThenRemovesUser() throws {
        let modelContext = try makeInMemoryModelContext()
        let bookmarkManagerUnderTest = BookmarkManager(modelContext: modelContext)

        let user = makeUserEntity(suffix: "X")
        #expect(!bookmarkManagerUnderTest.isBookmarked(user))

        bookmarkManagerUnderTest.toggleBookmark(user)
        #expect(bookmarkManagerUnderTest.isBookmarked(user))
        #expect(bookmarkManagerUnderTest.bookmarkedCount == 1)

        bookmarkManagerUnderTest.toggleBookmark(user)
        #expect(!bookmarkManagerUnderTest.isBookmarked(user))
        #expect(bookmarkManagerUnderTest.bookmarkedCount == 0)
    }

    /// Ensures clearing all bookmarks results in an empty collection and zero count.
    @Test
    func clearAllBookmarks_removesAllRecords() throws {
        let modelContext = try makeInMemoryModelContext()
        let bookmarkManagerUnderTest = BookmarkManager(modelContext: modelContext)

        bookmarkManagerUnderTest.addBookmark(makeUserEntity(suffix: "1"))
        bookmarkManagerUnderTest.addBookmark(makeUserEntity(suffix: "2"))
        #expect(bookmarkManagerUnderTest.bookmarkedCount == 2)

        bookmarkManagerUnderTest.clearAllBookmarks()
        #expect(bookmarkManagerUnderTest.bookmarkedCount == 0)
        #expect(bookmarkManagerUnderTest.bookmarkedUsers.isEmpty)
    }
}
