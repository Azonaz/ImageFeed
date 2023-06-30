import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let keychainWrapper = KeychainWrapper.standard

    private enum Keys: String {
        case token = "com.imagefeed.authkey"
    }

    var token: String? {
        get {
            keychainWrapper.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else { return }
            keychainWrapper.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
