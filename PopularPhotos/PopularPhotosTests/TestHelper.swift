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
