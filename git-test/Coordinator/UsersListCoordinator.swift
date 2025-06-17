import UIKit

/// Coordinator responsible for managing the users list flow
/// Handles the navigation and presentation of GitHub users list and transitions to user details
///
/// Part of the programmatic UI implementation using the Coordinator pattern
/// to separate navigation logic from view controllers
final class UsersListCoordinator: Coordinator {
    /// Collection of child coordinators
    /// Required by the Coordinator protocol
    var childCoordinators: [Coordinator] = []
    /// Navigation controller used to present view controllers
    /// Required by the Coordinator protocol
    var navigationController: UINavigationController
    /// Repository interface for fetching GitHub data
    /// Follows Dependency Inversion Principle for better testability
    private let repository: GitHubRepositoryProtocol
    
    /// Creates a new UsersListCoordinator
    /// - Parameters:
    ///   - navigationController: The navigation controller to present view controllers on
    ///   - repository: Data repository implementation (defaults to standard implementation)
    init(navigationController: UINavigationController, repository: GitHubRepositoryProtocol = GitHubRepository()) {
        self.navigationController = navigationController
        self.repository = repository
    }
    
    /// Starts the users list flow
    /// Creates and configures the users list view controller and presents it
    func start() {
        let viewModel = UsersListViewModel(repository: repository)
        let viewController = UsersListViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    /// Handles selection of a specific user from the list
    /// Creates a UserDetailCoordinator and delegates the user detail flow to it
    /// - Parameter username: Username of the selected GitHub user
    func didSelectUser(with username: String) {
        let userDetailCoordinator = UserDetailCoordinator(navigationController: navigationController, username: username, repository: repository)
        childCoordinators.append(userDetailCoordinator)
        userDetailCoordinator.start()
    }
}
