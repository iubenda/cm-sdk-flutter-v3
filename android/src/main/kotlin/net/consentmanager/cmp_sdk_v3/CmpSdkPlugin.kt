package net.consentmanager.cmp_sdk_v3

import android.app.Activity
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.serialization.json.JsonObject
import net.consentmanager.cm_sdk_android_v3.CMPManager
import net.consentmanager.cm_sdk_android_v3.CMPManagerDelegate
import net.consentmanager.cm_sdk_android_v3.ConsentLayerUIConfig
import net.consentmanager.cm_sdk_android_v3.UrlConfig

class CmpSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, CMPManagerDelegate {

    private lateinit var channel: MethodChannel
    private var cmpManager: CMPManager? = null
    private var urlConfig: UrlConfig = UrlConfig("", "", "", "")
    private var webViewConfig: ConsentLayerUIConfig = ConsentLayerUIConfig(
        position = ConsentLayerUIConfig.Position.FULL_SCREEN,
        cornerRadius = 0f,
        respectsSafeArea = true,
        allowsOrientationChanges = true
    )
    private var activityContext: Activity? = null

    // FlutterPlugin interface implementation
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "cmp_sdk_v3")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityContext = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivity() {
        activityContext = null
    }

    // Initialization and Configuration
    private fun initializeCMPManager() {
        val activity = activityContext ?: throw IllegalStateException("Current activity is null")
        cmpManager = CMPManager.getInstance(activity, urlConfig, webViewConfig, this)
        cmpManager?.setActivity(activity)
    }

    private fun initialize(result: Result) {
        try {
            initializeCMPManager()
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize CMPManager: ${e.localizedMessage}", null)
        }
    }

    private fun setWebViewConfig(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: run {
            result.error("INVALID_ARGUMENTS", "Arguments for setting WebViewConfig are missing", null)
            return
        }
        webViewConfig = CmpArgumentParser.parseConsentLayerUIConfig(args)
        result.success(null)
    }

    private fun setUrlConfig(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: run {
            result.error("INVALID_ARGUMENTS", "Arguments for setting UrlConfig are missing", null)
            return
        }
        urlConfig = CmpArgumentParser.parseUrlConfig(args)
        initializeCMPManager()
        result.success(null)
    }

    // Consent Layer Actions
    private fun openConsentLayer(result: Result) {
        val handler = Handler(Looper.getMainLooper())
        handler.post {
            try {
                cmpManager?.openConsentLayer {
                    result.success(null)
                }
            } catch (e: Exception) {
                result.error("CONSENT_LAYER_ERROR", "Failed to open consent layer: ${e.localizedMessage}", null)
            }
        }
    }

    private fun jumpToSettings(result: Result) {
        try {
            // TODO No Function
            result.success(null)
        } catch (e: Exception) {
            result.error("SETTINGS_ERROR", "Failed to open settings: ${e.localizedMessage}", null)
        }
    }

    private fun checkWithServerAndOpenIfNecessary(result: Result) {
        cmpManager?.checkWithServerAndOpenIfNecessary {
            if (it.isSuccess) {
                result.success(null)
            } else {
                result.error("SERVER_CHECK_ERROR", "Failed to check with server", null)
            }
        }
    }

    private fun checkIfConsentIsRequired(result: Result) {
        try {
             cmpManager?.checkIfConsentIsRequired { isRequired ->
                result.success(isRequired)
            }
        } catch (e: Exception) {
            result.error("CONSENT_CHECK_ERROR", "Failed to check consent requirement: ${e.localizedMessage}", null)
        }
    }

    // Vendor and Purpose Consent Actions
    private fun hasVendorConsent(call: MethodCall, result: Result) {
        val id = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENTS", "Vendor ID is required", null)
            return
        }
        try {
            val hasConsent = cmpManager?.hasVendorConsent(id) ?: false
            result.success(hasConsent)
        } catch (e: Exception) {
            result.error("CONSENT_ERROR", "Failed to check vendor consent: ${e.localizedMessage}", null)
        }
    }

    private fun hasPurposeConsent(call: MethodCall, result: Result) {
        val id = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENTS", "Purpose ID is required", null)
            return
        }
        try {
            val hasConsent = cmpManager?.hasPurposeConsent(id) ?: false
            result.success(hasConsent)
        } catch (e: Exception) {
            result.error("CONSENT_ERROR", "Failed to check purpose consent: ${e.localizedMessage}", null)
        }
    }

    // Consent Management
    private fun acceptAll(result: Result) {
        cmpManager?.acceptAll {
            result.success(null)
        }
    }

    private fun rejectAll(result: Result) {
        cmpManager?.rejectAll {
            result.success(null)
        }
    }

    private fun acceptVendors(call: MethodCall, result: Result) {
        val ids = call.argument<List<String>>("ids") ?: run {
            result.error("INVALID_ARGUMENTS", "Vendor IDs are required", null)
            return
        }
        cmpManager?.acceptVendors(ids) {
            result.success(null)
        }
    }

    private fun rejectVendors(call: MethodCall, result: Result) {
        val ids = call.argument<List<String>>("ids") ?: run {
            result.error("INVALID_ARGUMENTS", "Vendor IDs are required", null)
            return
        }
        cmpManager?.rejectVendors(ids) {
            result.success(null)
        }
    }

    private fun acceptPurposes(call: MethodCall, result: Result) {
        val ids = call.argument<List<String>>("ids") ?: run {
            result.error("INVALID_ARGUMENTS", "Purpose IDs are required", null)
            return
        }
        val updateVendors = call.argument<Boolean>("updateVendors") ?: true
        cmpManager?.acceptPurposes(ids, updateVendors) {
            result.success(null)
        }
    }

    private fun rejectPurposes(call: MethodCall, result: Result) {
        val ids = call.argument<List<String>>("ids") ?: run {
            result.error("INVALID_ARGUMENTS", "Purpose IDs are required", null)
            return
        }
        val updateVendors = call.argument<Boolean>("updateVendors") ?: true
        cmpManager?.rejectPurposes(ids, updateVendors) {
            result.success(null)
        }
    }

    // Other Consent Functions
    private fun exportCMPInfo(result: Result) {
        try {
            val cmpInfo = cmpManager?.exportCMPInfo()
            result.success(cmpInfo)
        } catch (e: Exception) {
            result.error("EXPORT_ERROR", "Failed to export CMP info: ${e.localizedMessage}", null)
        }
    }

    private fun resetConsentManagementData(result: Result) {
        try {
            cmpManager?.resetConsentManagementData()
            result.success(null)
        } catch (e: Exception) {
            result.error("RESET_ERROR", "Failed to reset consent data: ${e.localizedMessage}", null)
        }
    }

    private fun getAllVendorsIDs(result: Result) {
        try {
            val ids = cmpManager?.getAllVendorsIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("VENDORS_ERROR", "Failed to get all vendors IDs: ${e.localizedMessage}", null)
        }
    }

    private fun getAllPurposesIDs(result: Result) {
        try {
            val ids = cmpManager?.getAllPurposesIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("PURPOSES_ERROR", "Failed to get all purposes IDs: ${e.localizedMessage}", null)
        }
    }

    private fun hasUserChoice(result: Result) {
        try {
            val hasChoice = cmpManager?.hasUserChoice() ?: false
            result.success(hasChoice)
        } catch (e: Exception) {
            result.error("USER_CHOICE_ERROR", "Failed to check user choice: ${e.localizedMessage}", null)
        }
    }

    private fun getEnabledPurposesIDs(result: Result) {
        try {
            val ids = cmpManager?.getEnabledPurposesIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("ENABLED_PURPOSES_ERROR", "Failed to get enabled purposes IDs: ${e.localizedMessage}", null)
        }
    }

    private fun getEnabledVendorsIDs(result: Result) {
        try {
            val ids = cmpManager?.getEnabledVendorsIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("ENABLED_VENDORS_ERROR", "Failed to get enabled vendors IDs: ${e.localizedMessage}", null)
        }
    }

    private fun getDisabledPurposesIDs(result: Result) {
        try {
            val ids = cmpManager?.getDisabledPurposesIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("DISABLED_PURPOSES_ERROR", "Failed to get disabled purposes IDs: ${e.localizedMessage}", null)
        }
    }

    private fun getDisabledVendorsIDs(result: Result) {
        try {
            val ids = cmpManager?.getDisabledVendorsIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("DISABLED_VENDORS_ERROR", "Failed to get disabled vendors IDs: ${e.localizedMessage}", null)
        }
    }

    // CMPManagerDelegate implementation
    override fun didReceiveError(error: String) {
        val arguments = mapOf("error" to error)
        channel.invokeMethod("didReceiveError", arguments)
    }

    override fun didReceiveConsent(consent: String, jsonObject: JsonObject) {
        val arguments = mapOf(
            "consent" to consent,
            "jsonObject" to jsonObject.toString()
        )
        channel.invokeMethod("didReceiveConsent", arguments)
    }

    override fun didShowConsentLayer() {
        channel.invokeMethod("didShowConsentLayer", null)
    }

    override fun didCloseConsentLayer() {
        channel.invokeMethod("didCloseConsentLayer", null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "setWebViewConfig" -> setWebViewConfig(call, result)
            "setUrlConfig" -> setUrlConfig(call, result)
            "checkWithServerAndOpenIfNecessary" -> checkWithServerAndOpenIfNecessary(result)
            "openConsentLayer" -> openConsentLayer(result)
            "jumpToSettings" -> jumpToSettings(result)
            "checkIfConsentIsRequired" -> checkIfConsentIsRequired(result)
            "hasVendorConsent" -> hasVendorConsent(call, result)
            "hasPurposeConsent" -> hasPurposeConsent(call, result)
            "exportCMPInfo" -> exportCMPInfo(result)
            "resetConsentManagementData" -> resetConsentManagementData(result)
            "getAllVendorsIDs" -> getAllVendorsIDs(result)
            "getAllPurposesIDs" -> getAllPurposesIDs(result)
            "hasUserChoice" -> hasUserChoice(result)
            "getEnabledPurposesIDs" -> getEnabledPurposesIDs(result)
            "getEnabledVendorsIDs" -> getEnabledVendorsIDs(result)
            "getDisabledPurposesIDs" -> getDisabledPurposesIDs(result)
            "getDisabledVendorsIDs" -> getDisabledVendorsIDs(result)
            "acceptAll" -> acceptAll(result)
            "rejectAll" -> rejectAll(result)
            "acceptVendors" -> acceptVendors(call, result)
            "rejectVendors" -> rejectVendors(call, result)
            "acceptPurposes" -> acceptPurposes(call, result)
            "rejectPurposes" -> rejectPurposes(call, result)
            else -> result.notImplemented()
        }
    }
}
