import Foundation
import Alamofire

protocol PhotoService {
    func getPhotos(feature: String, page: Int, exclude: [String], onComplete: @escaping ([Photo]) -> ())
}

class PhotoServiceImpl: PhotoService {
    
    static private let TAG = "PhotoServiceImpl"
    
    static let instance = PhotoServiceImpl()
    
    private let service: HTTPService
    
    init(httpService: HTTPService = HTTPServiceImpl()) {
        service = httpService
    }
    
    func getPhotos(feature: String, page: Int, exclude: [String], onComplete: @escaping ([Photo]) -> ()) {
        let request = PhotosRouter.photos(feature: feature, page: page, rpp: 25, exclude: exclude, imageSizes: [4])
        service.request(urlRequest: request) { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let value):
                debugPrint(PhotoServiceImpl.TAG, value)
                if let value = value as? [[String: Any]] {
                    let photos = self.parsePhotos(photosJson: value)
                    onComplete(photos)
                }
            case .failure(let error):
                debugPrint(PhotoServiceImpl.TAG, error)
                onComplete([])
            }
        }
    }
    
    func parsePhotos(photosJson: [[String: Any]]) -> [Photo] {
        var parsedPhotos: [Photo] = []
        for photoJson in photosJson {
            guard let id = photoJson["id"] as? Int64,
                    let name = photoJson["name"] as? String,
                    let desc = photoJson["description"] as? String,
                    let imageUrl = photoJson["image_url"] as? String,
                    let width = photoJson["width"] as? Int,
                    let height = photoJson["height"] as? Int else {
                continue
            }
            let photo = Photo(id: id, name: name, desc: desc, imageUrl: imageUrl, width: width, height: height)
            parsedPhotos.append(photo)
        }
        return parsedPhotos
    }
    
}

private enum PhotosRouter: URLRequestConvertible {
    
    case photos(feature: String, page: Int?, rpp: Int?, exclude: [String]?, imageSizes: [Int]?)
    
    var method: HTTPMethod {
        switch self {
        case .photos:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .photos:
            return "photos"
        }
    }
    
    var encoding: URLEncoding {
        switch self {
        case .photos:
            return URLEncoding.default
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .photos(let feature, let page, let rpp, let exclude, let imageSizes):
            var params: [String: Any] = ["feature": feature]
            if let page = page {
                params["page"] = page
            }
            if let rpp = rpp {
                params["rpp"] = rpp
            }
            if let exclude = exclude {
                params["exclude"] = exclude
            }
            if let imageSizes = imageSizes {
                params["imageSizes"] = imageSizes
            }
            return params
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try APIGeneral.baseUrl.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request = try encoding.encode(request, with: APIGeneral.attachConsumerKey(parameters))
        return request
    }
    
}
