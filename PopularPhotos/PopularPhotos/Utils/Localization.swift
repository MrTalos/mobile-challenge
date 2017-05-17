import Foundation

extension String {
    func i18n() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
