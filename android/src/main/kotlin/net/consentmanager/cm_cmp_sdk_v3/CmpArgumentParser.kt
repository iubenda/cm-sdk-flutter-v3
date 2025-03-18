package net.consentmanager.cm_cmp_sdk_v3
import android.graphics.Color
import net.consentmanager.cm_sdk_android_v3.ConsentLayerUIConfig
import net.consentmanager.cm_sdk_android_v3.UrlConfig

class CmpArgumentParser {
    companion object {

        fun parseConsentLayerUIConfig(args: Map<String, Any>): ConsentLayerUIConfig {
            val position = parsePosition(args["position"] as? String)
            val backgroundStyle = parseBackgroundStyle(args)
            val cornerRadius = (args["cornerRadius"] as? Double)?.toFloat() ?: 0f
            val respectsSafeArea = args["respectsSafeArea"] as? Boolean ?: true
            val allowsOrientationChanges = args["allowsOrientationChanges"] as? Boolean ?: true

            return ConsentLayerUIConfig(
                position = position,
                backgroundStyle = backgroundStyle,
                cornerRadius = cornerRadius,
                respectsSafeArea = respectsSafeArea,
                allowsOrientationChanges = allowsOrientationChanges
            )
        }

        fun parseUrlConfig(args: Map<String, Any>): UrlConfig {
            val id = args["id"] as String
            val domain = args["domain"] as String
            val language = args["language"] as String
            val appName = args["appName"] as String

            return UrlConfig(id = id, domain = domain, language = language, appName = appName)
        }

        private fun parsePosition(positionString: String?): ConsentLayerUIConfig.Position {
            return when (positionString) {
                "halfScreenTop" -> ConsentLayerUIConfig.Position.HALF_SCREEN_TOP
                "halfScreenBottom" -> ConsentLayerUIConfig.Position.HALF_SCREEN_BOTTOM
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
