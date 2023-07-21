import UIKit

let accessKey = "alcNdnRc_vh6Thf4eX7mgARtLhDW0MWnKShXGq1jtmA"
let secretKey = "asGco24eBPwAgixTdTpnonTq-pj83hvEiD8M4jWVECw"
let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
let accessScope = "public+read_user+write_likes"
let defaultBaseURL = URL(string: "https://api.unsplash.com/")!
let unsplashAuthorizeURL = URL(string: "https://unsplash.com/")!
let photosPerPage = 10

struct AuthConfiguration {
    let accessKeys: String
    let secretKeys: String
    let redirectURIS: String
    let accessScopes: String
    let baseURL: URL
    let authURL: URL
    let photoPerPage: Int
    
    init(accessKeys: String,
         secretKeys: String,
         redirectURIS: String,
         accessScopes: String,
         authURL: URL,
         baseURL: URL,
         photoPerPage: Int) {
        self.accessKeys = accessKeys
        self.secretKeys = secretKeys
        self.redirectURIS = redirectURIS
        self.accessScopes = accessScopes
        self.baseURL = baseURL
        self.authURL = authURL
        self.photoPerPage = photoPerPage
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKeys: accessKey,
                                 secretKeys: secretKey,
                                 redirectURIS: redirectURI,
                                 accessScopes: accessScope,
                                 authURL: unsplashAuthorizeURL,
                                 baseURL: defaultBaseURL,
                                 photoPerPage: photosPerPage)
    }
}
