import Foundation
import Flutter
import WebKit
import cm_sdk_ios_v3
import UIKit

public enum ConsentStatus: Int {
    case granted = 0
    case denied = 1
    case choiceDoesntExist = 2
}

public enum UserChoiceStatus: Int {
    case choiceExists = 0
    case requiresUpdate = 1
    case choiceDoesntExist = 2
}

class CMPManagerService: NSObject {

    var cmpManager: CMPManager?
    var channel: FlutterMethodChannel?
    var urlConfig: UrlConfig?
    var domainHost: String?
    private var webViewConfigArgs: [String: Any]?
    private var presentationObserver: NSObjectProtocol?
    private var linkClickHandler: ((String) -> Bool)?

    init(channel: FlutterMethodChannel) {
        super.init()
        self.channel = channel
        setupPresentationObserver()
    }

    deinit {
        if let observer = presentationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func getOnClickLinkCallback() -> ((String) -> Bool)? {
        NSLog("iOS [DEBUG]: getOnClickLinkCallback called, handler exists: \(linkClickHandler != nil)")
        return linkClickHandler
    }

    func setOnClickLinkCallback(_ handler: ((String) -> Bool)?) {
        NSLog("iOS [DEBUG]: setOnClickLinkCallback called in CMPManagerService with handler: \(handler != nil ? "set" : "nil")")
        self.linkClickHandler = handler

        if let cmpManager = self.cmpManager {
            NSLog("iOS [DEBUG]: cmpManager exists, setting link click handler")
            if let handler = handler {
                NSLog("iOS [DEBUG]: Setting link click handler on cmpManager")
                
                cmpManager.setLinkClickHandler { (url) -> Bool in
                    NSLog("iOS [DEBUG]: Link click handler called by WebViewManager for URL: \(url)")

                    // Ignore internal CMP navigations (same domain as UrlConfig)
                    if let domain = self.domainHost?.lowercased(),
                       let host = url.host?.lowercased(),
                       host.contains(domain) || domain.contains(host) {
                        NSLog("iOS [DEBUG]: Detected internal CMP navigation, letting WebView proceed")
                        return false
                    }

                    let handledByFlutter = handler(url.absoluteString)
                    NSLog("iOS [DEBUG]: Link \(url.absoluteString) handled by Flutter: \(handledByFlutter)")
                    NSLog("iOS [DEBUG]: Returning \(handledByFlutter) to WebViewManager - TRUE means CANCEL navigation")
                    
                    if handledByFlutter {
                        NSLog("iOS [DEBUG]: Flutter handled the link, FORCING navigation cancellation")
                        
                        DispatchQueue.main.async {
                            if let webViewController = self.findWebViewController(),
                               let webView = self.findWebView(in: webViewController.view) {
                                NSLog("iOS [DEBUG]: Found WebView in controller, stopping navigation")
                                webView.stopLoading()
                            }
                        }
                    }
                    
                    return handledByFlutter
                }
                NSLog("iOS [DEBUG]: Link click handler set on cmpManager")
            } else {
                NSLog("iOS [DEBUG]: Removing link click handler from cmpManager")
                cmpManager.removeLinkClickHandler()
            }
        }
    }

    private func setupPresentationObserver() {
        presentationObserver = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeVisibleNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyHalfScreenPositioningIfNeeded()
        }
    }

