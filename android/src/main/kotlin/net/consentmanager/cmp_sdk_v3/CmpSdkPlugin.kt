package net.consentmanager.cmp_sdk_v3

import android.app.Activity
import android.util.Log
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.consentmanager.sdk.CmpManager
import net.consentmanager.sdk.consentlayer.model.CmpConfig
import net.consentmanager.sdk.consentlayer.model.CmpUIConfig
import net.consentmanager.sdk.consentlayer.model.CmpUIStrategy
import net.consentmanager.sdk.consentlayer.model.valueObjects.ConsentType
import java.util.Locale

/** CmpSdkPlugin */
class CmpSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var consentManager: CmpManager? = null
    private var activityContext: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cmp_sdk_v3")
        channel.setMethodCallHandler(this)
    }

    // ActivityAware interface implementations
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

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "createInstance" -> createInstance(call, result)
            "createInstanceWithConfig" -> createInstanceWithConfig(call, result)
            "initialize" -> initialize(result)
            "setCallbacks" -> setCallbacks()
            "openConsentLayerOnCheck" -> openConsentLayerOnCheck(result)
            "openConsentLayer" -> openConsentLayer(result)
            "hasVendor" -> hasVendor(call, result)
            "hasPurpose" -> hasPurpose(call, result)
            "exportCmpString" -> exportCmpString(result)
            "reset" -> reset(result)
            "getAllVendors" -> getAllVendors(result)
            "getAllPurposes" -> getAllPurposes(result)
            "hasConsent" -> hasConsent(result)
            "getEnabledPurposes" -> getEnabledPurposes(result)
            "getEnabledVendors" -> getEnabledVendors(result)
            "getDisabledPurposes" -> getDisabledPurposes(result)
            "getDisabledVendors" -> getDisabledVendors(result)
            "getUSPrivacyString" -> getUSPrivacyString(result)
            "getGoogleACString" -> getGoogleACString(result)
            "consentRequestedToday" -> consentRequestedToday(result)
            "importCmpString" -> importCmpString(call, result)
            "check" -> check(call, result)
            "acceptAll" -> acceptAll(result)
            "rejectAll" -> rejectAll(result)
            "enablePurposes" -> enablePurposes(call, result)
            "disablePurposes" -> disablePurposes(call, result)
            "enableVendors" -> enableVendors(call, result)
            "disableVendors" -> disableVendors(call, result)
            "configureConsentLayer" -> configureConsentLayer(call, result)

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun createInstance(call: MethodCall, result: Result) {
        // Extract arguments from the MethodCall object
        val id =
            call.argument<String>("id")
                ?: return result.error("INVALID_ARGUMENTS", "ID is required", null)
        val domain =
            call.argument<String>("domain")
                ?: return result.error("INVALID_ARGUMENTS", "Domain is required", null)
        val appName =
            call.argument<String>("appName")
                ?: return result.error("INVALID_ARGUMENTS", "AppName is required", null)
        val language =
            call.argument<String>("language")
                ?: return result.error("INVALID_ARGUMENTS", "Language is required", null)

        // Configure CmpConfig with the extracted arguments
        CmpConfig.id = id
        CmpConfig.domain = domain
        CmpConfig.appName = appName
        CmpConfig.language = language
        CmpConfig.timeout = 5000

        // Create an instance of CmpManager with the configured CmpConfig
        consentManager = activityContext?.let { CmpManager.createInstance(it, CmpConfig) }

        // Return success result
        result.success(null)
    }

    private fun createInstanceWithConfig(call: MethodCall, result: Result) {
        val configMap =
            call.arguments<Map<String, Any>>()
                ?: return result.error("INVALID_ARGUMENTS", "Config map is required", null)

        CmpConfig.id =
            configMap["id"] as? String ?: CmpConfig.id // Keep existing value if not provided
        CmpConfig.domain = configMap["domain"] as? String ?: CmpConfig.domain
        CmpConfig.appName = configMap["appName"] as? String ?: CmpConfig.appName
        CmpConfig.language = configMap["language"] as? String ?: CmpConfig.language
        CmpConfig.gaid = configMap["idfaOrGaid"] as? String ?: CmpConfig.gaid
        CmpConfig.timeout = configMap["timeout"] as? Int ?: CmpConfig.timeout
        CmpConfig.jumpToSettingsPage =
            configMap["jumpToSettingsPage"] as? Boolean ?: CmpConfig.jumpToSettingsPage
        if (configMap["isDebugMode"] as Boolean) {
            CmpConfig.enableDebugMode()
        }

        val screenConfigIdx = configMap["screenConfig"] as? String ?: "FULLSCREEN"

        Log.d("CMPTEST", screenConfigIdx)
        val screenConfig = mapScreenConfig(screenConfigIdx)


        if (screenConfig == null) {
            result.error("INVALID_ARGUMENTS", "Invalid or missing screenConfig", null)
            return
        }

        configureScreen(screenConfig)
        val androidStyle = mapAndroidPresentationStyleToCmpUIStrategy(
            configMap["androidPresentationStyle"] as? String ?: "POPUP"
        )
        CmpUIConfig.uiStrategy = androidStyle

        consentManager = activityContext?.let { CmpManager.createInstance(it, CmpConfig) }

        result.success(null)
    }

