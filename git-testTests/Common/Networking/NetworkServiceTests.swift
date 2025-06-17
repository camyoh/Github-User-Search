import XCTest
@testable import git_test

final class NetworkServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockURLSession: MockURLSession!
    private var networkService: NetworkService!
    
    // Test models
    private struct TestModel: Decodable, Equatable {
        let id: Int
        let name: String
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkService = NetworkService(session: mockURLSession)
    }
    
    override func tearDown() {
        mockURLSession = nil
        networkService = nil
        super.tearDown()
    }
    
    // MARK: - fetch<T> Tests
    
    func testFetch_whenValidJSONResponse_shouldReturnDecodedObject() async throws {
        // GIVEN
        let expectedModel = TestModel(id: 1, name: "Test")
        let jsonData = """
        {
            "id": 1,
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        mockURLSession.data = jsonData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // WHEN
        let result: TestModel = try await networkService.fetch(url: URL(string: "https://api.example.com")!)
        
        // THEN
        XCTAssertEqual(result, expectedModel)
    }
    
    func testFetch_whenInvalidResponse_shouldThrowNoData() async {
        // GIVEN
        mockURLSession.data = Data()
        mockURLSession.response = URLResponse()  // Not an HTTPURLResponse
        
        // WHEN / THEN
        do {
            let _: TestModel = try await networkService.fetch(url: URL(string: "https://api.example.com")!)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .noData)
        }
    }
    
    func testFetch_whenServerError_shouldThrowServerError() async {
        // GIVEN
        let statusCode = 404
        mockURLSession.data = Data()
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        
        // WHEN / THEN
        do {
            let _: TestModel = try await networkService.fetch(url: URL(string: "https://api.example.com")!)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .serverError(statusCode))
        }
    }
    
    func testFetch_whenDecodingFails_shouldThrowDecodingError() async {
        // GIVEN
        let invalidJsonData = Data("This is not JSON".utf8)
        mockURLSession.data = invalidJsonData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // WHEN / THEN
        do {
            let _: TestModel = try await networkService.fetch(url: URL(string: "https://api.example.com")!)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .decodingError)
        }
    }
    
    func testFetch_whenNetworkError_shouldPropagateError() async {
        // GIVEN
        struct MockError: Error {}
        mockURLSession.error = MockError()
        
        // WHEN / THEN
        do {
            let _: TestModel = try await networkService.fetch(url: URL(string: "https://api.example.com")!)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is MockError)
        }
    }
}
