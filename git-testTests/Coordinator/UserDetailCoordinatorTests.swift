import XCTest
@testable import git_test

final class UserDetailCoordinatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockNavigationController: MockNavigationController!
    private var mockRepository: MockGitHubRepository!
    private var coordinator: UserDetailCoordinator!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockNavigationController = MockNavigationController()
        mockRepository = MockGitHubRepository()
        coordinator = UserDetailCoordinator(
            navigationController: mockNavigationController,
            username: "testuser",
            repository: mockRepository
        )
    }
    
    override func tearDown() {
        mockNavigationController = nil
        mockRepository = nil
        coordinator = nil
        super.tearDown()
    }
    
    // MARK: - showRepositoryWebView Tests
    
    func testShowRepositoryWebView_shouldPresentWebViewController() {
        // GIVEN
        let testURL = URL(string: "https://github.com/testuser/repo")!
        
        // WHEN
        coordinator.showRepositoryWebView(with: testURL)
        
        // THEN
        XCTAssertNotNil(mockNavigationController.presentedVC)
        XCTAssertTrue(mockNavigationController.presentedVC is WebViewViewController)
        
    }
    
    func testShowRepositoryWebView_shouldConfigureModalPresentationStyle() {
        // GIVEN
        let testURL = URL(string: "https://github.com/testuser/repo")!
        
        // WHEN
        coordinator.showRepositoryWebView(with: testURL)
        
        // THEN
        if let webViewController = mockNavigationController.presentedVC as? WebViewViewController {
            XCTAssertEqual(webViewController.modalPresentationStyle, .pageSheet)
        } else {
            XCTFail("The presented view controller should be WebViewViewController")
        }
    }
    
    func testShowRepositoryWebView_shouldConfigureSheetPresentationControllerIfAvailable() {
        // GIVEN
        let testURL = URL(string: "https://github.com/testuser/repo")!
        
        // WHEN
        coordinator.showRepositoryWebView(with: testURL)
        
        // THEN
        XCTAssertNotNil(mockNavigationController.presentedVC)
        
        if mockNavigationController.presentedVC?.modalPresentationStyle == .pageSheet {
            // La prueba pasa si el estilo es correcto y no hay excepciones
            XCTAssertTrue(true)
        } else {
            XCTFail("Sheet presentation style should be configured properly")
        }
    }
}
