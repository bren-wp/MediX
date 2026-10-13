package com.brendigo.medix

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val navigationChannel = "com.brendigo.medix/navigation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            navigationChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNearbyPharmacies" -> result.success(openNearbyPharmacies())
                "openExternalUrl" -> {
                    val url = call.argument<String>("url")
                    result.success(url != null && openExternalUrl(url))
                }
                "shareFile" -> {
                    val path = call.argument<String>("path")
                    result.success(path != null && shareExportZip(path))
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
        }

        return openExternalUrl(
            "https://www.google.com/maps/search/ljekarna",
        )
    }

    private fun openExternalUrl(value: String): Boolean {
        val uri = try {
            Uri.parse(value)
        } catch (_: Exception) {
            return false
        }
        if (uri.scheme != "https" && uri.scheme != "http") return false

        return try {
            startActivity(Intent(Intent.ACTION_VIEW, uri))
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }

    private fun shareExportZip(path: String): Boolean {
        val exportDirectory = File(cacheDir, "medix-exports").canonicalFile
        val file = File(path).canonicalFile
        if (!file.isFile ||
            !file.name.startsWith("MediX-export-") ||
            !file.name.endsWith(".zip") ||
            file.parentFile != exportDirectory
        ) {
            return false
        }

        val uri = try {
            FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.files",
                file,
            )
        } catch (_: IllegalArgumentException) {
            return false
        }

        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "application/zip"
            putExtra(Intent.EXTRA_STREAM, uri)
            clipData = ClipData.newRawUri("MediX export", uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        return try {
            startActivity(Intent.createChooser(shareIntent, "Share MediX export"))
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }
}
