import UIKit

/// Main application coordinator responsible for managing the navigation flow of the application
/// Acts as the root coordinator that owns and manages child coordinators
/// 
/// This coordinator follows the Coordinator pattern to decouple navigation logic from view controllers,
/// aligning with clean architecture principles and programmatic UI approach
final class AppCoordinator: Coordinator {
    /// Array of child coordinators managed by this coordinator
    /// Each child coordinator is responsible for a specific flow in the application
    var childCoordinators: [Coordinator] = []
    /// Main navigation controller used for presenting view controllers
    /// This is the root navigation controller of the application
    var navigationController: UINavigationController
    
    /// Initializes a new AppCoordinator
    /// - Parameter navigationController: The root navigation controller for the application
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// Starts the application flow
    /// This is the entry point for the application UI and is called by SceneDelegate
    func start() {
        showUsersList()
    }
    
    /// Displays the users list screen by creating and starting the UsersListCoordinator
    /// This is the initial screen of the application
    private func showUsersList() {
        let usersListCoordinator = UsersListCoordinator(navigationController: navigationController)
        childCoordinators.append(usersListCoordinator)
        usersListCoordinator.start()
    }
    
    /// Adds a child coordinator to this coordinator's management
    /// - Parameter coordinator: The coordinator to be added as a child
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    /// Removes a child coordinator from this coordinator's management
    /// Used for cleanup when a flow is completed
    /// - Parameter coordinator: The coordinator to be removed
    func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}
