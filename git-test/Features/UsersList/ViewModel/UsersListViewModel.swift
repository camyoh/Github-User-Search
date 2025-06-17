import Foundation

/// Represents the possible states of the users list screen
/// Uses a type-safe approach with associated values to maintain clean state management
enum UsersListState {
    /// Initial state while fetching data
    case loading
    /// Success state with a list of users
    case loaded([User])
    /// State while loading additional users during pagination
    case loadingMore
    /// State when additional users have been loaded successfully
    case loadedMore([User])
    /// Error state with descriptive message
    case error(String)
}

/// Protocol defining the contract for the Users List screen view model
/// Following Interface Segregation Principle to provide a clean API for views
protocol UsersListViewModelProtocol {
    /// Current state of the view model
    var state: UsersListState { get }
    
    /// Flag indicating whether additional users are being loaded
    var isLoadingMore: Bool { get }
    
    /// Callback triggered when state changes
    /// Used by view controllers to react to state transitions
    var onStateChanged: ((UsersListState) -> Void)? { get set }
    
    /// Initiates initial data loading when view appears
    func viewDidLoad()
    
    /// Refreshes the user list from the beginning
    func refreshUsers()
    
    /// Loads additional users for pagination
    func loadMoreUsers()
    
    /// Searches for users matching the given query
    /// - Parameter query: Search text to filter users
    func searchUsers(query: String)
    
    /// Cancels the current search and restores original list
    func cancelSearch()
}

/// Implementation of UsersListViewModelProtocol
/// Responsible for managing users list data and business logic
/// 
/// Following Single Responsibility Principle by focusing only on
/// users list data management and state transitions
final class UsersListViewModel: UsersListViewModelProtocol {
    
    // MARK: - Properties
    
    /// Data source for user information
    /// Following Dependency Inversion Principle by depending on abstraction
    private let repository: GitHubRepositoryProtocol
    
    /// Current state of the view model, initially set to loading
    /// Uses property wrapper to control access
    private(set) var state: UsersListState = .loading
    
    /// Flag indicating if additional users are being loaded
    private(set) var isLoadingMore = false
    
    /// Flag indicating if a search is currently active
    private(set) var isSearching = false
    
    /// Current users being displayed
    private var currentUsers: [User] = []
    
    /// Original users list before any search filtering
    private var originalUsers: [User] = []
    
    /// Callback for state changes
    /// Used to notify the view controller when data is loaded or errors occur
    var onStateChanged: ((UsersListState) -> Void)?
    
    // MARK: - Constants
    
    /// Number of users to fetch per page
    /// Default value aligned with GitHub API standard
    private let usersPerPage = 30
    
    // MARK: - Initialization
    
    /// Creates a new UsersListViewModel
    /// 
    /// - Parameter repository: Data provider for GitHub information, defaults to standard implementation
    init(repository: GitHubRepositoryProtocol = GitHubRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        fetchUsers(since: 0)
    }
    
    func refreshUsers() {
        currentUsers = []
        fetchUsers(since: 0)
    }
    
    func loadMoreUsers() {
        // Only allow loading more from loaded or loadedMore states
        guard !isLoadingMore else { return }
        
        // Check if we are in appropriate state for loading more
        switch state {
        case .loaded, .loadedMore: break // Continue loading
        default: return // Exit if not in appropriate state
        }
        
        guard let lastUserId = currentUsers.last?.id else { return }
        
        isLoadingMore = true
        updateState(.loadingMore)
        
        fetchUsers(since: lastUserId, isPaginating: true)
    }
    
    func searchUsers(query: String) {
        // Don't search if query is empty
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Save original users before starting search
        if !isSearching {
            // Only backup if not already searching
            switch state {
            case .loaded(let users), .loadedMore(let users):
                self.originalUsers = users
            default: break
            }
        }
        
        isSearching = true
        updateState(.loading)
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let searchResults = try await self.repository.searchUsers(query: query, perPage: self.usersPerPage)
                await MainActor.run {
                    self.isSearching = false
                    self.updateState(.loaded(searchResults))
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                    self.updateState(.error("error.failed.search".localized))
                }
            }
        }
    }
    
    func cancelSearch() {
        // Only restore if we were searching
        guard isSearching || !originalUsers.isEmpty else { return }
        
        isSearching = false
        currentUsers = originalUsers
        updateState(.loaded(originalUsers))
    }
    
    // MARK: - Private Methods
    
    private func fetchUsers(since userId: Int, isPaginating: Bool = false) {
        if !isPaginating {
            updateState(.loading)
        }
        
        Task { [weak self] in
            do {
                guard let self = self else { return }
                
                let newUsers = try await self.repository.fetchUsers(perPage: self.usersPerPage, since: userId)
                await MainActor.run {
                    self.isLoadingMore = false
                    
                    if isPaginating {
                        self.currentUsers.append(contentsOf: newUsers)
                        self.updateState(.loadedMore(self.currentUsers))
                    } else {
                        self.currentUsers = newUsers
                        self.updateState(.loaded(newUsers))
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isLoadingMore = false
                    self?.updateState(.error("error.failed.fetch.users".localized))
                }
            }
        }
    }
    
    private func updateState(_ newState: UsersListState) {
        state = newState
        onStateChanged?(newState)
    }
}
