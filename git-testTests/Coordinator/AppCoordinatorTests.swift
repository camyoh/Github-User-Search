import XCTest
@testable import git_test

final class AppCoordinatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var navigationController: UINavigationController!
    private var appCoordinator: AppCoordinator!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
    }
    
    override func tearDown() {
        navigationController = nil
        appCoordinator = nil
        super.tearDown()
    }
    
    // MARK: - start() Tests
    
    func testStart_shouldInitiateUsersListCoordinator() {
        // GIVEN
        XCTAssertTrue(appCoordinator.childCoordinators.isEmpty)
        
        // WHEN
        appCoordinator.start()
        
        // THEN
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertTrue(appCoordinator.childCoordinators.first is UsersListCoordinator)
    }
    
    // MARK: - Child Coordinators Management Tests
    
    func testAddChildCoordinator_shouldAddCoordinatorToChildArray() {
        // GIVEN
        let mockCoordinator = MockCoordinator(navigationController: navigationController)
        XCTAssertTrue(appCoordinator.childCoordinators.isEmpty)
        
        // WHEN
        appCoordinator.addChildCoordinator(mockCoordinator)
        
        // THEN
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertTrue(appCoordinator.childCoordinators.contains { $0 === mockCoordinator })
    }
    
    func testRemoveChildCoordinator_shouldRemoveCoordinatorFromChildArray() {
        // GIVEN
        let mockCoordinator = MockCoordinator(navigationController: navigationController)
        appCoordinator.addChildCoordinator(mockCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        
        // WHEN
        appCoordinator.removeChildCoordinator(mockCoordinator)
        
        // THEN
        XCTAssertTrue(appCoordinator.childCoordinators.isEmpty)
    }
    
    func testRemoveChildCoordinator_whenCoordinatorNotInArray_shouldNotCrash() {
        // GIVEN
        let mockCoordinator1 = MockCoordinator(navigationController: navigationController)
        let mockCoordinator2 = MockCoordinator(navigationController: navigationController)
        appCoordinator.addChildCoordinator(mockCoordinator1)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        
        // WHEN
        appCoordinator.removeChildCoordinator(mockCoordinator2) // Not in the array
        
        // THEN
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertTrue(appCoordinator.childCoordinators.contains { $0 === mockCoordinator1 })
    }
    
    func testRemoveChildCoordinator_whenMultipleCoordinatorsExist_shouldRemoveOnlySpecificOne() {
        // GIVEN
        let mockCoordinator1 = MockCoordinator(navigationController: navigationController)
        let mockCoordinator2 = MockCoordinator(navigationController: navigationController)
        appCoordinator.addChildCoordinator(mockCoordinator1)
        appCoordinator.addChildCoordinator(mockCoordinator2)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 2)
        
        // WHEN
        appCoordinator.removeChildCoordinator(mockCoordinator1)
        
        // THEN
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertTrue(appCoordinator.childCoordinators.contains { $0 === mockCoordinator2 })
    }
}
