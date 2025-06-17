import UIKit

/// Coordinator responsible for managing the user detail flow
/// Handles navigation logic for displaying user profile and repository information
/// 
/// Part of the Coordinator pattern implementation which separates navigation concerns
/// from view controllers, following clean architecture principles
final class UserDetailCoordinator: Coordinator {
    /// Collection of child coordinators
    /// Required by Coordinator protocol
    var childCoordinators: [Coordinator] = []
    /// Navigation controller used to present view controllers
    /// Required by Coordinator protocol
    var navigationController: UINavigationController
    /// Username of the GitHub user to display details for
    private let username: String
    
    /// Repository interface for fetching data
    /// Injected dependency for better testability (Dependency Inversion Principle)
    private let repository: GitHubRepositoryProtocol
    
    /// Creates a new UserDetailCoordinator
    /// - Parameters:
    ///   - navigationController: The navigation controller to present on
    ///   - username: GitHub username to display details for
    ///   - repository: Data repository implementation (defaults to standard implementation)
    init(navigationController: UINavigationController, username: String, repository: GitHubRepositoryProtocol = GitHubRepository()) {
        self.navigationController = navigationController
        self.username = username
        self.repository = repository
    }
    
    /// Starts the user detail flow
    /// Creates and configures the user detail view controller and presents it
    func start() {
        let viewModel = UserDetailViewModel(username: username, repository: repository)
        let viewController = UserDetailViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    /// Presents a web view for displaying repository content
    /// 
    /// Configures a sheet presentation with appropriate styling and displays
    /// repository information in a web view
    /// - Parameter url: Repository URL to display
    func showRepositoryWebView(with url: URL) {
        let webViewController = WebViewViewController(url: url)
        
        // Configure modal presentation style as sheet that slides from bottom
        webViewController.modalPresentationStyle = .pageSheet
        
        // Setup sheet presentation controller
        if let sheet = webViewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        // Present from the current visible view controller
        navigationController.visibleViewController?.present(webViewController, animated: true)
    }
}
