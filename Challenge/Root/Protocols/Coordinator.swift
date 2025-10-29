import UIKit

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    @MainActor func start()
}
