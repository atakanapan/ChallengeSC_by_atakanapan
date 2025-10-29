import Foundation
import SwiftData

final class BookmarksPersistenceController {
    static let shared = BookmarksPersistenceController()

    let container: ModelContainer
    let context: ModelContext

    private init() {
        do {
            let schema = Schema([BookmarkRecord.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [configuration])
            self.context = ModelContext(container)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
}
