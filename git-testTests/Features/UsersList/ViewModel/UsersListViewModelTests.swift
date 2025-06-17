import XCTest
@testable import git_test

final class UsersListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockRepository: MockGitHubRepository!
    private var viewModel: UsersListViewModel!
    private var stateChangedExpectation: XCTestExpectation!
    private var capturedStates: [UsersListState] = []
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockGitHubRepository()
        viewModel = UsersListViewModel(repository: mockRepository)
        capturedStates = []
    }
    
    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - viewDidLoad Tests
    
    func testViewDidLoad_whenSucceeds_shouldUpdateStateToLoaded() async {
        // GIVEN
        let mockUsers = MockData.createMockUsers()
        mockRepository.usersToReturn = mockUsers
        
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
        
        if case .loaded(let users) = capturedStates[1] {
            XCTAssertEqual(users.count, mockUsers.count)
            XCTAssertEqual(users[0].id, mockUsers[0].id)
        } else {
            XCTFail("Second state should be loaded")
        }
        
        XCTAssertTrue(mockRepository.fetchUsersCalled)
        XCTAssertEqual(mockRepository.lastFetchUsersPerPage, 30)
        XCTAssertEqual(mockRepository.lastFetchUsersSince, 0)
    }
    
    func testViewDidLoad_whenFails_shouldUpdateStateToError() async {
        // GIVEN
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .noData
        
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
        
        XCTAssertTrue(mockRepository.fetchUsersCalled)
    }
    
    // MARK: - refreshUsers Tests
    
    func testRefreshUsers_whenSucceeds_shouldReloadUsers() async {
        // GIVEN
        // 1. Initial load with some users
        let initialUsers = MockData.createMockUsers(count: 3)
        mockRepository.usersToReturn = initialUsers
        
        let initialLoadExpectation = expectation(description: "Initial load")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                initialLoadExpectation.fulfill()
            }
        }
        
        viewModel.viewDidLoad()
        await fulfillment(of: [initialLoadExpectation], timeout: 1.0)
        
        // 2. Prepare new data for refresh
        let refreshedUsers = MockData.createMockUsers(count: 2)
        mockRepository.usersToReturn = refreshedUsers
        
        // Reset the fetchUsersCalled flag to track the new call
        mockRepository.fetchUsersCalled = false
        
        // Configure expectations for refresh
        let refreshExpectation = expectation(description: "Refresh completed")
        refreshExpectation.expectedFulfillmentCount = 2  // loading + loaded
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            refreshExpectation.fulfill()
        }
        
        // WHEN
        viewModel.refreshUsers()
        
        // THEN
        await fulfillment(of: [refreshExpectation], timeout: 1.0)
        
        // Verify the repository was called
        XCTAssertTrue(mockRepository.fetchUsersCalled)
        XCTAssertEqual(mockRepository.lastFetchUsersSince, 0, "Should start from the beginning when refreshing")
        
        // Verify state transitions
        XCTAssertEqual(capturedStates.count, 2)
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .loaded(let users) = capturedStates[1] {
            XCTAssertEqual(users.count, refreshedUsers.count)
            XCTAssertEqual(users[0].id, refreshedUsers[0].id)
        } else {
            XCTFail("Second state should be loaded")
        }
    }
    
    func testRefreshUsers_whenFails_shouldShowError() async {
        // GIVEN
        // 1. Initial load with some users
        let initialUsers = MockData.createMockUsers()
        mockRepository.usersToReturn = initialUsers
        
        let initialLoadExpectation = expectation(description: "Initial load")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                initialLoadExpectation.fulfill()
            }
        }
        
        viewModel.viewDidLoad()
        await fulfillment(of: [initialLoadExpectation], timeout: 1.0)
        
        // 2. Set up error for refresh
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .noData
        
        // Reset the fetchUsersCalled flag to track the new call
        mockRepository.fetchUsersCalled = false
        
        // Configure expectations for refresh
        let refreshExpectation = expectation(description: "Refresh failed")
        refreshExpectation.expectedFulfillmentCount = 2  // loading + error
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            refreshExpectation.fulfill()
        }
        
        // WHEN
        viewModel.refreshUsers()
        
        // THEN
        await fulfillment(of: [refreshExpectation], timeout: 1.0)
        
        // Verify the repository was called
        XCTAssertTrue(mockRepository.fetchUsersCalled)
        
        // Verify state transitions
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
    }
    
    // MARK: - loadMoreUsers Tests
    
    func testLoadMoreUsers_whenSucceeds_shouldAppendNewUsers() async {
        // GIVEN
        let initialUsers = MockData.createMockUsers(count: 3)
        let additionalUsers = MockData.createMockUsers(count: 2)
        let expectation1 = expectation(description: "Initial load")
        let expectation2 = expectation(description: "Load more")
        
        mockRepository.usersToReturn = initialUsers
        
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                expectation1.fulfill()
            }
            if case .loadedMore = state {
                expectation2.fulfill()
            }
        }
        
        // WHEN - Initial load
        viewModel.viewDidLoad()
        await fulfillment(of: [expectation1], timeout: 1.0)
        
        // Reset for next call
        mockRepository.usersToReturn = additionalUsers
        
        // WHEN - Load more
        viewModel.loadMoreUsers()
        
        // THEN
        await fulfillment(of: [expectation2], timeout: 1.0)
        
        XCTAssertEqual(mockRepository.lastFetchUsersSince, initialUsers.last?.id)
        
        // Check the state directly without creating a new expectation
        if case .loadedMore(let users) = viewModel.state {
            XCTAssertEqual(users.count, initialUsers.count + additionalUsers.count)
        } else {
            XCTFail("State should be loadedMore")
        }
    }
    
    func testLoadMoreUsers_whenNoInitialUsers_shouldNotLoadMore() async {
        // GIVEN
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .noData
        
        let expectation1 = expectation(description: "Initial error")
        viewModel.onStateChanged = { state in
            if case .error = state {
                expectation1.fulfill()
            }
        }
        
        // Set initial error state
        viewModel.viewDidLoad()
        await fulfillment(of: [expectation1], timeout: 1.0)
        
        // Reset repository flags
        mockRepository.fetchUsersCalled = false
        mockRepository.shouldThrowError = false
        
        // WHEN
        viewModel.loadMoreUsers()
        
        // THEN
        // Small delay to ensure any potential async operation would have started
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Should not call fetchUsers since we're in error state
        XCTAssertFalse(mockRepository.fetchUsersCalled)
    }
    
    // MARK: - searchUsers Tests
    
    func testSearchUsers_whenSucceeds_shouldUpdateStateWithSearchResults() async {
        // GIVEN
        let searchResults = MockData.createMockSearchResults()
        mockRepository.searchResultsToReturn = searchResults
        
        // Configure expectations
        let expectation = expectation(description: "Search completed")
        expectation.expectedFulfillmentCount = 2  // Loading + Loaded
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.searchUsers(query: "test")
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockRepository.searchUsersCalled)
        XCTAssertEqual(mockRepository.lastSearchQuery, "test")
        
        XCTAssertEqual(capturedStates.count, 2)
        if case .loading = capturedStates[0] {
            // First state is loading
        } else {
            XCTFail("First state should be loading")
        }
        
        if case .loaded(let users) = capturedStates[1] {
            XCTAssertEqual(users.count, searchResults.count)
        } else {
            XCTFail("Second state should be loaded with search results")
        }
    }
    
    func testSearchUsers_whenFails_shouldUpdateStateToError() async {
        // GIVEN
        mockRepository.shouldThrowError = true
        
        // Configure expectations
        let expectation = expectation(description: "Search failed")
        expectation.expectedFulfillmentCount = 2  // Loading + Error
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            expectation.fulfill()
        }
        
        // WHEN
        viewModel.searchUsers(query: "test")
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockRepository.searchUsersCalled)
        
        XCTAssertEqual(capturedStates.count, 2)
        if case .error = capturedStates[1] {
            // Correct error state
        } else {
            XCTFail("Second state should be error")
        }
    }
    
    func testSearchUsers_whenEmptyQuery_shouldNotPerformSearch() async {
        // GIVEN
        // Reset flags
        mockRepository.searchUsersCalled = false
        
        // WHEN
        viewModel.searchUsers(query: "   ")
        
        // THEN
        // Small delay to ensure any potential async operation would have started
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        XCTAssertFalse(mockRepository.searchUsersCalled)
    }
    
    // MARK: - cancelSearch Tests
    
    func testCancelSearch_whenSearchActive_shouldRestoreOriginalUsers() async {
        // GIVEN
        // 1. Initial load
        let initialUsers = MockData.createMockUsers()
        mockRepository.usersToReturn = initialUsers
        
        let initialLoadExpectation = expectation(description: "Initial load")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                initialLoadExpectation.fulfill()
            }
        }
        
        viewModel.viewDidLoad()
        await fulfillment(of: [initialLoadExpectation], timeout: 1.0)
        
        // 2. Search
        let searchResults = MockData.createMockSearchResults()
        mockRepository.searchResultsToReturn = searchResults
        
        let searchExpectation = expectation(description: "Search completed")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                searchExpectation.fulfill()
            }
        }
        
        viewModel.searchUsers(query: "test")
        await fulfillment(of: [searchExpectation], timeout: 1.0)
        
        // Reset states and configure expectations for cancel
        let cancelExpectation = expectation(description: "Cancel completed")
        capturedStates = []
        
        viewModel.onStateChanged = { [weak self] state in
            self?.capturedStates.append(state)
            cancelExpectation.fulfill()
        }
        
        // WHEN
        viewModel.cancelSearch()
        
        // THEN
        await fulfillment(of: [cancelExpectation], timeout: 1.0)
        
        if case .loaded(let users) = capturedStates[0] {
            XCTAssertEqual(users.count, initialUsers.count)
            XCTAssertEqual(users[0].id, initialUsers[0].id)
        } else {
            XCTFail("State should be loaded with original users")
        }
    }
}
