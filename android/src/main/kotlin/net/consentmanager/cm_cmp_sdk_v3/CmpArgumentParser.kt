package net.consentmanager.cm_cmp_sdk_v3
import android.app.Activity
import android.graphics.Color
import net.consentmanager.cm_sdk_android_v3.ConsentLayerUIConfig
import net.consentmanager.cm_sdk_android_v3.UrlConfig

class CmpArgumentParser {
    companion object {

        fun parseConsentLayerUIConfig(args: Map<String, Any>, activity: Activity? = null): ConsentLayerUIConfig {
            val position = parsePosition(args["position"] as? String, args, activity)
            val backgroundStyle = parseBackgroundStyle(args)
            val cornerRadius = (args["cornerRadius"] as? Number)?.toFloat() ?: 0f
            val respectsSafeArea = args["respectsSafeArea"] as? Boolean ?: true
            val allowsOrientationChanges = args["allowsOrientationChanges"] as? Boolean ?: true
            val darkMode = args["darkMode"] as? Boolean ?: false
            val isCancelable = args["isCancelable"] as? Boolean ?: true
            val navigationBarColor = args["navigationBarColor"] as? Int

            return ConsentLayerUIConfig(
                position = position,
                backgroundStyle = backgroundStyle,
                cornerRadius = cornerRadius,
                respectsSafeArea = respectsSafeArea,
                isCancelable = isCancelable,
                allowsOrientationChanges = allowsOrientationChanges,
                darkMode = darkMode,
                navigationBarColor = navigationBarColor
            )
        }

        fun parseUrlConfig(args: Map<String, Any>): UrlConfig {
            val id = args["id"] as String
            val domain = args["domain"] as String
            val language = args["language"] as String
            val appName = args["appName"] as String
            val noHash = args["noHash"] as? Boolean ?: false

            return UrlConfig(id = id, domain = domain, language = language, appName = appName, jsonConfig = "{}", noHash = noHash)
        }

        private fun parsePosition(positionString: String?, args: Map<String, Any>, activity: Activity?): ConsentLayerUIConfig.Position {
            return when (positionString) {
                "halfScreenTop" -> ConsentLayerUIConfig.Position.HALF_SCREEN_TOP
                "halfScreenBottom" -> ConsentLayerUIConfig.Position.HALF_SCREEN_BOTTOM
                "custom" -> {
                    val density = activity?.resources?.displayMetrics?.density ?: 1f
                    val rect = (args["customPosition"] as? Map<*, *>)?.let {
                        val width = ((it["width"] as? Number)?.toFloat() ?: 0f) * density
                        val height = ((it["height"] as? Number)?.toFloat() ?: 0f) * density
                        val gravityString = it["gravity"] as? String ?: "center"
                        val gravity = when (gravityString) {
                            "top" -> android.view.Gravity.TOP
                            "bottom" -> android.view.Gravity.BOTTOM
                            else -> android.view.Gravity.CENTER
                        }
                        Triple(width.toInt(), height.toInt(), gravity)
                    }
                    ConsentLayerUIConfig.Position.custom(
                        width = rect?.first ?: 0,
                        height = rect?.second ?: 0,
                        gravity = rect?.third ?: android.view.Gravity.CENTER
                    )
                }
                "fullScreen" -> ConsentLayerUIConfig.Position.FULL_SCREEN
                else -> ConsentLayerUIConfig.Position.FULL_SCREEN
            }
        }

        private fun parseBackgroundStyle(args: Map<String, Any>): ConsentLayerUIConfig.BackgroundStyle {
            val backgroundStyleString = args["backgroundStyle"] as? String ?: "dimmed"
            return when (backgroundStyleString) {
                "color" -> {
                    val colorValue = args["backgroundColor"] as? Int ?: Color.BLACK
                    ConsentLayerUIConfig.BackgroundStyle.solid(colorValue)
                }
                "none" -> ConsentLayerUIConfig.BackgroundStyle.none()
                else -> {
                    val colorValue = args["backgroundColor"] as? Int ?: Color.BLACK
                    val opacity = (args["backgroundOpacity"] as? Double)?.toFloat() ?: 0.5f
                    ConsentLayerUIConfig.BackgroundStyle.dimmed(colorValue, opacity)
                }
            }
        }
    }
}
