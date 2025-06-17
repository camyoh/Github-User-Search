import Foundation
@testable import git_test

class MockGitHubRepository: GitHubRepositoryProtocol {
    // MARK: - Flags para seguimiento de llamadas
    
    var fetchUserDetailCalled = false
    var fetchUsersCalled = false
    var fetchRepositoriesCalled = false
    var searchUsersCalled = false
    
    // MARK: - Parámetros almacenados
    
    var lastSearchQuery: String?
    var lastSearchPerPage: Int?
    var lastFetchUsersPerPage: Int?
    var lastFetchUsersSince: Int?
    
    // MARK: - Resultados mock
    
    var userDetailToReturn: UserDetail?
    var usersToReturn: [User] = []
    var repositoriesToReturn: [Repository] = []
    var searchResultsToReturn: [User] = []
    
    // MARK: - Errores mock
    
    var shouldThrowError = false
    var errorToThrow: NetworkError = .invalidURL
    
    // MARK: - Implementación de protocolo
    
    func fetchUserDetail(username: String) async throws -> UserDetail {
        fetchUserDetailCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let userDetail = userDetailToReturn else {
            throw NetworkError.noData
        }
        
        return userDetail
    }
    
    func fetchUsers(perPage: Int, since: Int = 0) async throws -> [User] {
        fetchUsersCalled = true
        lastFetchUsersPerPage = perPage
        lastFetchUsersSince = since
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return usersToReturn
    }
    
    func fetchRepositories(username: String, perPage: Int) async throws -> [Repository] {
        fetchRepositoriesCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return repositoriesToReturn
    }
    
    func searchUsers(query: String, perPage: Int) async throws -> [User] {
        searchUsersCalled = true
        lastSearchQuery = query
        lastSearchPerPage = perPage
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return searchResultsToReturn
    }
}
