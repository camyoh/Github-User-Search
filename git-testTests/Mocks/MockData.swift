import Foundation
@testable import git_test

enum MockData {
    static func createMockUsers(count: Int = 3) -> [User] {
        var users: [User] = []
        for i in 1...count {
            let user = User(id: i, login: "user\(i)", avatarUrl: "https://example.com/avatar\(i).png")
            users.append(user)
        }
        return users
    }
    
    static func createMockSearchResults(count: Int = 3, prefix: String = "search") -> [User] {
        var users: [User] = []
        for i in 1...count {
            let user = User(id: i + 100, login: "\(prefix)User\(i)", avatarUrl: "https://example.com/search\(i).png")
            users.append(user)
        }
        return users
    }
}
