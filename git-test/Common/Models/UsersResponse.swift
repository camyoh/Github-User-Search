import Foundation

// Protocol for domain models that can be created from external data
protocol DomainModel {
    associatedtype Input
    init(from input: Input) throws
}

// Domain model for User entity
struct UserEntity {
    let id: Int
    let username: String
    let avatarUrl: URL?
}

// Extension to convert API User to Domain UserEntity
extension UserEntity: DomainModel {
    typealias Input = User
    
    init(from input: User) throws {
        self.id = input.id
        self.username = input.login
        self.avatarUrl = URL(string: input.avatarUrl)
    }
}
