import Alamofire

protocol HTTPService {
    func request(urlRequest: URLRequestConvertible, jsonHandler: @escaping (DataResponse<Any>) -> Void)
}

class HTTPServiceImpl: HTTPService {
    
    func request(urlRequest: URLRequestConvertible, jsonHandler: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(urlRequest).responseJSON(completionHandler: jsonHandler)
    }
    
}
