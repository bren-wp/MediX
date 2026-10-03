package com.brendigo.medix

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val navigationChannel = "com.brendigo.medix/navigation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            navigationChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNearbyPharmacies" -> {
                    result.success(openNearbyPharmacies())
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun openNearbyPharmacies(): Boolean {
        val geoIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("geo:0,0?q=ljekarna"),
        )

        try {
            startActivity(geoIntent)
            return true
        } catch (_: ActivityNotFoundException) {
            // Fall through to a regular HTTPS maps search.
        }

        val webIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("https://www.google.com/maps/search/ljekarna"),
        )

        return try {
            startActivity(webIntent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }
}
