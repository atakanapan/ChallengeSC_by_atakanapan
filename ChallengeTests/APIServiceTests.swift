import Foundation
import Testing
@testable import Challenge

@Suite("APIService")
struct APIServiceTests {

    /// Ensures a successful request decodes the payload and writes it to the cache.
    @Test
    func fetchUsers_success_decodesAndWritesToCache() async throws {
        let httpClientMock = MockHTTPClient(.success(data: TestFixtures.singleUserPayload, statusCode: 200))
        let usersCacheStub = InMemoryUsersCacheStub()
        let apiServiceUnderTest = APIService(httpClient: httpClientMock, usersCache: usersCacheStub)

        let response = try await apiServiceUnderTest.fetchUsers(page: 1, results: 1, seed: "seed-xyz")

        #expect(response.results.count == 1)
        #expect(response.info.page == 1)
        #expect(response.info.seed == "seed-xyz")

        let expectedCacheKey = RandomUserEndpoint(page: 1, results: 1, seed: "seed-xyz").cacheKey
        let cachedData = await usersCacheStub.read(for: expectedCacheKey)
        #expect(cachedData != nil)
    }

    /// Ensures non-2xx HTTP responses are surfaced as `NetworkError.httpError`.
    @Test
    func fetchUsers_httpError_throwsNetworkErrorHttpError() async {
        let httpClientMock = MockHTTPClient(.success(data: Data(), statusCode: 500))
        let usersCacheStub = InMemoryUsersCacheStub()
        let apiServiceUnderTest = APIService(httpClient: httpClientMock, usersCache: usersCacheStub)

        do {
            _ = try await apiServiceUnderTest.fetchUsers(page: 1, results: 1, seed: nil)
            Issue.record("Expected `NetworkError.httpError` to be thrown but no error was thrown.")
        } catch let networkError as NetworkError {
            switch networkError {
            case .httpError(let statusCode):
                #expect(statusCode == 500)
            default:
                Issue.record("Unexpected NetworkError variant: \(networkError)")
            }
        } catch {
            Issue.record("Unexpected error type thrown: \(error)")
        }
    }

    /// Ensures that when the network layer throws, the service falls back to a cached value if present.
    @Test
    func fetchUsers_networkFailure_usesCachedPayloadAsFallback() async throws {
        // Seed cache with valid payload.
        let endpoint = RandomUserEndpoint(page: 1, results: 1, seed: "seed-xyz")
        let usersCacheStub = InMemoryUsersCacheStub()
        await usersCacheStub.write(TestFixtures.singleUserPayload, for: endpoint.cacheKey)

        struct ArbitraryError: Error {}
        let httpClientMock = MockHTTPClient(.error(ArbitraryError()))
        let apiServiceUnderTest = APIService(httpClient: httpClientMock, usersCache: usersCacheStub)

        let response = try await apiServiceUnderTest.fetchUsers(page: 1, results: 1, seed: "seed-xyz")
        #expect(response.results.first?.email == "john.doe@example.com")
    }
}