    private func applyHalfScreenPositioningIfNeeded() {
        guard let args = webViewConfigArgs,
              let position = args["position"] as? String,
              (position == "halfScreenTop" || position == "halfScreenBottom") else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let window = UIApplication.shared.windows.first,
               let rootVC = window.rootViewController,
               let presentedVC = self?.findPresentedWebViewController(from: rootVC) {
                self?.adjustWebViewPosition(presentedVC, position: position)
            }
        }
    }

    private func findPresentedWebViewController(from viewController: UIViewController) -> UIViewController? {
        if let presented = viewController.presentedViewController {
            if presented.view.subviews.contains(where: { $0 is WKWebView }) {
                return presented
            }
            return findPresentedWebViewController(from: presented)
        }
        return nil
    }

    private func adjustWebViewPosition(_ viewController: UIViewController, position: String) {
        let screenBounds = UIScreen.main.bounds
        let safeAreaInsets = viewController.view.safeAreaInsets

        guard let webView = findWebView(in: viewController.view) else { return }
        webView.translatesAutoresizingMaskIntoConstraints = true

        let height = (screenBounds.height - safeAreaInsets.top - safeAreaInsets.bottom) / 2
        var yOrigin: CGFloat = safeAreaInsets.top
        switch position {
        case "halfScreenTop":
            yOrigin = safeAreaInsets.top
        case "halfScreenBottom":
            yOrigin = screenBounds.height - height - safeAreaInsets.bottom
        default:
            break
        }

        webView.frame = CGRect(
            x: 0,
            y: yOrigin,
            width: screenBounds.width,
            height: height
        )

        // Add a dimmed background if requested
        if let styleString = webViewConfigArgs?["backgroundStyle"] as? String,
           styleString == "dimmed" {
            let colorValue = webViewConfigArgs?["backgroundColor"] as? Int ?? 0x000000
            let opacity = webViewConfigArgs?["backgroundOpacity"] as? CGFloat ?? 0.5
            let overlay = UIView(frame: screenBounds)
            overlay.backgroundColor = UIColor(rgb: colorValue).withAlphaComponent(opacity)
            overlay.isUserInteractionEnabled = false
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.view.insertSubview(overlay, belowSubview: webView)
        }

        webView.removeFromSuperview()
        viewController.view.addSubview(webView)
    }

    func initialize(with viewController: UIViewController) {
        self.cmpManager = CMPManager.shared
        self.cmpManager?.setPresentingViewController(viewController)
        self.cmpManager?.delegate = self
        if let urlConfig = self.urlConfig {
            self.cmpManager?.setUrlConfig(urlConfig)
        }
        if let configArgs = webViewConfigArgs {
            let config = CMPArgumentParser.parseConsentLayerUIConfig(from: configArgs)
            self.cmpManager?.setWebViewConfig(config)
        }
    }

    func setWebViewConfig(config: ConsentLayerUIConfig) {
        self.cmpManager?.setWebViewConfig(config)
    }

    func setWebViewConfigFromArgs(_ args: [String: Any]) {
        self.webViewConfigArgs = args

        var modifiedArgs = args
        if let position = args["position"] as? String,
           (position == "halfScreenTop" || position == "halfScreenBottom") {
            modifiedArgs["position"] = "fullScreen"
        }

        let config = CMPArgumentParser.parseConsentLayerUIConfig(from: modifiedArgs)
        self.cmpManager?.setWebViewConfig(config)
    }

    func setUrlConfig(config: UrlConfig) {
        self.urlConfig = config
        // Capture domain from config via KVC fallback
        if let domainValue = (config.value(forKey: "domain") as? String) {
            self.domainHost = domainValue
        }
        if let cmpManager = self.cmpManager {
            cmpManager.setUrlConfig(config)
        }
    }

    func exportCMPInfo() -> String? {
        return self.cmpManager?.exportCMPInfo()
    }

    func resetConsentManagementData(completion: @escaping (String?) -> Void) {
        self.cmpManager?.resetConsentManagementData { error in
            completion(error?.localizedDescription)
        }
    }

    func importCMPInfo(cmpString: String, completion: @escaping (Bool) -> Void) {
        self.cmpManager?.importCMPInfo(cmpString) { error in
            completion(error == nil)
        }
    }

    func acceptAll(completion: @escaping (String?) -> Void) {
        self.cmpManager?.acceptAll { error in
            completion(error?.localizedDescription)
        }
    }

    func rejectAll(completion: @escaping (String?) -> Void) {
        self.cmpManager?.rejectAll { error in
            completion(error?.localizedDescription)
        }
    }

    func acceptPurposes(purposes: [String], updateVendors: Bool, completion: @escaping (String?) -> Void) {
        self.cmpManager?.acceptPurposes(purposes, updatePurpose: updateVendors) { error in
            completion(error?.localizedDescription)
        }
    }

    func rejectPurposes(purposes: [String], updateVendors: Bool, completion: @escaping (String?) -> Void) {
        self.cmpManager?.rejectPurposes(purposes, updateVendor: updateVendors) { error in
            completion(error?.localizedDescription)
        }
    }

    func acceptVendors(vendors: [String], completion: @escaping (String?) -> Void) {
        self.cmpManager?.acceptVendors(vendors) { error in
            completion(error?.localizedDescription)
        }
    }

    func rejectVendors(vendors: [String], completion: @escaping (String?) -> Void) {
        self.cmpManager?.rejectVendors(vendors) { error in
            completion(error?.localizedDescription)
        }
    }

    // MARK: - New Methods (v3.1.0+)

    func getStatusForPurpose(purposeId: String) -> BridgeConsentStatus {
        guard let status = cmpManager?.getStatusForPurpose(id: purposeId) else {
            return .choiceDoesntExist
        }
        return mapToConsentStatus(status)
    }

    func getStatusForVendor(vendorId: String) -> BridgeConsentStatus {
        guard let status = cmpManager?.getStatusForVendor(id: vendorId) else {
            return .choiceDoesntExist
        }
        return mapToConsentStatus(status)
    }

    func getUserStatus() -> [String: Any] {
        guard let response = cmpManager?.getUserStatus() else {
            return createEmptyUserStatus()
        }

        var statusDict: [String: Any] = [
            "hasUserChoice": mapChoiceStatus(response.status),
            "vendors": response.vendors,
            "purposes": response.purposes,
            "tcf": response.tcf,
            "addtlConsent": response.addtlConsent,
            "regulation": response.regulation
        ]

        return convertDateValues(statusDict)
    }

    func getGoogleConsentModeStatus() -> [String: String] {
        return cmpManager?.getGoogleConsentModeStatus() ?? [:]
    }

    // MARK: - Updated Methods

    func checkAndOpen(jumpToSettings: Bool = false, completion: @escaping (String?) -> Void) {
        cmpManager?.checkAndOpen(jumpToSettings: jumpToSettings) { error in
            completion(error?.localizedDescription)
        }
    }

    func forceOpen(jumpToSettings: Bool, completion: @escaping (String?) -> Void) {
        cmpManager?.forceOpen(jumpToSettings: jumpToSettings) { error in
            completion(error?.localizedDescription)
        }
    }
    
    func setAutomaticConsentUpdatesEnabled(_ enabled: Bool) {
        cmpManager?.setAutomaticFirebaseConsentUpdatesEnabled(enabled)
    }

    func setATTStatus(_ status: Int) {
        cmpManager?.setATTStatus(status)
    }

    func isConsentRequired(completion: @escaping (Bool, Error?) -> Void) {
        cmpManager?.isConsentRequired { isRequired, error in
            completion(isRequired, error)
        }
    }

    // MARK: - Helper Methods

    private func createEmptyUserStatus() -> [String: Any] {
        return [
            "hasUserChoice": "choiceDoesntExist",
            "vendors": [:],
            "purposes": [:],
            "tcf": "",
            "addtlConsent": "",
            "regulation": ""
        ]
    }

    private func mapToConsentStatus(_ status: UniqueConsentStatus) -> BridgeConsentStatus {
        switch status {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .choiceDoesntExist:
            return .choiceDoesntExist
        @unknown default:
            return .choiceDoesntExist
        }
    }

    private func mapChoiceStatus(_ status: String) -> Int {
        switch status {
        case "choiceExists":
            return BridgeUserChoiceStatus.choiceExists.rawValue
        case "requiresUpdate":
            return BridgeUserChoiceStatus.requiresUpdate.rawValue
        default:
            return BridgeUserChoiceStatus.choiceDoesntExist.rawValue
        }
    }
    
    // MARK: - WebView Navigation Helper Methods
    
    func findWebViewController() -> UIViewController? {
        NSLog("iOS [DEBUG]: Searching for WebViewController")
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootVC = window.rootViewController else {
                NSLog("iOS [DEBUG]: Could not find root view controller")
                return nil
            }
            return findWebViewControllerRecursively(in: rootVC)
        } else {
            // Fallback for iOS 12 and below
            guard let window = UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else {
                NSLog("iOS [DEBUG]: Could not find root view controller")
                return nil
            }
            return findWebViewControllerRecursively(in: rootVC)
        }
    }
    
    func findWebView(in view: UIView) -> WKWebView? {
        if let webView = view as? WKWebView {
            NSLog("iOS [DEBUG]: Found WKWebView directly")
            return webView
        }
        
        for subview in view.subviews {
            if let webView = findWebView(in: subview) {
                return webView
            }
        }
        
        return nil
    }
    
    private func findWebViewControllerRecursively(in viewController: UIViewController) -> UIViewController? {
        NSLog("iOS [DEBUG]: Checking view controller: \(type(of: viewController))")
        
        if let _ = findWebView(in: viewController.view) {
            NSLog("iOS [DEBUG]: Found WebView in view controller: \(type(of: viewController))")
            return viewController
        }
        
        if let presented = viewController.presentedViewController {
            NSLog("iOS [DEBUG]: Checking presented view controller")
            if let webVC = findWebViewControllerRecursively(in: presented) {
                return webVC
            }
        }
        
        for child in viewController.children {
            NSLog("iOS [DEBUG]: Checking child view controller")
            if let webVC = findWebViewControllerRecursively(in: child) {
                return webVC
            }
        }
        
        if let navVC = viewController as? UINavigationController {
            NSLog("iOS [DEBUG]: Checking navigation controller's visible view controller")
            if let visibleVC = navVC.visibleViewController,
               let webVC = findWebViewControllerRecursively(in: visibleVC) {
                return webVC
            }
        }
        
        if let tabVC = viewController as? UITabBarController {
            NSLog("iOS [DEBUG]: Checking tab bar controller's selected view controller")
            if let selectedVC = tabVC.selectedViewController,
               let webVC = findWebViewControllerRecursively(in: selectedVC) {
                return webVC
            }
        }
        
        NSLog("iOS [DEBUG]: No WebView found in this view controller hierarchy")
        return nil
    }
}

