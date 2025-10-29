import Foundation

// MARK: - AppLogger
enum AppLogger {
    static func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}
