import cm_sdk_ios_v3
import UIKit

enum BridgeConsentStatus: Int {
    case granted = 0
    case denied = 1
    case choiceDoesntExist = 2
}

enum BridgeUserChoiceStatus: Int {
    case choiceExists = 0
    case requiresUpdate = 1
    case choiceDoesntExist = 2
}

enum BridgePosition {
    case fullScreen
    case halfScreenTop
    case halfScreenBottom
    case custom(CGRect, String)

    static func create(from string: String?, args: [String: Any]) -> BridgePosition {
        switch string {
        case "halfScreenTop":
            return .halfScreenTop
        case "halfScreenBottom":
            return .halfScreenBottom
        case "custom":
            let rectInfo = args["customPosition"] as? [String: Any]
            let width = rectInfo?["width"] as? CGFloat ?? 0
            let height = rectInfo?["height"] as? CGFloat ?? 0
            let gravity = rectInfo?["gravity"] as? String ?? "center"
            return .custom(CGRect(x: 0, y: 0, width: width, height: height), gravity)
        default:
            return .fullScreen
        }
    }

    func toNativePosition() -> ConsentLayerUIConfig.CMPPosition {
        let screen = UIScreen.main.bounds
        switch self {
        case .fullScreen:
            return .fullScreen
        case .halfScreenTop:
            let height = screen.height / 2
            let rect = CGRect(x: 0, y: 0, width: screen.width, height: height)
            return .custom(rect: rect)
        case .halfScreenBottom:
            let height = screen.height / 2
            let rect = CGRect(x: 0, y: screen.height - height, width: screen.width, height: height)
            return .custom(rect: rect)
        case .custom(let rect, let gravity):
            var finalRect = rect
            if finalRect.height == 0 { finalRect.size.height = screen.height / 2 }
            if finalRect.width == 0 { finalRect.size.width = screen.width }
            
            finalRect.origin.x = max(0, (screen.width - finalRect.width) / 2)
            
            switch gravity {
            case "top":
                finalRect.origin.y = 0
            case "bottom":
                finalRect.origin.y = max(0, screen.height - finalRect.height)
            default:
                finalRect.origin.y = max(0, (screen.height - finalRect.height) / 2)
            }
            return .custom(rect: finalRect)
        }
    }
}

enum BridgeBackgroundStyle {
    case dimmed(UIColor, CGFloat)
    case blur(UIBlurEffect.Style)
    case color(UIColor)
    case none

    static func create(from args: [String: Any]) -> BridgeBackgroundStyle {
        let styleString = args["backgroundStyle"] as? String ?? "dimmed"

        switch styleString {
        case "color":
            if let colorValue = args["backgroundColor"] as? Int {
                return .color(UIColor(rgb: colorValue))
            }
            return .color(.black)
        case "none":
            return .none
        default:
            let colorValue = args["backgroundColor"] as? Int ?? 0x000000
            let opacity = args["backgroundOpacity"] as? CGFloat ?? 0.5
            return .dimmed(UIColor(rgb: colorValue), opacity)
        }
    }

    func toNativeStyle() -> ConsentLayerUIConfig.CMPBackgroundStyle {
        switch self {
        case .dimmed(let color, let opacity):
            return .dimmed(color: color, alpha: opacity)
        case .blur:
            // Blur not supported via Flutter bridge; fallback to dimmed default
            return .dimmed(color: .black, alpha: 0.5)
        case .color(let color):
            return .color(color)
        case .none:
            return .none
        }
    }
}

class CMPArgumentParser {
    static func parseConsentLayerUIConfig(from args: [String: Any]) -> ConsentLayerUIConfig {
        let position = BridgePosition.create(from: args["position"] as? String, args: args)
        let backgroundStyle = BridgeBackgroundStyle.create(from: args)

        let cornerRadius = args["cornerRadius"] as? CGFloat ?? 0
        let respectsSafeArea = args["respectsSafeArea"] as? Bool ?? true
        let allowsOrientationChanges = args["allowsOrientationChanges"] as? Bool ?? true
        let darkMode = args["darkMode"] as? Bool ?? false
        let config = ConsentLayerUIConfig(
            objcPosition: position.toNativePosition(),
            objcBackgroundStyle: backgroundStyle.toNativeStyle(),
            cornerRadius: cornerRadius,
            respectsSafeArea: respectsSafeArea,
            allowsOrientationChanges: allowsOrientationChanges,
            darkMode: darkMode
        )

        return config
    }

    static func parseUrlConfig(from args: [String: Any]) -> UrlConfig {
        let id = args["id"] as! String
        let domain = args["domain"] as! String
        let language = args["language"] as! String
        let appName = args["appName"] as! String
        let jsonConfig = args["jsonConfig"] as? String
        let noHash = args["noHash"] as? Bool ?? false
        let webViewConnectionTimeoutMillis = (args["webViewConnectionTimeoutMillis"] as? NSNumber)?.intValue ?? 3000

        return UrlConfig(id: id, domain: domain, language: language, appName: appName, jsonConfig: jsonConfig, noHash: noHash, webViewConnectionTimeoutMillis: webViewConnectionTimeoutMillis)
    }
}
