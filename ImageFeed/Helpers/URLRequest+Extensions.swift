import UIKit

extension URLRequest {

    static func makeHTTPRequest(path: String,
                                httpMethod: HTTPMethod,
                                baseURL: URL = defaultBaseURL,
                                queryItems: [URLQueryItem] = [],
                                headers: [(header: String, value: String)] = []) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: path, relativeTo: baseURL)!, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = httpMethod.rawValue
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

enum URLRequests {
    static func profile(token: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "me",
            httpMethod: .get,
            headers: [("Authorization", "Bearer \(token)")]
        )
    }

    static func profileImage(token: String, userName: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "users/\(userName)",
            httpMethod: .get,
            headers: [("Authorization", "Bearer \(token)")]
        )
    }

    static func photos(page: Int, perPage: Int, token: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "photos",
            httpMethod: .get,
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ],
            headers: [("Authorization", "Bearer \(token)")]
        )
    }

    static func likes(photoID: String, method: HTTPMethod, token: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "photos/\(photoID)/like",
            httpMethod: method,
            headers: [("Authorization", "Bearer \(token)")])
    }
}
