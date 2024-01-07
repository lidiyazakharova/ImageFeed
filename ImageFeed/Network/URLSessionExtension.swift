import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T,Error>) -> Void) -> URLSessionTask {
            let fulfillCompletionOnMainThread: (Result<T, Error>) -> Void = { result in DispatchQueue.main.async {
                completion(result)
            }
        }
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(T.self, from: data)
                            fulfillCompletionOnMainThread(.success(result))
                        } catch {
                            fulfillCompletionOnMainThread(.failure(NetworkError.decodingError(error)))
                        }
                    } else {
                        fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
                }
            })
            task.resume()
            return task
        }
}

//extension URLSession {
//    func data(for request: URLRequest,completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
//        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                completion(result)
//            }
//        }
//        let task = dataTask(with: request, completionHandler: { data, response, error in
//            if let data = data,
//               let response = response,
//               let statusCode = (response as? HTTPURLResponse)?.statusCode
//            {
//                if 200 ..< 300 ~= statusCode {
//                    fulfillCompletionOnMainThread(.success(data))
//                } else {
//                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
//                }
//            } else if let error = error {
//                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
//            }
//        })
//        task.resume()
//        return task
//    }
//}
