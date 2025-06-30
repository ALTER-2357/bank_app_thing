import Foundation

class PanManager {
    static var pan: String? {
        get {
            UserDefaults.standard.object(forKey: "pan") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "pan")
        }
    }
}
