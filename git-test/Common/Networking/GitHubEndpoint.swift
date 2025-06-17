import Foundation

enum GitHubEndpoint {
    case userDetail(username: String)
    case usersList(perPage: Int, since: Int)
    case userRepositories(username: String, perPage: Int)
    case searchUsers(query: String, perPage: Int)
    
    private var baseURL: String {
        return "https://api.github.com"
    }
    
    var url: URL? {
        switch self {
        case .userDetail(let username):
            return URL(string: "\(baseURL)/users/\(username)")
        case .usersList(let perPage, let since):
            return URL(string: "\(baseURL)/users?per_page=\(perPage)&since=\(since)")
        case .userRepositories(let username, let perPage):
            return URL(string: "\(baseURL)/users/\(username)/repos?type=owner&per_page=\(perPage)")
        case .searchUsers(let query, let perPage):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return URL(string: "\(baseURL)/search/users?q=\(encodedQuery)&per_page=\(perPage)")
        }
    }
}
