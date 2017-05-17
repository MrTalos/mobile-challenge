import Foundation
import XCTest

func parseJsonString(str: String) -> [String: Any]? {
    do {
        if let data = str.data(using: .utf8), let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return dict
        }
    } catch _ {
    }
    return nil
}

func parseJsonObject(dict: [String: Any]) -> String? {
    do {
        let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        if let ret = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
            return ret
        }
    } catch _ {
    }
    return nil
}

func XCTExpectEqual<T: Equatable>(actual: T?, expected: T?) {
    XCTAssert(actual == expected, "Actual: \(String(describing: actual))")
}

extension XCTestCase {
    func getData(fromFile fileName: String, _ type: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: fileName, ofType: type) {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: path))
            } catch _ {}
        }
        return nil
    }
    
    func getString(fromFile fileName: String, _ type: String) -> String? {
        guard let data = getData(fromFile: fileName, type) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}
