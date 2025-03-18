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
        case "checkWithServerAndOpenIfNecessary":
            checkWithServerAndOpenIfNecessary(result: result)
        case "jumpToSettings":
            jumpToSettings(result: result)
        case "openConsentLayer":
            openConsentLayer(result: result)
        case "checkIfConsentIsRequired":
            checkIfConsentIsRequired(result: result)
        case "hasVendorConsent":
            hasVendorConsent(call: call, result: result)
        case "hasPurposeConsent":
            hasPurposeConsent(call: call, result: result)
        case "exportCMPInfo":
            exportCMPInfo(result: result)
        case "importCMPInfo":
            importCMPInfo(call: call, result: result)
        case "resetConsentManagementData":
            resetConsentManagementData(result: result)
        case "getAllVendorsIDs":
            getAllVendorsIDs(result: result)
        case "getAllPurposesIDs":
            getAllPurposesIDs(result: result)
        case "hasUserChoice":
            hasUserChoice(result: result)
        case "getEnabledPurposesIDs":
            getEnabledPurposesIDs(result: result)
        case "getEnabledVendorsIDs":
            getEnabledVendorsIDs(result: result)
        case "getDisabledPurposesIDs":
            getDisabledPurposesIDs(result: result)
        case "getDisabledVendorsIDs":
            getDisabledVendorsIDs(result: result)
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
        let config = CMPArgumentParser.parseConsentLayerUIConfig(from: args)
        cmpManagerService?.setWebViewConfig(config: config)
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
            result(status) // status is already a dictionary with the correct format
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


    private func checkWithServerAndOpenIfNecessary(result: @escaping FlutterResult) {
        cmpManagerService?.checkWithServerAndOpenIfNecessary { error in
            if let error = error {
                result(FlutterError(code: "SERVER_ERROR", message: error, details: nil))
            } else {
                result("Success")
            }
        }
    }

    private func jumpToSettings(result: @escaping FlutterResult) {
        cmpManagerService?.jumpToSettings { error in
            if let error = error {
                result(FlutterError(code: "SETTINGS_ERROR", message: error, details: nil))
            } else {
                result("Success")
            }
        }
    }

    private func openConsentLayer(result: @escaping FlutterResult) {
        cmpManagerService?.openConsentLayer { error in
            if let error = error {
                result(FlutterError(code: "CONSENT_LAYER_ERROR", message: error, details: nil))
            } else {
                result("Consent Layer Opened")
            }
        }
    }

    private func checkIfConsentIsRequired(result: @escaping FlutterResult) {
        cmpManagerService?.checkIfConsentIsRequired { isRequired in
            result(isRequired)
        }
    }

    private func hasVendorConsent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let vendorId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Vendor ID is required", details: nil))
            return
        }
        let hasConsent = cmpManagerService?.hasVendorConsent(vendorId: vendorId) ?? false
        result(hasConsent)
    }

    private func hasPurposeConsent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let purposeId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Purpose ID is required", details: nil))
            return
        }
        let hasConsent = cmpManagerService?.hasPurposeConsent(purposeId: purposeId) ?? false
        result(hasConsent)
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

    private func getAllVendorsIDs(result: @escaping FlutterResult) {
        let vendorIds = cmpManagerService?.getAllVendorsIDs()
        result(vendorIds)
    }

    private func getAllPurposesIDs(result: @escaping FlutterResult) {
        let purposeIds = cmpManagerService?.getAllPurposesIDs()
        result(purposeIds)
    }

    private func hasUserChoice(result: @escaping FlutterResult) {
        let hasConsent = cmpManagerService?.hasUserChoice() ?? false
        result(hasConsent)
    }

    private func getEnabledPurposesIDs(result: @escaping FlutterResult) {
        let purposes = cmpManagerService?.getEnabledPurposesIDs()
        result(purposes)
    }

    private func getEnabledVendorsIDs(result: @escaping FlutterResult) {
        let vendors = cmpManagerService?.getEnabledVendorsIDs()
        result(vendors)
    }

    private func getDisabledPurposesIDs(result: @escaping FlutterResult) {
        let purposes = cmpManagerService?.getDisabledPurposesIDs()
        result(purposes)
    }

    private func getDisabledVendorsIDs(result: @escaping FlutterResult) {
        let vendors = cmpManagerService?.getDisabledVendorsIDs()
        result(vendors)
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
}
