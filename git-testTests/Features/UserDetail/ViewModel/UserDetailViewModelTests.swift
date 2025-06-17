import XCTest
@testable import git_test

final class UserDetailViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockRepository: MockGitHubRepository!
    private var viewModel: UserDetailViewModel!
    private var capturedStates: [UserDetailState] = []
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockGitHubRepository()
        viewModel = UserDetailViewModel(username: "testuser", repository: mockRepository)
        capturedStates = []
    }
    
    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - viewDidLoad Tests
    
    func testViewDidLoad_whenAllRequestsSucceed_shouldUpdateStateToLoaded() async {
        // GIVEN
        let mockUserDetail = createMockUserDetail()
        let mockRepositories = createMockRepositories(count: 3)
        
        mockRepository.userDetailToReturn = mockUserDetail
        mockRepository.repositoriesToReturn = mockRepositories
        
        // Configure expectations
        let expectation = expectation(description: "State changed twice")
        expectation.expectedFulfillmentCount = 2
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.viewDidLoad()
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedStates.count, 2)
        
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .loaded(let userDetail, let repositories) = capturedStates[1] {
            XCTAssertEqual(userDetail.login, mockUserDetail.login)
            XCTAssertEqual(repositories.count, mockRepositories.count)
        } else {
            XCTFail("Second state should be loaded")
        }
        
        XCTAssertTrue(mockRepository.fetchUserDetailCalled)
        XCTAssertTrue(mockRepository.fetchRepositoriesCalled)
    }
    
    func testViewDidLoad_whenUserDetailFails_shouldUpdateStateToError() async {
        // GIVEN
        mockRepository.shouldThrowError = true
        
        // Configure expectations
        let expectation = expectation(description: "State changed twice")
        expectation.expectedFulfillmentCount = 2
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.viewDidLoad()
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedStates.count, 2)
        
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .error(let message) = capturedStates[1] {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Second state should be error")
        }
        
        XCTAssertTrue(mockRepository.fetchUserDetailCalled)
        XCTAssertFalse(mockRepository.fetchRepositoriesCalled)
    }
    
    func testViewDidLoad_whenOnlyRepositoriesFail_shouldLoadUserWithEmptyRepositories() async {
        // GIVEN
        let mockUserDetail = createMockUserDetail()
        mockRepository.userDetailToReturn = mockUserDetail
        
        // Configure repository to succeed for user details but fail for repositories
        // We need to modify the mock to have specific error control for repositories
        
        // Success for user detail
        mockRepository.shouldThrowError = false
        
        // Create a custom mock for this specific test case
        class CustomMockRepository: MockGitHubRepository {
            override func fetchRepositories(username: String, perPage: Int) async throws -> [Repository] {
                // Mark that the method was called but always throw error
                fetchRepositoriesCalled = true
                throw NetworkError.noData
            }
        }
        
        // Replace with our custom mock
        let customMock = CustomMockRepository()
        customMock.userDetailToReturn = mockUserDetail
        
        // Importante: necesitamos reemplazar la referencia al mockRepository para las verificaciones
        mockRepository = customMock
        viewModel = UserDetailViewModel(username: "testuser", repository: customMock)
        
        // Configure expectations
        let expectation = expectation(description: "State changed twice")
        expectation.expectedFulfillmentCount = 2
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.viewDidLoad()
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedStates.count, 2)
        
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .loaded(let userDetail, let repositories) = capturedStates[1] {
            XCTAssertEqual(userDetail.login, mockUserDetail.login)
            XCTAssertTrue(repositories.isEmpty)
        } else {
            XCTFail("Second state should be loaded with empty repositories")
        }
        
        XCTAssertTrue(mockRepository.fetchUserDetailCalled)
        XCTAssertTrue(mockRepository.fetchRepositoriesCalled, "fetchRepositories should have been called")
    }
    
    // MARK: - refreshData Tests
    
    func testRefreshData_whenSucceeds_shouldUpdateStateToLoaded() async {
        // GIVEN
        let mockUserDetail = createMockUserDetail()
        let mockRepositories = createMockRepositories(count: 2)
        
        mockRepository.userDetailToReturn = mockUserDetail
        mockRepository.repositoriesToReturn = mockRepositories
        
        // Configure expectations
        let expectation = expectation(description: "State changed twice")
        expectation.expectedFulfillmentCount = 2
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.refreshData()
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedStates.count, 2)
        
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .loaded(let userDetail, let repositories) = capturedStates[1] {
            XCTAssertEqual(userDetail.login, mockUserDetail.login)
            XCTAssertEqual(repositories.count, mockRepositories.count)
        } else {
            XCTFail("Second state should be loaded")
        }
        
        XCTAssertTrue(mockRepository.fetchUserDetailCalled)
        XCTAssertTrue(mockRepository.fetchRepositoriesCalled)
    }
    
    func testRefreshData_whenFails_shouldUpdateStateToError() async {
        // GIVEN
        mockRepository.shouldThrowError = true
        
        // Configure expectations
        let expectation = expectation(description: "State changed twice")
        expectation.expectedFulfillmentCount = 2
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.refreshData()
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedStates.count, 2)
        
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .error(let message) = capturedStates[1] {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Second state should be error")
        }
        
        XCTAssertTrue(mockRepository.fetchUserDetailCalled)
    }
    
    // MARK: - State Management Tests
    
    func testStateManagement_initialStateShouldBeLoading() {
        // GIVEN - ViewModel was initialized in setUp
        
        // WHEN - Initial state without any actions
        
        // THEN
        if case .loading = viewModel.state {
            // State is correctly initialized to loading
            XCTAssert(true)
        } else {
            XCTFail("Initial state should be loading")
        }
    }
    
    func testStateManagement_stateChangesShouldTriggerCallback() async {
        // GIVEN
        let mockUserDetail = createMockUserDetail()
        let mockRepositories = createMockRepositories(count: 1)
        
        mockRepository.userDetailToReturn = mockUserDetail
        mockRepository.repositoriesToReturn = mockRepositories
        
        // Configure expectations
        var callbackCount = 0
        let expectation = self.expectation(description: "State callback executed")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.onStateChanged = { _ in
            callbackCount += 1
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.viewDidLoad()
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(callbackCount, 2)
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