extension CMPManagerService: CMPManagerDelegate {
    public func didChangeATTStatus(oldStatus: Int, newStatus: Int, lastUpdated: Date?) {
        let lastUpdatedString: String?
        if let date = lastUpdated {
            let formatter = ISO8601DateFormatter()
            lastUpdatedString = formatter.string(from: date)
        } else {
            lastUpdatedString = nil
        }

        let arguments: [String: Any] = [
            "oldStatus": oldStatus,
            "newStatus": newStatus,
            "lastUpdated": lastUpdatedString as Any
        ]
        self.channel?.invokeMethod("didChangeATTStatus", arguments: arguments)
    }

    public func didReceiveError(error: String) {
        let arguments: [String: Any] = ["error": error]
        self.channel?.invokeMethod("didReceiveError", arguments: arguments)
    }

    public func didReceiveConsent(consent: String, jsonObject: [String : Any]) {
        let safeJsonObject = convertDateValues(jsonObject)
        channel?.invokeMethod("didReceiveConsent", arguments: [
            "consent": consent,
            "jsonObject": safeJsonObject
        ])
    }

    public func didShowConsentLayer() {
        self.channel?.invokeMethod("didShowConsentLayer", arguments: nil)
        applyHalfScreenPositioningIfNeeded()
    }

    public func didCloseConsentLayer() {
        self.channel?.invokeMethod("didCloseConsentLayer", arguments: nil)
    }
}

extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

private func convertDateValues(_ dict: [String: Any]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, value) in dict {
        if let date = value as? Date {
            result[key] = date.toISOString()
        } else if let nestedDict = value as? [String: Any] {
            result[key] = convertDateValues(nestedDict)
        } else if let array = value as? [Any] {
            result[key] = array.map { item -> Any in
                if let date = item as? Date {
                    return date.toISOString()
                }
                if let dict = item as? [String: Any] {
                    return convertDateValues(dict)
                }
                return item
            }
        } else {
            result[key] = value
        }
    }
    return result
}

private func handleCallbackResponse(_ response: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let safeResponse = convertDateValues(response)
    completion(.success(safeResponse))
}
