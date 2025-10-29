import Foundation
import Testing
@testable import Challenge

/// A small set of reusable fixtures and test doubles used across test files.
enum TestFixtures {

    /// A minimal but valid RandomUser API payload with a single user.
    static let singleUserPayload: Data = """
    {
      "results": [{
        "gender":"male",
        "name":{"title":"Mr","first":"John","last":"Doe"},
        "location":{
          "street":{"number":123,"name":"Main Street"},
          "city":"Istanbul","state":"Marmara","country":"Turkey",
          "postcode":34000,
          "coordinates":{"latitude":"41.0","longitude":"28.9"},
          "timezone":{"offset":"+03:00","description":"TRT"}
        },
        "email":"john.doe@example.com",
        "login":{
          "uuid":"uuid-1","username":"johndoe","password":"p","salt":"s",
          "md5":"m","sha1":"s1","sha256":"s256"
        },
        "dob":{"date":"1990-01-01T00:00:00Z","age":34},
        "registered":{"date":"2020-01-01T00:00:00Z","age":4},
        "phone":"000","cell":"111",
        "id":{"name":"TC","value":"123"},
        "picture":{"large":"https://example.com/large.jpg","medium":"https://example.com/med.jpg","thumbnail":"https://example.com/thumb.jpg"},
        "nat":"TR"
      }],
      "info":{"seed":"seed-xyz","results":1,"page":1,"version":"1.0"}
    }
    """.data(using: .utf8)!
}

/// An HTTP client mock that can return either a successful response with a given
/// status code and data, or throw an arbitrary error.
final class MockHTTPClient: HTTPClient {

    enum Behavior {
        case success(data: Data, statusCode: Int)
        case error(Error)
    }

    var behavior: Behavior
    var lastRequestedURL: URL?

    init(_ behavior: Behavior) { self.behavior = behavior }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        lastRequestedURL = url
        switch behavior {
        case .success(let data, let statusCode):
            let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (data, httpResponse)
        case .error(let error):
            throw error
        }
    }
}

/// A simple in-memory cache stub conforming to `UsersCache` used for isolating
/// APIService tests from the disk cache implementation.
actor InMemoryUsersCacheStub: UsersCache {
    private var storage: [String: Data] = [:]

    func write(_ data: Data, for key: String) async { storage[key] = data }
    func read(for key: String) async -> Data? { storage[key] }
    func touch(key: String) async { /* no-op for stub */ }
}
