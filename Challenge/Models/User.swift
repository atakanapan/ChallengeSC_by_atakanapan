import Foundation

// MARK: - RandomUserResponse
struct RandomUserResponse: Codable {
    let results: [User]
    let info: Info
}

// MARK: - Info
struct Info: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

// MARK: - User
struct User: Codable, Equatable {
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob: DateOfBirth
    let registered: DateOfBirth
    let phone: String
    let cell: String
    let id: ID
    let picture: Picture
    let nat: String
    
    // MARK: - Computed Properties
    var fullName: String {
        return "\(name.title) \(name.first) \(name.last)"
    }
    
    var fullAddress: String {
        return "\(location.street.number) \(location.street.name), \(location.city), \(location.state), \(location.country), \(location.postcode)"
    }
    
    var age: Int {
        return dob.age
    }
    
    // Unique identifier for the user (using a combination of fields)
    var uniqueID: String {
        return "\(email)_\(login.username)"
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
}

// MARK: - DateOfBirth
struct DateOfBirth: Codable {
    let date: String
    let age: Int
}

// MARK: - ID
struct ID: Codable {
    let name: String?
    let value: String?
}

// MARK: - Location
struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: PostcodeType
    let coordinates: Coordinates
    let timezone: Timezone
    
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

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

// MARK: - Street
struct Street: Codable {
    let number: Int
    let name: String
}

// MARK: - Timezone
struct Timezone: Codable {
    let offset: String
    let description: String
}

// MARK: - Login
struct Login: Codable {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}

// MARK: - Name
struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

// MARK: - Picture
struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}