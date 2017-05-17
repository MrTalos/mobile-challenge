import Foundation
import Alamofire

enum APIGeneral {
    static let baseUrl = "https://api.500px.com/v1"
    
    static let consumerKeyKey = "consumer_key"
    static let consumerKey = "RNyMvTrg9wCF3263XiUhH51FzKG2FOPltpuw5j1U"
    
    static func attachConsumerKey(_ params: Parameters?) -> Parameters {
        if var params = params {
            params[APIGeneral.consumerKeyKey] = APIGeneral.consumerKey
            return params
        } else {
            return [APIGeneral.consumerKeyKey: APIGeneral.consumerKey]
        }
    }
}
