@testable import PopularPhotos

import Alamofire

internal enum MockError: Error {
    case noInternet
    case serverError
}

internal class MockHTTPService: HTTPService {
    
    var mock: [String: DataResponse<Any>?]!
    
    var validateRequest: ((URLRequestConvertible) -> ())?
    
    func createJsonResponse(jsonString: String?) -> DataResponse<Any> {
        if let jsonString = jsonString, let parsed = parseJsonString(str: jsonString) {
            return createResponse(result: Result<Any>.success(parsed))
        } else {
            return createErrorResponse(error: .serverError)
        }
    }
    
    func createErrorResponse(error: MockError) -> DataResponse<Any> {
        return createResponse(result: Result<Any>.failure(error))
    }
    
    func createResponse<T>(result: Result<T>) -> DataResponse<T> {
        return DataResponse(request: nil, response: nil, data: nil, result: result)
    }
    
    func request(urlRequest: URLRequestConvertible, jsonHandler: @escaping (DataResponse<Any>) -> Void) {
        do {
            validateRequest?(urlRequest)
            if let url = try urlRequest.asURLRequest().url?.absoluteString,
                let key = url.components(separatedBy: "?").first,
                let response = mock[key] as? DataResponse<Any> {
                jsonHandler(response)
                return
            }
        } catch _ {
        }
        jsonHandler(createResponse(result: Result<Any>.failure(MockError.noInternet)))
    }
    
}
