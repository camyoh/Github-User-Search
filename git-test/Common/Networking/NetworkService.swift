import Foundation

/// Protocol to abstract URLSession functionality for better testability
/// Enables mocking of network responses in unit tests
protocol URLSessionProtocol {
    /// Retrieves the contents of a URL based on the specified URL request object
    /// - Parameters:
    ///   - url: The URL to retrieve data from
    ///   - delegate: Task-specific delegate for handling events during the transfer
    /// - Returns: Tuple containing data and response
    /// - Throws: Error if the request fails for any reason
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

/// Makes URLSession conform to URLSessionProtocol
/// This allows the real URLSession to be used without modification
extension URLSession: URLSessionProtocol {}

/// Protocol defining core network functionality for the application
/// Provides a clean abstraction for making HTTP requests and handling responses
protocol NetworkServiceProtocol {
    /// Fetches data from a specified URL and decodes it to the requested type
    /// - Parameter url: The URL to fetch data from
    /// - Returns: Decoded object of type T
    /// - Throws: NetworkError if request fails or response cannot be decoded
    func fetch<T: Decodable>(url: URL) async throws -> T
}

/// Concrete implementation of NetworkServiceProtocol
/// Handles API calls, response validation, and JSON decoding
final class NetworkService: NetworkServiceProtocol {
    /// URLSession instance used for making network requests
    private let session: URLSessionProtocol
    
    /// Creates a new NetworkService instance
    /// - Parameter session: The URLSession to use for network requests (defaults to shared session)
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// Fetches and decodes data from a specified URL
    /// - Parameter url: The URL to fetch data from
    /// - Returns: Decoded object of type T
    /// - Throws: 
    ///   - NetworkError.noData if response is invalid
    ///   - NetworkError.serverError if HTTP status code is not 2xx
    ///   - NetworkError.decodingError if JSON cannot be decoded to type T
    func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url, delegate: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
