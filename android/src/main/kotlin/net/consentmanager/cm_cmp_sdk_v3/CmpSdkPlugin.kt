package net.consentmanager.cm_cmp_sdk_v3

import android.util.Log
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
import net.consentmanager.cm_sdk_android_v3.CMPManager
import net.consentmanager.cm_sdk_android_v3.CMPManagerDelegate
import net.consentmanager.cm_sdk_android_v3.ConsentLayerUIConfig
import net.consentmanager.cm_sdk_android_v3.UrlConfig
import net.consentmanager.cm_sdk_android_v3.ConsentStatus

class CmpSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, CMPManagerDelegate {

    private lateinit var channel: MethodChannel
    private var cmpManager: CMPManager? = null
    private var urlConfig: UrlConfig? = null
    private var webViewConfig: ConsentLayerUIConfig = ConsentLayerUIConfig(
        position = ConsentLayerUIConfig.Position.FULL_SCREEN,
        cornerRadius = 0f,
        respectsSafeArea = true,
        allowsOrientationChanges = true
    )

    private var activityContext: Activity? = null

    // FlutterPlugin interface implementation
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "cm_cmp_sdk_v3")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityContext = binding.activity
        if (urlConfig != null) {
            initializeCMPManager()
        }
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
        val config = urlConfig ?: throw IllegalStateException("URL config not set")  // Add null check
        cmpManager = CMPManager.getInstance(activity, config, webViewConfig, this)
        cmpManager?.setActivity(activity)
    }

    private fun initialize(result: Result) {
        try {
            initializeCMPManager()
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize CMPManager: ${e.toString()}", null)
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

        Log.d("CmpSdkPlugin", "Received URL config params: $args")

        val id = args["id"] as? String ?: ""
        val domain = args["domain"] as? String ?: ""
        val language = args["language"] as? String ?: ""
        val appName = args["appName"] as? String ?: ""

        Log.d("CmpSdkPlugin", "Extracted config - id: $id, domain: $domain, language: $language, appName: $appName")

        urlConfig = UrlConfig(id, domain, language, appName)
        cmpManager = null

        try {
            if (activityContext != null) {
                initializeCMPManager()
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("URL_CONFIG_ERROR", "Failed to set URL config: ${e.message}", null)
        }
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
                result.error("CONSENT_LAYER_ERROR", "Failed to open consent layer: ${e.toString()}", null)
            }
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
            result.error("CONSENT_CHECK_ERROR", "Failed to check consent requirement: ${e.toString()}", null)
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
            result.error("CONSENT_ERROR", "Failed to check vendor consent: ${e.toString()}", null)
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
            result.error("CONSENT_ERROR", "Failed to check purpose consent: ${e.toString()}", null)
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
            result.error("EXPORT_ERROR", "Failed to export CMP info: ${e.toString()}", null)
        }
    }

    private fun resetConsentManagementData(result: Result) {
        try {
            cmpManager?.resetConsentManagementData()
            result.success(null)
        } catch (e: Exception) {
            result.error("RESET_ERROR", "Failed to reset consent data: ${e.toString()}", null)
        }
    }

    private fun getAllVendorsIDs(result: Result) {
        try {
            val ids = cmpManager?.getAllVendorsIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("VENDORS_ERROR", "Failed to get all vendors IDs: ${e.toString()}", null)
        }
    }

    private fun getAllPurposesIDs(result: Result) {
        try {
            val ids = cmpManager?.getAllPurposesIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("PURPOSES_ERROR", "Failed to get all purposes IDs: ${e.toString()}", null)
        }
    }

    private fun hasUserChoice(result: Result) {
        try {
            val hasChoice = cmpManager?.hasUserChoice() ?: false
            result.success(hasChoice)
        } catch (e: Exception) {
            result.error("USER_CHOICE_ERROR", "Failed to check user choice: ${e.toString()}", null)
        }
    }

    private fun getEnabledPurposesIDs(result: Result) {
        try {
            val ids = cmpManager?.getEnabledPurposesIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("ENABLED_PURPOSES_ERROR", "Failed to get enabled purposes IDs: ${e.toString()}", null)
        }
    }

    private fun getEnabledVendorsIDs(result: Result) {
        try {
            val ids = cmpManager?.getEnabledVendorsIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("ENABLED_VENDORS_ERROR", "Failed to get enabled vendors IDs: ${e.toString()}", null)
        }
    }

    private fun getDisabledPurposesIDs(result: Result) {
        try {
            val ids = cmpManager?.getDisabledPurposesIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("DISABLED_PURPOSES_ERROR", "Failed to get disabled purposes IDs: ${e.toString()}", null)
        }
    }

    private fun getDisabledVendorsIDs(result: Result) {
        try {
            val ids = cmpManager?.getDisabledVendorsIDs()
            result.success(ids)
        } catch (e: Exception) {
            result.error("DISABLED_VENDORS_ERROR", "Failed to get disabled vendors IDs: ${e.toString()}", null)
        }
    }

    private fun getUserStatus(result: Result) {
        try {
            val status = cmpManager?.getUserStatus()
            Log.d("Raw User Status: ", "$status")

            val convertedVendors = status?.vendors?.mapValues {
                when(it.value) {
                    ConsentStatus.GRANTED -> 0
                    ConsentStatus.DENIED -> 1
                    else -> 2  // choiceDoesntExist
                }
            } ?: emptyMap()

            val convertedPurposes = status?.purposes?.mapValues {
                when(it.value) {
                    ConsentStatus.GRANTED -> 0
                    ConsentStatus.DENIED -> 1
                    else -> 2  // choiceDoesntExist
                }
            } ?: emptyMap()

            val statusMap = mapOf(
                "hasUserChoice" to (status?.hasUserChoice?.ordinal ?: 2), // 2 = choiceDoesntExist
                "vendors" to convertedVendors,
                "purposes" to convertedPurposes,
                "tcf" to (status?.tcf ?: ""),
                "addtlConsent" to (status?.addtlConsent ?: ""),
                "regulation" to (status?.regulation ?: "")
            )
            Log.d("User Status Map: ", "$statusMap")
            result.success(statusMap)
        } catch (e: Exception) {
            result.error("USER_STATUS_ERROR", "Failed to get user status: ${e.toString()}", null)
        }
    }

    private fun getStatusForPurpose(call: MethodCall, result: Result) {
        val id = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Purpose ID is required", null)
            return
        }
        try {
            val status = cmpManager?.getStatusForPurpose(id)
            result.success(status?.ordinal)
        } catch (e: Exception) {
            result.error("PURPOSE_STATUS_ERROR", "Failed to get purpose status: ${e.toString()}", null)
        }
    }

    private fun getStatusForVendor(call: MethodCall, result: Result) {
        val id = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Vendor ID is required", null)
            return
        }
        try {
            val status = cmpManager?.getStatusForVendor(id)
            result.success(status?.ordinal)
        } catch (e: Exception) {
            result.error("VENDOR_STATUS_ERROR", "Failed to get vendor status: ${e.toString()}", null)
        }
    }

    private fun getGoogleConsentModeStatus(result: Result) {
        try {
            val status = cmpManager?.getGoogleConsentModeStatus()
            result.success(status)
        } catch (e: Exception) {
            result.error("CONSENT_MODE_ERROR", "Failed to get Google consent mode status: ${e.toString()}", null)
        }
    }

    private fun checkAndOpen(call: MethodCall, result: Result) {
        val jumpToSettings = call.argument<Boolean>("jumpToSettings") ?: false
        val handler = Handler(Looper.getMainLooper())
        handler.post {
            cmpManager?.checkAndOpen(jumpToSettings) { kotlinResult ->
                kotlinResult.onSuccess {
                    result.success(true)
                }.onFailure { error ->
                    result.error("CHECK_AND_OPEN_ERROR", error.message, null)
                }
            }
        }
    }

    private fun forceOpen(call: MethodCall, result: Result) {
        val jumpToSettings = call.argument<Boolean>("jumpToSettings") ?: false
        val handler = Handler(Looper.getMainLooper())
        handler.post {
            cmpManager?.forceOpen(jumpToSettings) { kotlinResult ->
                kotlinResult.onSuccess {
                    result.success(true)
                }.onFailure { error ->
                    result.error("CHECK_AND_OPEN_ERROR", error.message, null)
                }
            }
        }
    }

    // CMPManagerDelegate implementation
    override fun didReceiveError(error: String) {
        val arguments = mapOf("error" to error)
        channel.invokeMethod("didReceiveError", arguments)
    }

    override fun didReceiveConsent(consent: String, jsonObject: Map<String, Any>) {
        val arguments: Map<String, Any> = mapOf(
            "consent" to consent,
            "jsonObject" to jsonObject
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
            "checkWithServerAndOpenIfNecessary" -> {
                println("Warning: checkWithServerAndOpenIfNecessary is deprecated. Use checkAndOpen instead")
                checkAndOpen(call, result)
            }
            "openConsentLayer" -> {
                println("Warning: openConsentLayer is deprecated. Use forceOpen instead")
                forceOpen(call, result)
            }
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
            "getUserStatus" -> getUserStatus(result)
            "getStatusForPurpose" -> getStatusForPurpose(call, result)
            "getStatusForVendor" -> getStatusForVendor(call, result)
            "getGoogleConsentModeStatus" -> getGoogleConsentModeStatus(result)
            "checkAndOpen" -> checkAndOpen(call, result)
            "forceOpen" -> forceOpen(call, result)
            "setOnClickLinkCallback" -> setOnClickLinkCallback(call, result)
            "setAutomaticConsentUpdatesEnabled" -> setAutomaticConsentUpdatesEnabled(call, result)
            else -> result.notImplemented()
        }
    }

    private fun setOnClickLinkCallback(call: MethodCall, result: Result) {
        try {
            Log.d("CmpSdkPlugin", "Setting link click callback")

            cmpManager?.setOnClickLinkCallback { url ->
                Log.d("CmpSdkPlugin", "Link clicked: $url")

                var handled = false
                val latch = java.util.concurrent.CountDownLatch(1)

                Handler(Looper.getMainLooper()).post {
                    Log.d("CmpSdkPlugin", "Sending link click to Flutter: $url")

                    channel.invokeMethod("onClickLink", mapOf("url" to url), object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            Log.d("CmpSdkPlugin", "Flutter handled link: $result")
                            handled = result as? Boolean ?: false
                            latch.countDown()
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            Log.e("CmpSdkPlugin", "Error in link callback: $errorCode - $errorMessage")
                            handled = false
                            latch.countDown()
                        }

                        override fun notImplemented() {
                            Log.e("CmpSdkPlugin", "onClickLink not implemented in Flutter")
                            handled = false
                            latch.countDown()
                        }
                    })
                }

                try {
                    latch.await(500, java.util.concurrent.TimeUnit.MILLISECONDS)
                    Log.d("CmpSdkPlugin", "Link handling result: $handled")
                } catch (e: Exception) {
                    Log.e("CmpSdkPlugin", "Error waiting for link click handler: ${e.message}")
                }

                return@setOnClickLinkCallback true
            }

            result.success(true)
            Log.d("CmpSdkPlugin", "Link click callback set successfully")
        } catch (e: Exception) {
            Log.e("CmpSdkPlugin", "Failed to set click callback: ${e.message}", e)
            result.error("CALLBACK_ERROR", "Failed to set click callback: ${e.toString()}", null)
        }
    }
    
    private fun setAutomaticConsentUpdatesEnabled(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: run {
            result.error("INVALID_ARGUMENT", "Enabled parameter not provided", null)
            return
        }
        
        try {
            cmpManager?.setAutomaticConsentUpdatesEnabled(enabled)
            result.success("Automatic consent updates enabled: $enabled")
        } catch (e: Exception) {
            result.error("SET_AUTOMATIC_CONSENT_ERROR", "Failed to set automatic consent updates: ${e.message}", null)
        }
    }
}