private fun initialize(result: Result) {
    val handler = Handler(Looper.getMainLooper())
    handler.post {
        try {
            consentManager?.initialize(activityContext!!)
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to initialize CMP: ${e.localizedMessage}", null)
        }
    }
}


    private fun setCallbacks() {
        consentManager?.addEventListeners(
            openListener = {
                println("openListener triggered")
                channel.invokeMethod("onOpen", null)
            },
            closeListener = {
                println("onClose triggered")
                channel.invokeMethod("onClose", null)
            },
            cmpNotOpenedCallback = { channel.invokeMethod("onNotOpened", null) },
            onErrorCallback = { type, message ->
                val errorMap = hashMapOf("type" to type.toString(), "message" to message)
                channel.invokeMethod("onError", errorMap)
            },
            onButtonClickedCallback = { event ->
                val buttonTypeMap = hashMapOf("buttonType" to event.toString())
                channel.invokeMethod("onButtonClicked", buttonTypeMap)
            },
            googleConsentModeListener = { consentMap ->
                val consentMapString = consentMap.mapKeys { (key, _) -> key.name }
                    .mapValues { (_, value) -> value.name }

                channel.invokeMethod(
                    "onGoogleConsentUpdated",
                    hashMapOf("consentMap" to consentMapString)
                )
            }
        )
    }

    private fun openConsentLayerOnCheck(result: Result) {
            val handler = Handler(Looper.getMainLooper())
    handler.post {
        try {
            activityContext?.let { consentManager?.openConsentLayerOnCheck(it) }
            result.success(null)
        } catch (e: Exception) {
            result.error(
                "ERROR",
                "Failed to open consent layer on check: ${e.localizedMessage}",
                null
            )
        }
    }
    }

    private fun openConsentLayer(result: Result) {
            val handler = Handler(Looper.getMainLooper())
    handler.post {
        try {
            activityContext?.let { consentManager?.openConsentLayer(it) }
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to open consent layer: ${e.localizedMessage}", null)
        }
    }
    }

    private fun hasVendor(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val defaultReturn = call.argument<Boolean?>("defaultReturn")
        if (id == null) {
            result.error("INVALID_ARGUMENTS", "Vendor ID is required", null)
        } else {
            try {
                val hasConsent = consentManager?.hasVendor(id, defaultReturn ?: true) ?: false
                result.success(hasConsent)
            } catch (e: Exception) {
                result.error("ERROR", "Failed to check vendor consent: ${e.localizedMessage}", null)
            }
        }
    }

    private fun hasPurpose(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val defaultReturn = call.argument<Boolean?>("defaultReturn")
        if (id == null) {
            result.error("INVALID_ARGUMENTS", "Purpose ID is required", null)
        } else {
            try {
                val hasConsent = consentManager?.hasPurpose(id, defaultReturn ?: true) ?: false
                result.success(hasConsent)
            } catch (e: Exception) {
                result.error(
                    "ERROR",
                    "Failed to check purpose consent: ${e.localizedMessage}",
                    null
                )
            }
        }
    }

    private fun exportCmpString(result: Result) {
        try {
            val cmpString = consentManager?.exportCmpString()
            result.success(cmpString)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to export CMP string: ${e.localizedMessage}", null)
        }
    }

    private fun reset(result: Result) {
        try {
            activityContext?.let { CmpManager.reset(it) }
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to reset CMP: ${e.localizedMessage}", null)
        }
    }

    private fun getAllVendors(result: Result) {
        try {
            val vendors = consentManager?.getAllVendorsList()
            result.success(vendors)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get all vendors: ${e.localizedMessage}", null)
        }
    }

    private fun getAllPurposes(result: Result) {
        try {
            val purposes = consentManager?.getAllPurposeList()
            result.success(purposes)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get all purposes: ${e.localizedMessage}", null)
        }
    }

    private fun hasConsent(result: Result) {
        try {
            val hasConsent = consentManager?.hasConsent() ?: false
            result.success(hasConsent)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check general consent: ${e.localizedMessage}", null)
        }
    }

    private fun getEnabledPurposes(result: Result) {
        try {
            val enabledPurposes = consentManager?.getEnabledPurposeList()
            result.success(enabledPurposes)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get enabled purposes: ${e.localizedMessage}", null)
        }
    }

    private fun getEnabledVendors(result: Result) {
        try {
            val enabledVendors = consentManager?.getEnabledVendorList()
            result.success(enabledVendors)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get enabled vendors: ${e.localizedMessage}", null)
        }
    }

    private fun getDisabledPurposes(result: Result) {
        try {
            val disabledPurposes = consentManager?.getDisabledPurposes()
            result.success(disabledPurposes)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get disabled purposes: ${e.localizedMessage}", null)
        }
    }

    private fun getDisabledVendors(result: Result) {
        try {
            val disabledVendors = consentManager?.getDisabledVendors()
            result.success(disabledVendors)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get disabled vendors: ${e.localizedMessage}", null)
        }
    }

    private fun getUSPrivacyString(result: Result) {
        try {
            val usPrivacyString = consentManager?.getUSPrivacyString() ?: ""
            result.success(usPrivacyString)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get US privacy string: ${e.localizedMessage}", null)
        }
    }

    private fun getGoogleACString(result: Result) {
        try {
            val googleACString = consentManager?.getGoogleACString() ?: ""
            result.success(googleACString)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get Google AC string: ${e.localizedMessage}", null)
        }
    }

    private fun consentRequestedToday(result: Result) {
        val consentRequestedToday = consentManager?.consentRequestedToday()
        result.success(consentRequestedToday)
    }

    private fun configureScreen(screenConfig: ScreenConfig) {
        when (screenConfig) {
            ScreenConfig.FULLSCREEN -> CmpUIConfig.configureFullScreen()
            ScreenConfig.HALFSCREEN_BOTTOM -> CmpUIConfig.configureHalfScreenBottom(activityContext!!)
            ScreenConfig.HALFSCREEN_TOP -> CmpUIConfig.configureHalfScreenTop(activityContext!!)
            ScreenConfig.CENTERSCREEN -> CmpUIConfig.configureCenterScreen(activityContext!!)
            ScreenConfig.SMALL_CENTERSCREEN -> CmpUIConfig.configureSmallCenterScreen(
                activityContext!!
            )

            ScreenConfig.LARGE_TOPSCREEN -> CmpUIConfig.configureLargeTopScreen(activityContext!!)
            ScreenConfig.LARGE_BOTTOMSCREEN -> CmpUIConfig.configureLargeBottomScreen(
                activityContext!!
            )
        }
    }

    private fun configureConsentLayer(call: MethodCall, result: Result) {
        val screenConfigString = call.argument<String>("screenConfig")

        if (screenConfigString == null) {
            result.error("INVALID_ARGUMENTS", "screenConfig is required as a String", null)
            return
        }

        // Map the screenConfig string to the ScreenConfig enum
        val screenConfig = mapScreenConfig(screenConfigString)
        val consentManager = this.consentManager // Assuming this is already initialized

        if (screenConfig == null || consentManager == null) {
            result.error("INVALID_ARGUMENTS", "Invalid or missing screenConfig", null)
            return
        }

        configureScreen(screenConfig)

        result.success(null) // Indicate success
    }


    // Function to import a CMP string
    private fun importCmpString(call: MethodCall, result: Result) {
        val cmpString = call.argument<String>("cmpString")
        if (cmpString == null) {
            result.error("INVALID_ARGUMENTS", "CMP string is required", null)
        } else {
            consentManager?.importCmpString(cmpString) { success, message ->
                if (success) {
                    result.success(true)
                } else {
                    result.error("IMPORT_FAILED", message, null)
                }
            }
        }
    }

    // Function to check if consent is required
    private fun check(call: MethodCall, result: Result) {
        val isCached = call.argument<Boolean>("isCached") ?: false
        consentManager?.checkConsentIsRequired(
            { isRequired -> result.success(isRequired) },
            isCached
        )
    }

    private fun rejectAll(result: Result) {
        consentManager?.rejectAll { result.success(null) }
    }

    private fun acceptAll(result: Result) {
        consentManager?.acceptAll { result.success(null) }
    }

    private fun enablePurposes(call: MethodCall, result: Result) {
        val purposes = call.argument<List<String>>("purposes")
        val updateVendors = call.argument<Boolean>("updateVendors") ?: true
        if (purposes == null) {
            result.error("INVALID_ARGUMENTS", "Purposes not provided", null)
            return
        }

        consentManager?.enablePurposeList(purposes, updateVendors) {
            result.success(null) // Notify Flutter that the operation completed
        }
    }

    private fun disablePurposes(call: MethodCall, result: Result) {
        val purposes = call.argument<List<String>>("purposes")
        val updateVendors = call.argument<Boolean>("updateVendors") ?: true
        if (purposes == null) {
            result.error("INVALID_ARGUMENTS", "Purposes not provided", null)
            return
        }

        consentManager?.disablePurposeList(purposes, updateVendors) {
            result.success(null) // Notify Flutter that the operation completed
        }
    }

    private fun enableVendors(call: MethodCall, result: Result) {
        val vendors = call.argument<List<String>>("vendors")
        if (vendors == null) {
            result.error("INVALID_ARGUMENTS", "Vendors not provided", null)
            return
        }

        consentManager?.enableVendorList(vendors) {
            result.success(null) // Notify Flutter that the operation completed
        }
    }

    private fun disableVendors(call: MethodCall, result: Result) {
        val vendors = call.argument<List<String>>("vendors")
        if (vendors == null) {
            result.error("INVALID_ARGUMENTS", "Vendors not provided", null)
            return
        }

        consentManager?.disableVendorList(vendors) {
            result.success(null) // Notify Flutter that the operation completed
        }
    }

}

