import Foundation
import Testing
@testable import Challenge

@Suite("RandomUserEndpoint")
struct RandomUserEndpointTests {

    /// Verifies the endpoint builds a URL that includes page, results, and seed.
    @Test
    func url_includesPageResultsAndSeed() throws {
        let randomUserEndpoint = RandomUserEndpoint(page: 2, results: 25, seed: "abc")
        let builtURL = try randomUserEndpoint.url()

        // `#require` throws when the value is nil; use `try`.
        let urlComponents = try #require(URLComponents(url: builtURL, resolvingAgainstBaseURL: false))
        let queryItemsDictionary = Dictionary(
            uniqueKeysWithValues: (urlComponents.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        )

        #expect(queryItemsDictionary["page"] == "2")
        #expect(queryItemsDictionary["results"] == "25")
        #expect(queryItemsDictionary["seed"] == "abc")
    }

    /// Verifies the endpoint omits the seed query item when it is nil.
    @Test
    func url_omitsSeedWhenNil() throws {
        let randomUserEndpoint = RandomUserEndpoint(page: 1, results: 10, seed: nil)
        let builtURL = try randomUserEndpoint.url()

        // `#require` can throw → `try`.
        let urlComponents = try #require(URLComponents(url: builtURL, resolvingAgainstBaseURL: false))
        let queryItemNames = Set((urlComponents.queryItems ?? []).map(\.name))

        #expect(queryItemNames.contains("page"))
        #expect(queryItemNames.contains("results"))
        #expect(!queryItemNames.contains("seed"))
    }

    /// Verifies the cache key encodes seed, page, and result size consistently.
    @Test
    func cacheKey_formatsUsingSeedPageAndResults() {
        let endpointWithSeed = RandomUserEndpoint(page: 3, results: 40, seed: "seedValue")
        let endpointWithoutSeed = RandomUserEndpoint(page: 1, results: 25, seed: nil)

        #expect(endpointWithSeed.cacheKey == "seedValue_p3_r40")
        #expect(endpointWithoutSeed.cacheKey == "noseed_p1_r25")
    }
}
