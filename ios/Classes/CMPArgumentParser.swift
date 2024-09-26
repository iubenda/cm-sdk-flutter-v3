import cm_sdk_ios_v3
import UIKit

class CMPArgumentParser {

    static func parseConsentLayerUIConfig(from args: [String: Any]) -> ConsentLayerUIConfig {
        let position: ConsentLayerUIConfig.Position = parsePosition(args["position"] as? String)
        let backgroundStyle: ConsentLayerUIConfig.BackgroundStyle = parseBackgroundStyle(args)

        let cornerRadius = args["cornerRadius"] as? CGFloat ?? 0
        let respectsSafeArea = args["respectsSafeArea"] as? Bool ?? true
        let allowsOrientationChanges = args["allowsOrientationChanges"] as? Bool ?? true

        return ConsentLayerUIConfig(
            position: position,
            backgroundStyle: backgroundStyle,
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

    private static func parsePosition(_ positionString: String?) -> ConsentLayerUIConfig.Position {
        switch positionString {
        case "halfScreenTop":
            return .halfScreenTop
        case "halfScreenBottom":
            return .halfScreenBottom
        case "custom":
            return .custom(CGRect.zero) // Add custom logic
        default:
            return .fullScreen
        }
    }

    private static func parseBackgroundStyle(_ args: [String: Any]) -> ConsentLayerUIConfig.BackgroundStyle {
        let backgroundStyleString = args["backgroundStyle"] as? String ?? "dimmed"
        switch backgroundStyleString {
        case "blur":
            return .blur(.dark)
        case "color":
            let colorValue = args["backgroundColor"] as? Int ?? 0x000000
            return .color(UIColor(rgb: colorValue))
        case "none":
            return .none
        default:
            let colorValue = args["backgroundColor"] as? Int ?? 0x000000
            let opacity = args["backgroundOpacity"] as? CGFloat ?? 0.5
            return .dimmed(UIColor(rgb: colorValue), opacity)
        }
    }
}