enum class ScreenConfig {
    FULLSCREEN,
    HALFSCREEN_BOTTOM,
    HALFSCREEN_TOP,
    CENTERSCREEN,
    SMALL_CENTERSCREEN,
    LARGE_TOPSCREEN,
    LARGE_BOTTOMSCREEN
}

private fun mapAndroidPresentationStyleToCmpUIStrategy(styleString: String): CmpUIStrategy {
    return when (styleString?.lowercase(Locale.ROOT)) {
        "popup" -> CmpUIStrategy.POPUP
        "dialog" -> CmpUIStrategy.DIALOG
        "activity" -> CmpUIStrategy.ACTIVITY
        else -> CmpUIStrategy.POPUP // Default strategy, you can change it as needed
    }
}

private fun mapScreenConfig(screenConfigString: String): ScreenConfig? {
    return when (screenConfigString) {
        "fullScreen" -> ScreenConfig.FULLSCREEN
        "halfScreenBottom" -> ScreenConfig.HALFSCREEN_BOTTOM
        "halfScreenTop" -> ScreenConfig.HALFSCREEN_TOP
        "centerScreen" -> ScreenConfig.CENTERSCREEN
        "smallCenterScreen" -> ScreenConfig.SMALL_CENTERSCREEN
        "largeTopScreen" -> ScreenConfig.LARGE_TOPSCREEN
        "largeBottomScreen" -> ScreenConfig.LARGE_BOTTOMSCREEN
        else -> null // Handle invalid or missing values
    }
}
