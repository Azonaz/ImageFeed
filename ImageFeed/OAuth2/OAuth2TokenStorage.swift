import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    var token: String? {
        get {
            keychainWrapper.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else { return }
            keychainWrapper.set(newValue, forKey: Keys.token.rawValue)
        }
    }

    private let keychainWrapper = KeychainWrapper.standard

    private enum Keys: String {
        case token = "com.imagefeed.authkey"
    }

    func removeToken() {
        keychainWrapper.removeObject(forKey: Keys.token.rawValue)
    }
}
