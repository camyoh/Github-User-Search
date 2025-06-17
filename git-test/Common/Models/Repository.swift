import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let language: String?
    let starsCount: Int
    let description: String?
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case language
        case starsCount = "stargazers_count"
        case description
        case htmlUrl = "html_url"
    }
}
