import Foundation

/// Represents the possible states of the user detail screen
/// Uses value types to maintain a clean separation of concerns
enum UserDetailState {
    /// Initial state while fetching data
    case loading
    /// Success state with user details and repositories
    case loaded(userDetail: UserDetail, repositories: [Repository])
    /// Error state with error message
    case error(String)
}

/// Protocol defining the contract for the User Detail screen view model
/// Following Interface Segregation Principle to provide a clean API for views
protocol UserDetailViewModelProtocol {
    /// Current state of the view model
    var state: UserDetailState { get }
    
    /// Callback triggered when state changes
    /// Used by view controllers to react to state transitions
    var onStateChanged: ((UserDetailState) -> Void)? { get set }
    
    /// Initiates data loading when view appears
    func viewDidLoad()
    
    /// Reloads all data from the repository
    func refreshData()
}

/// Implementation of UserDetailViewModelProtocol
/// Responsible for managing user detail data and business logic
/// 
/// Following Single Responsibility Principle by focusing only on
/// user detail data management and state transitions
final class UserDetailViewModel: UserDetailViewModelProtocol {
    
    // MARK: - Properties
    
    /// GitHub username to fetch details for
    private let username: String
    
    /// Data source for user information
    /// Following Dependency Inversion Principle by depending on abstraction
    private let repository: GitHubRepositoryProtocol
    
    /// Current state of the view model, initially set to loading
    /// Uses property wrapper to control access
    private(set) var state: UserDetailState = .loading
    
    /// Callback for state changes
    /// Used to notify the view controller when data is loaded or errors occur
    var onStateChanged: ((UserDetailState) -> Void)?
    
    // MARK: - Constants
    
    /// Number of repositories to fetch per page
    /// Default value aligned with GitHub API standard
    private let reposPerPage = 30
    
    // MARK: - Initialization
    
    /// Creates a new UserDetailViewModel
    /// 
    /// - Parameters:
    ///   - username: GitHub username to fetch details for
    ///   - repository: Data provider for GitHub information, defaults to standard implementation
    init(username: String, repository: GitHubRepositoryProtocol = GitHubRepository()) {
        self.username = username
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Initiates data loading when view appears
    func viewDidLoad() {
        fetchUserData()
    }
    
    /// Reloads all user data and repositories
    /// Used for pull-to-refresh functionality
    func refreshData() {
        fetchUserData()
    }
    
    // MARK: - Private Methods
    
    private func fetchUserData() {
        updateState(.loading)
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // First request: Get user details
                let userDetail = try await self.repository.fetchUserDetail(username: self.username)
                
                // Second request: Get user repositories
                do {
                    let repositories = try await self.repository.fetchRepositories(username: self.username, perPage: self.reposPerPage)
                    
                    // Both requests succeeded, update UI with data
                    await MainActor.run {
                        self.updateState(.loaded(userDetail: userDetail, repositories: repositories))
                    }
                } catch {
                    // User detail succeeded but repositories failed
                    // For now, we'll show the user detail with empty repositories
                    await MainActor.run {
                        self.updateState(.loaded(userDetail: userDetail, repositories: []))
                    }
                }
            } catch {
                // User detail request failed
                await MainActor.run {
                    self.updateState(.error(String.failedToFetchUserInfo))
                }
            }
        }
    }
    
    private func updateState(_ newState: UserDetailState) {
        state = newState
        onStateChanged?(state)
    }
}
