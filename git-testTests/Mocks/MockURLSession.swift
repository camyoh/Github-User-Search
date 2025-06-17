import Foundation
@testable import git_test

// Mock basado en protocolo en lugar de heredar
class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    // Constructor simple que no trae advertencias
    init() {}
    
    func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        guard let data = data, let response = response else {
            throw NetworkError.noData
        }
        
        return (data, response)
    }
}
