import Flutter

class CMPMethodHandler {

    private var cmpManagerService: CMPManagerService?
    private var channel: FlutterMethodChannel?

    init(cmpManagerService: CMPManagerService?, channel: FlutterMethodChannel?) {
        self.cmpManagerService = cmpManagerService
        self.channel = channel
    }

    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "setWebViewConfig":
            setWebViewConfig(call: call, result: result)
        case "setUrlConfig":
            setUrlConfig(call: call, result: result)
        case "exportCMPInfo":
            exportCMPInfo(result: result)
        case "importCMPInfo":
            importCMPInfo(call: call, result: result)
        case "resetConsentManagementData":
            resetConsentManagementData(result: result)
        case "acceptAll":
            acceptAll(result: result)
        case "rejectAll":
            rejectAll(result: result)
        case "acceptPurposes":
            acceptPurposes(call: call, result: result)
        case "rejectPurposes":
            rejectPurposes(call: call, result: result)
        case "acceptVendors":
            acceptVendors(call: call, result: result)
        case "rejectVendors":
            rejectVendors(call: call, result: result)
        case "checkAndOpen":
            checkAndOpen(call: call, result: result)
        case "forceOpen":
            forceOpen(call: call, result: result)
        case "getUserStatus":
            getUserStatus(result: result)
        case "getStatusForPurpose":
            getStatusForPurpose(call: call, result: result)
        case "getStatusForVendor":
            getStatusForVendor(call: call, result: result)
        case "getGoogleConsentModeStatus":
            getGoogleConsentModeStatus(result: result)
        case "setOnClickLinkCallback":
            setOnClickLinkCallback(call: call, result: result)
        case "setAutomaticConsentUpdatesEnabled":
            setAutomaticConsentUpdatesEnabled(call: call, result: result)
        case "setATTStatus":
            setATTStatus(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(result: @escaping FlutterResult) {
        guard let rootVC = getRootViewController() else {
            result(FlutterError(code: "NO_ROOT_VC", message: "Root view controller not found", details: nil))
            return
        }
        cmpManagerService?.initialize(with: rootVC)
        result("CMPManager initialized")
    }

    private func setWebViewConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        cmpManagerService?.setWebViewConfigFromArgs(args)
        result("Consent Layer Configured")
    }

