//
//  Router.swift
//  Verifone2CO
//

import Foundation

public typealias NetworkResultCompletion<T: Decodable> = (T?, _ error: Error?) -> Void

protocol NetworkRouter: AnyObject {
    func request<T: Decodable>(_ route: ApiEndPoint, completion: @escaping NetworkResultCompletion<T>)
    func validateResponse(data: Any?, urlResponse: HTTPURLResponse, error: Error?) -> Result<Any, Error>
    func cancel()
}

final class Router: NetworkRouter {
    private(set) var task: URLSessionTask?
    private(set) var baseURL: String

    required init(baseURL: String) {
        self.baseURL = baseURL
    }

    func request<T: Decodable>(_ route: ApiEndPoint, completion: @escaping NetworkResultCompletion<T>) {
        let session = URLSession.shared
        do {
            guard let urlRequest = route.urlRequest(with: baseURL) else {
                throw Verifone2CoError.badRequest("Invalid URL for: \(route)")
            }
            Logger.request(request: urlRequest)
            task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
                Logger.response(data: data, error: error)
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                if let response = response as? HTTPURLResponse {
                    let decoder = JSONDecoder()
                    let result = self.validateResponse(data: data, urlResponse: response, error: error)
                    switch result {
                    case .success:
                        do {
                            guard let data = data else {
                                completion(nil, Verifone2CoError.noData)
                                return
                            }
                            let decodableData: T = try decoder.decode(T.self, from: data)
                            completion(decodableData, error)
                        } catch let exception {
                            completion(nil, Verifone2CoError.invalidResponse(exception.localizedDescription))
                        }
                    case .failure(let networkFailureError):
                        completion(nil, Verifone2CoError.invalidResponse(networkFailureError.localizedDescription))
                    }
                }
            })
        } catch {
            completion(nil, error)
        }
        self.task?.resume()
    }

    internal func validateResponse(data: Any?, urlResponse: HTTPURLResponse, error: Error?) -> Result<Any, Error> {
        let decoder = JSONDecoder()
        var errorStr: String?
        switch urlResponse.statusCode {
        case 200...299:
            if let data = data {
                return .success(data)
            } else {
                return .failure(Verifone2CoError.noData)
            }
        case 400...499:
            if let data = data as? Data {
                let decodableData: ErrorTokenGenerate? = try? decoder.decode(ErrorTokenGenerate.self, from: data)
                if let errorObj = decodableData {
                    errorStr = "\(errorObj.code ?? "") message: \(errorObj.detail ?? "")"
                }
            }
            return .failure(Verifone2CoError.badRequest(errorStr ?? error?.localizedDescription))
        case 500...599:
            return .failure(Verifone2CoError.serverError(error?.localizedDescription))
        default:
            return .failure(Verifone2CoError.unknown)
        }
    }

    func cancel() {
        self.task?.cancel()
    }
}
