import Foundation
@testable import git_test

class MockNetworkService: NetworkServiceProtocol {
    
    // MARK: - Tracking Properties
    
    var fetchCalled = false
    var lastFetchURL: URL?
    
    // MARK: - Mock Response Configuration
    
    var shouldThrowError = false
    var errorToThrow: NetworkError = .noData
    
    var userDetailToReturn: UserDetail?
    var usersToReturn: [User]?
    var repositoriesToReturn: [Repository]?
    var searchResponseToReturn: UserSearchResponse?
    
    // MARK: - NetworkServiceProtocol Implementation
    
    func fetch<T: Decodable>(url: URL) async throws -> T {
        fetchCalled = true
        lastFetchURL = url
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Determine which type of response to return based on the requested type
        if T.self == UserDetail.self, let userDetail = userDetailToReturn as? T {
            return userDetail
        }
        
        if T.self == [User].self, let users = usersToReturn as? T {
            return users
        }
        
        if T.self == [Repository].self, let repositories = repositoriesToReturn as? T {
            return repositories
        }
        
        if T.self == UserSearchResponse.self, let searchResponse = searchResponseToReturn as? T {
            return searchResponse
        }
        
        // If we can't provide a valid response, throw an error
        throw NetworkError.noData
    }
}
