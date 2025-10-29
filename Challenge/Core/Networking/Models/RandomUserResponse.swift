import Foundation

// MARK: - RandomUserResponse
struct RandomUserResponse: Codable {
    let results: [UserEntity]
    let info: Info
}

// MARK: - Info
struct Info: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}
