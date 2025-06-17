import XCTest
@testable import git_test

final class GitHubRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockNetworkService: MockNetworkService!
    private var repository: GitHubRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        repository = GitHubRepository(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        mockNetworkService = nil
        repository = nil
        super.tearDown()
    }
    
    // MARK: - fetchUserDetail Tests
    
    func testFetchUserDetail_whenSucceeds_shouldReturnUserDetail() async throws {
        // GIVEN
        let expectedUserDetail = createMockUserDetail()
        mockNetworkService.userDetailToReturn = expectedUserDetail
        
        // WHEN
        let result = try await repository.fetchUserDetail(username: "testuser")
        
        // THEN
        XCTAssertTrue(mockNetworkService.fetchCalled)
        XCTAssertNotNil(mockNetworkService.lastFetchURL)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("testuser") ?? false)
        XCTAssertEqual(result.login, expectedUserDetail.login)
    }
    
    func testFetchUserDetail_whenNetworkFails_shouldThrowError() async {
        // GIVEN
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = .serverError(404)
        
        // WHEN / THEN
        do {
            _ = try await repository.fetchUserDetail(username: "testuser")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(mockNetworkService.fetchCalled)
            XCTAssertNotNil(mockNetworkService.lastFetchURL)
            XCTAssertEqual(error as? NetworkError, .serverError(404))
        }
    }
    
    // MARK: - fetchUsers Tests
    
    func testFetchUsers_whenSucceeds_shouldReturnUsers() async throws {
        // GIVEN
        let expectedUsers = createMockUsers(count: 3)
        mockNetworkService.usersToReturn = expectedUsers
        let perPage = 10
        let since = 20
        
        // WHEN
        let result = try await repository.fetchUsers(perPage: perPage, since: since)
        
        // THEN
        XCTAssertTrue(mockNetworkService.fetchCalled)
        XCTAssertNotNil(mockNetworkService.lastFetchURL)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("per_page=\(perPage)") ?? false)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("since=\(since)") ?? false)
        XCTAssertEqual(result.count, expectedUsers.count)
        XCTAssertEqual(result.first?.login, expectedUsers.first?.login)
    }
    
    func testFetchUsers_whenNetworkFails_shouldThrowError() async {
        // GIVEN
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = .decodingError
        
        // WHEN / THEN
        do {
            _ = try await repository.fetchUsers(perPage: 10, since: 0)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(mockNetworkService.fetchCalled)
            XCTAssertNotNil(mockNetworkService.lastFetchURL)
            XCTAssertEqual(error as? NetworkError, .decodingError)
        }
    }
    
    // MARK: - fetchRepositories Tests
    
    func testFetchRepositories_whenSucceeds_shouldReturnRepositories() async throws {
        // GIVEN
        let expectedRepositories = createMockRepositories(count: 3)
        mockNetworkService.repositoriesToReturn = expectedRepositories
        let perPage = 15
        
        // WHEN
        let result = try await repository.fetchRepositories(username: "testuser", perPage: perPage)
        
        // THEN
        XCTAssertTrue(mockNetworkService.fetchCalled)
        XCTAssertNotNil(mockNetworkService.lastFetchURL)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("testuser") ?? false)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("per_page=\(perPage)") ?? false)
        XCTAssertEqual(result.count, expectedRepositories.count)
        XCTAssertEqual(result.first?.name, expectedRepositories.first?.name)
    }
    
    func testFetchRepositories_whenNetworkFails_shouldThrowError() async {
        // GIVEN
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = .noData
        
        // WHEN / THEN
        do {
            _ = try await repository.fetchRepositories(username: "testuser", perPage: 10)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(mockNetworkService.fetchCalled)
            XCTAssertNotNil(mockNetworkService.lastFetchURL)
            XCTAssertEqual(error as? NetworkError, .noData)
        }
    }
    
    // MARK: - searchUsers Tests
    
    func testSearchUsers_whenSucceeds_shouldReturnUsers() async throws {
        // GIVEN
        let expectedUsers = createMockUsers(count: 2)
        let searchResponse = UserSearchResponse(totalCount: expectedUsers.count, incompleteResults: false, items: expectedUsers)
        mockNetworkService.searchResponseToReturn = searchResponse
        let perPage = 25
        
        // WHEN
        let result = try await repository.searchUsers(query: "test", perPage: perPage)
        
        // THEN
        XCTAssertTrue(mockNetworkService.fetchCalled)
        XCTAssertNotNil(mockNetworkService.lastFetchURL)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("q=test") ?? false)
        XCTAssertTrue(mockNetworkService.lastFetchURL?.absoluteString.contains("per_page=\(perPage)") ?? false)
        XCTAssertEqual(result.count, expectedUsers.count)
        XCTAssertEqual(result.first?.login, expectedUsers.first?.login)
    }
    
    func testSearchUsers_whenNetworkFails_shouldThrowError() async {
        // GIVEN
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = .invalidURL
        
        // WHEN / THEN
        do {
            _ = try await repository.searchUsers(query: "test", perPage: 10)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(mockNetworkService.fetchCalled)
            XCTAssertNotNil(mockNetworkService.lastFetchURL)
            XCTAssertEqual(error as? NetworkError, .invalidURL)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockUserDetail() -> UserDetail {
        return UserDetail(
            login: "testuser",
            avatarUrl: "https://example.com/avatar.png",
            name: "Test User",
            followers: 100,
            following: 50
        )
    }
    
    private func createMockUsers(count: Int) -> [User] {
        var users = [User]()
        for i in 1...count {
            let user = User(
                id: i,
                login: "user\(i)",
                avatarUrl: "https://example.com/avatar\(i).png"
            )
            users.append(user)
        }
        return users
    }
    
    private func createMockRepositories(count: Int) -> [Repository] {
        var repositories = [Repository]()
        for i in 1...count {
            let repo = Repository(
                id: i,
                name: "repo\(i)",
                language: "Swift",
                starsCount: i * 10,
                description: "Repository \(i) description",
                htmlUrl: "https://github.com/testuser/repo\(i)"
            )
            repositories.append(repo)
        }
        return repositories
    }
}
