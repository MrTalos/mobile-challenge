@testable import PopularPhotos

import Alamofire

internal enum MockError: Error {
    case noInternet
    case serverError
}

internal class MockHTTPService: HTTPService {
    
    var mock: [String: DataResponse<Any>]!
    
    func createJsonResponse(jsonString: String) -> DataResponse<Any> {
        if let parsed = parseJsonString(str: jsonString) {
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
            if let key = try urlRequest.asURLRequest().url?.absoluteString, let response = mock[key] {
                jsonHandler(response)
                return
            }
        } catch _ {
        }
        jsonHandler(createResponse(result: Result<Any>.failure(MockError.noInternet)))
    }
    
}
