import Flutter
import UIKit
import cm_sdk_ios_v3

public class CmpSdkPlugin: NSObject, FlutterPlugin {

    var cmpManagerService: CMPManagerService?
    var methodHandler: CMPMethodHandler?
    var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cm_cmp_sdk_v3", binaryMessenger: registrar.messenger())
        let instance = CmpSdkPlugin()
        instance.channel = channel
        instance.setupServices(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private func setupServices(channel: FlutterMethodChannel) {
        self.cmpManagerService = CMPManagerService(channel: channel)
        self.methodHandler = CMPMethodHandler(cmpManagerService: cmpManagerService, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodHandler?.handle(call: call, result: result)
    }
}
