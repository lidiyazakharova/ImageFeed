import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        } }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void ){
            let request = authTokenRequest(code: code)
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    print ("YAHOO!!!", authToken)
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                } }
            task.resume()
        }
}
extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        ) }
//    private struct OAuthTokenResponseBody: Decodable {
//        let accessToken: String
//        let tokenType: String
//        let scope: String
//        let createdAt: Int
//        enum CodingKeys: String, CodingKey {
//            case accessToken = "access_token"
//            case tokenType = "token_type"
//            case scope
//            case createdAt = "created_at"
//        }
//    }
    
}
// MARK: - HTTP Request
// Если в вашем в проекте уже объявлена переменная `DefaultBaseURL` (с тем же значением),
// то строчку ниже можно удалить.
//fileprivate let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        
        //Памятка по сетевым запросам 10
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    } }
// MARK: - Network Connection
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    } }


//final class OAuth2Service {
//    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void){
//        
//        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
//        urlComponents?.queryItems = [URLQueryItem(name: "client_id", value: AccessKey),
//                                     URLQueryItem(name: "client_secret", value: SecretKey),
//                                     URLQueryItem(name: "redirect_uri", value: RedirectURI),
//                                     URLQueryItem(name: "code", value: code),
//                                     URLQueryItem(name: "grant_type", value: "authorization_code")]
//        
//        if let url = urlComponents?.url {
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            
//            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
//                //
//                completion(.success(""))//TO DO
//                completion(.failure(error))
//            })
//        }
//    }
//}

//        func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
//            networkClient.fetch(url: mostPopularMoviesUrl) { result in
//                switch result {
//                case .success(let data):
//                    do {
//                        let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
//                        handler(.success(mostPopularMovies))
//                    } catch {
//                        handler(.failure(error))
//                    }
//                case .failure(let error):
//                    handler(.failure(error))
//                }
//            }


//________ создание запроса
//// Создание URL с использованием [стандартного конструктора]
//let url = URL(string: "https://api.unsplash.com/me")!
//// Создание URL с использованием [URLComponents]
//var urlComponents = URLComponents()
//urlComponents.scheme = "https"
//urlComponents.host = "api.unsplash.com"
//urlComponents.path = "/me"
//let url = urlComponents.url!
//// Создание HTTP-запроса [с заданным URL]
//var request = URLRequest(url: url)
//// Изменение [HTTP-глагола]
//request.httpMethod = "PUT"
//// Установка [HTTP-заголовка]
//let authToken = OAuth2TokenStorage().token
//request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//// Передача объекта через [тело запроса]
//struct User: Encodable {
//    let username: String
//}
//request.httpBody = try JSONEncoder().encode(User(username: "Test"))


//========обработка запроса
//let task = session.dataTask(with: request) { data, response, error in
//  // Преобразование в [HTTPURLResponse] для получения данных
//  // уровня протокола HTTP
//  if let data = data,
//      let response = response,
//      let httpResponse = response as? HTTPURLResponse
//  {
//      let statusCode = httpResponse.statusCode
//      if 200 ..< 300 ~= statusCode {
//        // Обработка успешного ответа
//      } else {
//        // Обработка ошибки уровня HTTP ([HTTP 400/401/404], [HTTP 500], и тд])
//      }
//  } else if let error = error {
//      // Обработка [ошибки уровня URLSession] (прерванное соединение, таймаут и т.д.)
//  } else {
//      // Обработка (теоретической) ошибки нарушения контракта URLSession
//      // Контракт URLSession описан [в документации]:
//      // > If the request completes successfully, the data parameter of
//      // > the completion handler block contains the resource data, and
//      // > the error parameter is nil. If the request fails, the data
//      // > parameter is nil and the error parameter contain information
//      // > about the failure. If a response from the server is received,
//      // > regardless of whether the request completes successfully or fails,
//      // > the response parameter contains that information.
//      // Обратите внимание: на практике этот тип ошибок маловероятен, но возможен в случае
//      // наличия багов в (недоступной нам) реализации класса URLSession.
//      // Данный класс ошибок нельзя исправить иначе, чем
//      // получив системный апдейт от Apple.
//      // К счастью, в реальности такие ошибки редки и не критичны.
//  }
//}
//task.resume()


//=====вспомогательный метод
//fileprivate let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
//extension URLRequest {
//    static func makeHTTPRequest(
//        path: String,
//        httpMethod: String,
//        baseURL: URL = DefaultBaseURL
//    ) -> URLRequest {
//        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
//        request.httpMethod = httpMethod
//        return request
//} }

//var selfProfileRequest: URLRequest {
//    URLRequest.makeHTTPRequest(path: "/me")
//}
//func profileImageURLRequest(username: String) -> URLRequest {
//    URLRequest.makeHTTPRequest(path: "/users/\(username)")
//}
//func photosRequest(page: Int, perPage: Int) -> URLRequest {
//    URLRequest.makeHTTPRequest(path: "/photos?"
//      + "page=\(page)"
//      + "&&per_page=\(perPage)"
//    )
//}
//func likeRequest(photoId: String) -> URLRequest {
//    URLRequest.makeHTTPRequest(
//      path: "/photos/\(photoId)/like",
//      httpMethod: "POST"
//    )
//}
//func unlikeRequest(photoId: String) -> URLRequest {
//    URLRequest.makeHTTPRequest(
//      path: "/photos/\(photoId)/like",
//      httpMethod: "DELETE"
//    )
//}
//func authTokenRequest(code: String) -> URLRequest {
//    URLRequest.makeHTTPRequest(
//        path: "/oauth/token"
//        + "?client_id=\(AccessKey)"
//        + "&&client_secret=\(SecretKey)"
//        + "&&redirect_uri=\(RedirectURI)"
//        + "&&code=\(code)"
//        + "&&grant_type=authorization_code",
//        httpMethod: "POST",
//        baseURL: URL(string: "https://unsplash.com")!
//) }
