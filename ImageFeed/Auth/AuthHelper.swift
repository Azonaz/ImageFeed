import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL) -> String?
    func authToken(by code: String) -> URLRequest
}

class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "oauth/authorize",
            httpMethod: .get,
            baseURL: unsplashAuthorizeURL,
            queryItems: [
                URLQueryItem(name: "client_id", value: accessKey),
                URLQueryItem(name: "redirect_uri", value: redirectURI),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "scope", value: accessScope)
            ]
        )
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" } )
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    func authToken(by code: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "oauth/token",
            httpMethod: .post,
            baseURL: unsplashAuthorizeURL,
            queryItems: [
                URLQueryItem(name: "client_id", value: accessKey),
                URLQueryItem(name: "client_secret", value: secretKey),
                URLQueryItem(name: "redirect_uri", value: redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
        )
    }
} 
