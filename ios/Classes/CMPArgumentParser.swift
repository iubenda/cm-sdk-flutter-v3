import cm_sdk_ios_v3
import UIKit

// BridgeTypes.swift
// Bridge enum for consent status
enum BridgeConsentStatus: Int {
    case granted = 0
    case denied = 1
    case choiceDoesntExist = 2
}

// Bridge enum for user choice status
enum BridgeUserChoiceStatus: Int {
    case choiceExists = 0
    case requiresUpdate = 1
    case choiceDoesntExist = 2
}

// Bridge struct for position configuration
enum BridgePosition {
    case fullScreen
    case halfScreenTop
    case halfScreenBottom
    case custom(CGRect)

    // Static factory method to create from string
    static func create(from string: String?) -> BridgePosition {
        guard let positionString = string else { return .fullScreen }

        switch positionString {
        case "halfScreenTop":
            return .halfScreenTop
        case "halfScreenBottom":
            return .halfScreenBottom
        case "custom":
            return .custom(CGRect.zero) // Default rect, should be updated later
        default:
            return .fullScreen
        }
    }

    func toNativePosition() -> ConsentLayerUIConfig.CMPPosition {
        switch self {
        case .fullScreen:
            return .fullScreen
        case .custom(let rect):
            return .custom(rect: rect)
        case .halfScreenTop, .halfScreenBottom:
            // Since these aren't supported in native SDK, fallback to fullScreen
            return .fullScreen
        }
    }
}

// Bridge struct for background style configuration
enum BridgeBackgroundStyle {
    case dimmed(UIColor, CGFloat)
    case blur(UIBlurEffect.Style)
    case color(UIColor)
    case none

    // Static factory method to create from arguments dictionary
    static func create(from args: [String: Any]) -> BridgeBackgroundStyle {
        let styleString = args["backgroundStyle"] as? String ?? "dimmed"

        switch styleString {
        case "blur":
            return .blur(.dark)
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
        case .blur(let style):
            return .blur(style: style)
        case .color(let color):
            return .color(color)
        case .none:
            return .none
        }
    }
}
class CMPArgumentParser {
    static func parseConsentLayerUIConfig(from args: [String: Any]) -> ConsentLayerUIConfig {
        let position = BridgePosition.create(from: args["position"] as? String)
        let backgroundStyle = BridgeBackgroundStyle.create(from: args)

        let cornerRadius = args["cornerRadius"] as? CGFloat ?? 0
        let respectsSafeArea = args["respectsSafeArea"] as? Bool ?? true
        let allowsOrientationChanges = args["allowsOrientationChanges"] as? Bool ?? true

        return ConsentLayerUIConfig(
            objcPosition: position.toNativePosition(),
            objcBackgroundStyle: backgroundStyle.toNativeStyle(),
            cornerRadius: cornerRadius,
            respectsSafeArea: respectsSafeArea,
            allowsOrientationChanges: allowsOrientationChanges
        )
    }

    static func parseUrlConfig(from args: [String: Any]) -> UrlConfig {
        let id = args["id"] as! String
        let domain = args["domain"] as! String
        let language = args["language"] as! String
        let appName = args["appName"] as! String

        return UrlConfig(id: id, domain: domain, language: language, appName: appName)
    }

    private static func parsePosition(_ positionString: String?) -> Int {
        let bridgePosition = BridgePosition.create(from: positionString)
        switch bridgePosition {
        case .halfScreenTop:
            return 1 // Assuming this matches the SDK's internal position value
        case .halfScreenBottom:
            return 2
        case .custom:
            return 3
        case .fullScreen:
            return 0
        }
    }

    private static func parseBackgroundStyle(_ args: [String: Any]) -> ConsentLayerUIConfig.CMPBackgroundStyle {
        let backgroundStyle = BridgeBackgroundStyle.create(from: args)
        return backgroundStyle.toNativeStyle()
    }
}