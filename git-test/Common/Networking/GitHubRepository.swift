import Foundation

/// Protocol defining the contract for GitHub API data operations.
/// Abstracts the implementation details allowing for easier testing and dependency injection.
protocol GitHubRepositoryProtocol {
    /// Fetches detailed information about a specific GitHub user
    /// - Parameter username: The GitHub username to fetch details for
    /// - Returns: A UserDetail object containing the user's profile information
    /// - Throws: NetworkError if the request fails
    func fetchUserDetail(username: String) async throws -> UserDetail
    
    /// Fetches a list of GitHub users with pagination support
    /// - Parameters:
    ///   - perPage: Number of users to return per page
    ///   - since: User ID to start listing from
    /// - Returns: An array of User objects
    /// - Throws: NetworkError if the request fails
    func fetchUsers(perPage: Int, since: Int) async throws -> [User]
    
    /// Fetches repositories belonging to a specific GitHub user
    /// - Parameters:
    ///   - username: The GitHub username whose repositories to fetch
    ///   - perPage: Number of repositories to return
    /// - Returns: An array of Repository objects
    /// - Throws: NetworkError if the request fails
    func fetchRepositories(username: String, perPage: Int) async throws -> [Repository]
    
    /// Searches for GitHub users matching a query string
    /// - Parameters:
    ///   - query: The search query text
    ///   - perPage: Number of results to return per page
    /// - Returns: An array of matching User objects
    /// - Throws: NetworkError if the request fails
    func searchUsers(query: String, perPage: Int) async throws -> [User]
}

/// Concrete implementation of GitHubRepositoryProtocol that interacts with the GitHub API
/// Uses NetworkService to perform the actual network requests
final class GitHubRepository: GitHubRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// Fetches detailed information for a specific GitHub user
    /// - Parameter username: The username to fetch details for
    /// - Returns: A UserDetail object with the user's information
    /// - Throws: NetworkError.invalidURL if the URL cannot be constructed
    ///           Other NetworkErrors as propagated from the network service
    func fetchUserDetail(username: String) async throws -> UserDetail {
        guard let url = GitHubEndpoint.userDetail(username: username).url else {
            throw NetworkError.invalidURL
        }
        
        return try await networkService.fetch(url: url)
    }
    
    /// Fetches a paginated list of GitHub users
    /// - Parameters:
    ///   - perPage: Number of users per page (default GitHub API: 30)
    ///   - since: User ID to start fetching from (0 for first page)
    /// - Returns: An array of User objects
    /// - Throws: NetworkError.invalidURL if the URL cannot be constructed
    ///           Other NetworkErrors as propagated from the network service
    func fetchUsers(perPage: Int, since: Int = 0) async throws -> [User] {
        guard let url = GitHubEndpoint.usersList(perPage: perPage, since: since).url else {
            throw NetworkError.invalidURL
        }
        
        return try await networkService.fetch(url: url)
    }
    
    /// Fetches repositories for a specific GitHub user
    /// - Parameters:
    ///   - username: The owner of the repositories
    ///   - perPage: Maximum number of repositories to return
    /// - Returns: An array of Repository objects
    /// - Throws: NetworkError.invalidURL if the URL cannot be constructed
    ///           Other NetworkErrors as propagated from the network service
    func fetchRepositories(username: String, perPage: Int) async throws -> [Repository] {
        guard let url = GitHubEndpoint.userRepositories(username: username, perPage: perPage).url else {
            throw NetworkError.invalidURL
        }
        
        return try await networkService.fetch(url: url)
    }
    
    /// Searches for GitHub users matching the specified query
    /// - Parameters:
    ///   - query: The search term to look for
    ///   - perPage: Maximum number of results to return
    /// - Returns: An array of matching User objects
    /// - Throws: NetworkError.invalidURL if the URL cannot be constructed
    ///           Other NetworkErrors as propagated from the network service
    func searchUsers(query: String, perPage: Int) async throws -> [User] {
        guard let url = GitHubEndpoint.searchUsers(query: query, perPage: perPage).url else {
            throw NetworkError.invalidURL
        }
        
        let searchResponse: UserSearchResponse = try await networkService.fetch(url: url)
        return searchResponse.items
    }
}
