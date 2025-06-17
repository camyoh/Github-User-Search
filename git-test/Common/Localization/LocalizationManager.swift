import Foundation

protocol LocalizationProtocol {
    func localizedString(for key: String, comment: String) -> String
}

final class LocalizationManager: LocalizationProtocol {
    static let shared = LocalizationManager()
    
    private init() {}
    
    func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
}

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}
