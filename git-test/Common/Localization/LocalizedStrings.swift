import Foundation

// MARK: - UserDetail Localized Strings

extension String {
    static var followersTitle: String {
        return NSLocalizedString("followers.title", comment: "Title for followers count")
    }
    
    static var followingTitle: String {
        return NSLocalizedString("following.title", comment: "Title for following count")
    }
    
    static var retryButtonTitle: String {
        return NSLocalizedString("button.retry", comment: "Title for retry button")
    }
    
    static var failedToFetchUserInfo: String {
        return NSLocalizedString("error.failed.user.info", comment: "Error message shown when user information could not be fetched")
    }
}
