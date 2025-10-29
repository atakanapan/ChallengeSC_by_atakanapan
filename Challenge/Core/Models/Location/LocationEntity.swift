import Foundation

// MARK: - Location Entity
struct LocationEntity: Codable {
    let street: StreetEntity
    let city: String
    let state: String
    let country: String
    let postcode: PostcodeType
    let coordinates: CoordinatesEntity
    let timezone: TimezoneEntity
    
    // Handle both String and Int postcodes
    enum PostcodeType: Codable {
        case string(String)
        case int(Int)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else {
                throw DecodingError.typeMismatch(PostcodeType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Postcode must be either String or Int"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let stringValue):
                try container.encode(stringValue)
            case .int(let intValue):
                try container.encode(intValue)
            }
        }
        
        var stringValue: String {
            switch self {
            case .string(let value):
                return value
            case .int(let value):
                return String(value)
            }
        }
    }
}
