import Flutter
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

    init(channel: FlutterMethodChannel) {
            super.init()
            self.channel = channel
    }

    func initialize(with viewController: UIViewController) {
        self.cmpManager = CMPManager.shared
        self.cmpManager?.setPresentingViewController(viewController)
        self.cmpManager?.delegate = self
    }

    func setWebViewConfig(config: ConsentLayerUIConfig) {
        self.cmpManager?.setWebViewConfig(config)
    }

    func setUrlConfig(config: UrlConfig) {
        self.cmpManager?.setUrlConfig(config)
    }

    @available(*, deprecated, message: "Use checkAndOpen() instead")
    func checkWithServerAndOpenIfNecessary(completion: @escaping (String?) -> Void) {
        self.cmpManager?.checkWithServerAndOpenIfNecessary { error in
            completion(error?.localizedDescription)
        }
    }

    @available(*, deprecated, message: "Use forceOpen() instead")
    func openConsentLayer(completion: @escaping (String?) -> Void) {
        DispatchQueue.main.async {
            self.cmpManager?.openConsentLayer { error in
                completion(error?.localizedDescription)
            }
        }
    }

    @available(*, deprecated, message: "Use forceOpen() instead")
    func jumpToSettings(completion: @escaping (String?) -> Void) {
        DispatchQueue.main.async {
            self.cmpManager?.jumpToSettings { error in
                completion(error?.localizedDescription)
            }
        }
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func checkIfConsentIsRequired(completion: @escaping (Bool) -> Void) {
        self.cmpManager?.checkIfConsentIsRequired { isRequired in
            completion(isRequired)
        }
    }

    @available(*, deprecated, message: "Use getStatusForVendor() instead")
    func hasVendorConsent(vendorId: String) -> Bool {
        return self.cmpManager?.hasVendorConsent(id: vendorId) ?? false
    }

    @available(*, deprecated, message: "Use getStatusForPurpose() instead")
    func hasPurposeConsent(purposeId: String) -> Bool {
        return self.cmpManager?.hasPurposeConsent(id: purposeId) ?? false
    }

    func exportCMPInfo() -> String? {
        return self.cmpManager?.exportCMPInfo()
    }

    func resetConsentManagementData(completion: @escaping (String?) -> Void) {
        self.cmpManager?.resetConsentManagementData { error in
            completion(error?.localizedDescription)
        }
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func getAllVendorsIDs() -> [String]? {
        return self.cmpManager?.getAllVendorsIDs()
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func getAllPurposesIDs() -> [String]? {
        return self.cmpManager?.getAllPurposesIDs()
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func hasUserChoice() -> Bool {
        return self.cmpManager?.hasUserChoice() ?? false
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func getEnabledPurposesIDs() -> [String]? {
        return self.cmpManager?.getEnabledPurposesIDs()
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func getEnabledVendorsIDs() -> [String]? {
        return self.cmpManager?.getEnabledVendorsIDs()
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func getDisabledPurposesIDs() -> [String]? {
        return self.cmpManager?.getDisabledPurposesIDs()
    }

    @available(*, deprecated, message: "Use getUserStatus() instead")
    func getDisabledVendorsIDs() -> [String]? {
        return self.cmpManager?.getDisabledVendorsIDs()
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

        func forceOpen(jumpToSettings: Bool = false, completion: @escaping (String?) -> Void) {
            cmpManager?.forceOpen(jumpToSettings: jumpToSettings) { error in
                completion(error?.localizedDescription)
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
