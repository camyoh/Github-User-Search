import XCTest
@testable import git_test

final class UsersListCoordinatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockNavigationController: MockNavigationController!
    private var mockRepository: MockGitHubRepository!
    private var coordinator: UsersListCoordinator!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockNavigationController = MockNavigationController()
        mockRepository = MockGitHubRepository()
        coordinator = UsersListCoordinator(
            navigationController: mockNavigationController,
            repository: mockRepository
        )
    }
    
    override func tearDown() {
        mockNavigationController = nil
        mockRepository = nil
        coordinator = nil
        super.tearDown()
    }
    
    // MARK: - didSelectUser(with:) Tests
    
    func testDidSelectUser_shouldCreateUserDetailCoordinator() {
        // GIVEN
        let username = "testuser"
        XCTAssertTrue(coordinator.childCoordinators.isEmpty)
        
        // WHEN
        coordinator.didSelectUser(with: username)
        
        // THEN
        XCTAssertEqual(coordinator.childCoordinators.count, 1)
        XCTAssertTrue(coordinator.childCoordinators.first is UserDetailCoordinator)
    }
    
    func testDidSelectUser_shouldStartUserDetailCoordinator() {
        // GIVEN
        let username = "testuser"
        
        // WHEN
        coordinator.didSelectUser(with: username)
        
        // THEN
        XCTAssertNotNil(mockNavigationController.pushedVC)
        XCTAssertTrue(mockNavigationController.pushedVC is UserDetailViewController)
    }
    
    func testDidSelectUser_shouldPassCorrectUsername() {
        // GIVEN
        let username = "specificTestUser"
        
        // WHEN
        coordinator.didSelectUser(with: username)
        
        // THEN
        XCTAssertTrue(coordinator.childCoordinators.first is UserDetailCoordinator, "Expected to create a UserDetailCoordinator")
    }
    
    func testDidSelectUser_shouldUseSharedRepository() {
        // GIVEN
        XCTAssertTrue(coordinator.childCoordinators.isEmpty)
        
        // WHEN
        coordinator.didSelectUser(with: "testuser")
        
        // THEN
        XCTAssertFalse(coordinator.childCoordinators.isEmpty)
    }
}