    private func setUrlConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        let config = CMPArgumentParser.parseUrlConfig(from: args)
        cmpManagerService?.setUrlConfig(config: config)
        result("Consent URL Configured")
    }

    // MARK: - New Methods (v3.1.0+)

    private func getUserStatus(result: @escaping FlutterResult) {
        if let status = cmpManagerService?.getUserStatus() {
            result(status)
        } else {
            result([
                "hasUserChoice": BridgeUserChoiceStatus.choiceDoesntExist.rawValue,
                "vendors": [:],
                "purposes": [:],
                "tcf": "",
                "addtlConsent": "",
                "regulation": ""
            ])
        }
    }

    private func getStatusForPurpose(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let purposeId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT",
                              message: "Purpose ID is required",
                              details: nil))
            return
        }

        let status = cmpManagerService?.getStatusForPurpose(purposeId: purposeId)
        result(status?.rawValue ?? "choiceDoesntExist")
    }

    private func getStatusForVendor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let vendorId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT",
                              message: "Vendor ID is required",
                              details: nil))
            return
        }

        let status = cmpManagerService?.getStatusForVendor(vendorId: vendorId)
        result(status?.rawValue ?? "choiceDoesntExist")
    }

    private func getGoogleConsentModeStatus(result: @escaping FlutterResult) {
        let status = cmpManagerService?.getGoogleConsentModeStatus()
        result(status ?? [:])
    }

    private func checkAndOpen(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let jumpToSettings = args?["jumpToSettings"] as? Bool ?? false

        cmpManagerService?.checkAndOpen(jumpToSettings: jumpToSettings) { error in
            if let error = error {
                result(FlutterError(code: "CHECK_AND_OPEN_ERROR",
                                  message: error,
                                  details: nil))
            } else {
                result(nil)
            }
        }
    }

    private func forceOpen(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let jumpToSettings = args?["jumpToSettings"] as? Bool ?? false

        cmpManagerService?.forceOpen(jumpToSettings: jumpToSettings) { error in
            if let error = error {
                result(FlutterError(code: "FORCE_OPEN_ERROR",
                                  message: error,
                                  details: nil))
            } else {
                result(nil)
            }
        }
    }

    private func exportCMPInfo(result: @escaping FlutterResult) {
        let cmpInfo = cmpManagerService?.exportCMPInfo()
        result(cmpInfo)
    }

    private func importCMPInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let cmpString = args["cmpString"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "CMP String is required", details: nil))
            return
        }
        cmpManagerService?.importCMPInfo(cmpString: cmpString) { success in
            result(success)
        }
    }

    private func resetConsentManagementData(result: @escaping FlutterResult) {
        cmpManagerService?.resetConsentManagementData { error in
            if let error = error {
                result(FlutterError(code: "RESET_ERROR", message: error, details: nil))
            } else {
                result("Consent data reset")
            }
        }
    }

    private func acceptAll(result: @escaping FlutterResult) {
        cmpManagerService?.acceptAll { error in
            if let error = error {
                result(FlutterError(code: "ACCEPT_ALL_ERROR", message: error, details: nil))
            } else {
                result("All consents accepted")
            }
        }
    }

    private func rejectAll(result: @escaping FlutterResult) {
        cmpManagerService?.rejectAll { error in
            if let error = error {
                result(FlutterError(code: "REJECT_ALL_ERROR", message: error, details: nil))
            } else {
                result("All consents rejected")
            }
        }
    }

    private func acceptPurposes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let purposes = args["purposes"] as? [String], let updateVendors = args["updateVendors"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Purposes or updateVendors not provided", details: nil))
            return
        }
        cmpManagerService?.acceptPurposes(purposes: purposes, updateVendors: updateVendors) { error in
            if let error = error {
                result(FlutterError(code: "ACCEPT_PURPOSES_ERROR", message: error, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func rejectPurposes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let purposes = args["purposes"] as? [String], let updateVendors = args["updateVendors"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Purposes or updateVendors not provided", details: nil))
            return
        }
        cmpManagerService?.rejectPurposes(purposes: purposes, updateVendors: updateVendors) { error in
            if let error = error {
                result(FlutterError(code: "REJECT_PURPOSES_ERROR", message: error, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func acceptVendors(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let vendors = args["vendors"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Vendors not provided", details: nil))
            return
        }
        cmpManagerService?.acceptVendors(vendors: vendors) { error in
            if let error = error {
                result(FlutterError(code: "ACCEPT_VENDORS_ERROR", message: error, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func rejectVendors(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let vendors = args["vendors"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Vendors not provided", details: nil))
            return
        }
        cmpManagerService?.rejectVendors(vendors: vendors) { error in
            if let error = error {
                result(FlutterError(code: "REJECT_VENDORS_ERROR", message: error, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func setOnClickLinkCallback(call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("iOS [DEBUG]: Setting up link click callback in CMPMethodHandler")
        
        let flutterChannel = self.channel
        
        cmpManagerService?.setOnClickLinkCallback { url in
            NSLog("iOS [DEBUG]: Link click intercepted in CMPMethodHandler: \(url)")
            NSLog("iOS [DEBUG]: Initially allowing navigation to prevent blocking")
            
            DispatchQueue.main.async {
                flutterChannel?.invokeMethod("onClickLink", arguments: ["url": url], result: { flutterResult in
                    if let boolResult = flutterResult as? Bool, boolResult == true {
                        NSLog("iOS [DEBUG]: Flutter handled link externally: \(url)")
                        
                        if let cmpManagerService = self.cmpManagerService {
                            DispatchQueue.main.async {
                                NSLog("iOS [DEBUG]: Attempting to stop webview navigation after external handling")
                                if let webViewController = cmpManagerService.findWebViewController(),
                                   let webView = cmpManagerService.findWebView(in: webViewController.view) {
                                    webView.stopLoading()
                                    NSLog("iOS [DEBUG]: Stopped webview navigation after external handling")
                                }
                            }
                        }
                    }
                })
            }
            
            return false
        }
        result("iOS: Native WebView link handling active")
    }
    
    private func setAutomaticConsentUpdatesEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Enabled parameter not provided", details: nil))
            return
        }
        
        // Call the instance method on cmpManagerService following the same pattern as other methods
        cmpManagerService?.setAutomaticConsentUpdatesEnabled(enabled)
        result("Automatic consent updates enabled: \(enabled)")
    }

    private func setATTStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let status = args["status"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Status parameter not provided", details: nil))
            return
        }
        
        cmpManagerService?.setATTStatus(status)
        result("ATT status set to: \(status)")
    }
}