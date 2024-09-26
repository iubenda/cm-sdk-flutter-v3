import Flutter
import cm_sdk_ios_v3
import UIKit

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

    func checkWithServerAndOpenIfNecessary(completion: @escaping (String?) -> Void) {
        self.cmpManager?.checkWithServerAndOpenIfNecessary { error in
            completion(error?.localizedDescription)
        }
    }

    func openConsentLayer(completion: @escaping (String?) -> Void) {
        DispatchQueue.main.async {
            self.cmpManager?.openConsentLayer { error in
                completion(error?.localizedDescription)
            }
        }
    }

    func jumpToSettings(completion: @escaping (String?) -> Void) {
        DispatchQueue.main.async {
            self.cmpManager?.jumpToSettings { error in
                completion(error?.localizedDescription)
            }
        }
    }

    func checkIfConsentIsRequired(completion: @escaping (Bool) -> Void) {
        self.cmpManager?.checkIfConsentIsRequired { isRequired in
            completion(isRequired)
        }
    }

    func hasVendorConsent(vendorId: String) -> Bool {
        return self.cmpManager?.hasVendorConsent(id: vendorId) ?? false
    }

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

    func getAllVendorsIDs() -> [String]? {
        return self.cmpManager?.getAllVendorsIDs()
    }

    func getAllPurposesIDs() -> [String]? {
        return self.cmpManager?.getAllPurposesIDs()
    }

    func hasUserChoice() -> Bool {
        return self.cmpManager?.hasUserChoice() ?? false
    }

    func getEnabledPurposesIDs() -> [String]? {
        return self.cmpManager?.getEnabledPurposesIDs()
    }

    func getEnabledVendorsIDs() -> [String]? {
        return self.cmpManager?.getEnabledVendorsIDs()
    }

    func getDisabledPurposesIDs() -> [String]? {
        return self.cmpManager?.getDisabledPurposesIDs()
    }

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

    func requestATTPermission(completion: @escaping (Int) -> Void) {
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                self.cmpManager?.requestATTAuthorization { status in
                    completion(status.rawValue)
                }
            }
        } else {
            completion(0)
        }
    }

    func getATTAuthorizationStatus() -> Int {
        if #available(iOS 14, *) {
            return self.cmpManager?.getATTAuthorizationStatus().rawValue ?? 0
        }
        return 0
    }
}

extension CMPManagerService: CMPManagerDelegate {
 public func didChangeATTStatus(oldStatus: Int, newStatus: Int, lastUpdated: Date?) {
        let dateFormatter = ISO8601DateFormatter()
        let lastUpdatedString = lastUpdated != nil ? dateFormatter.string(from: lastUpdated!) : nil

        let arguments: [String: Any?] = [
            "oldStatus": oldStatus,
            "newStatus": newStatus,
            "lastUpdated": lastUpdatedString
        ]
        self.channel?.invokeMethod("didChangeATTStatus", arguments: arguments)
    }

    public func didReceiveError(error: String) {
        let arguments: [String: Any] = ["error": error]
        self.channel?.invokeMethod("didReceiveError", arguments: arguments)
    }

    public func didReceiveConsent(consent: String, jsonObject: [String : Any]) {
        let arguments: [String: Any] = [
            "consent": consent,
            "jsonObject": jsonObject
        ]
        self.channel?.invokeMethod("didReceiveError", arguments: arguments)
    }

    public func didShowConsentLayer() {
        self.channel?.invokeMethod("didShowConsentLayer", arguments: nil)
    }

    public func didCloseConsentLayer() {
        self.channel?.invokeMethod("didCloseConsentLayer", arguments: nil)
    }
}
