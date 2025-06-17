import UIKit

/// Defines the core behavior of a coordinator in the application
/// 
/// The Coordinator pattern centralizes navigation logic and decouples view controllers,
/// supporting a clean architecture approach with programmatic UI.
/// 
/// Coordinators are responsible for:
/// - Managing navigation flow between screens
/// - Creating and configuring view controllers
/// - Handling the relationships between different parts of the application
protocol Coordinator: AnyObject {
    /// Collection of child coordinators managed by this coordinator
    /// Used to maintain reference to child flows and prevent deallocation
    var childCoordinators: [Coordinator] { get set }
    /// The navigation controller used by this coordinator to present view controllers
    var navigationController: UINavigationController { get set }
    
    /// Entry point for the coordinator
    /// Initiates the flow managed by this coordinator
    func start()
}

/// Default implementation of common coordinator functionality
extension Coordinator {
    /// Adds a child coordinator to this coordinator's management
    /// - Parameter coordinator: The coordinator to be managed
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    /// Removes a child coordinator from this coordinator's management
    /// - Parameter coordinator: The coordinator to be removed
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
