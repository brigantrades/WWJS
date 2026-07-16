package com.wwjs.wwjs

import android.util.Log
import com.ryanheise.audioservice.AudioServiceActivity
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val appUpdateChannelName = "wwjs/app_update"
private const val appUpdateLogTag = "WWJSAppUpdate"

class MainActivity : AudioServiceActivity() {
    private lateinit var appUpdateManager: AppUpdateManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        appUpdateManager = AppUpdateManagerFactory.create(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appUpdateChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkForUpdate" -> checkForPlayUpdate(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun checkForPlayUpdate(result: MethodChannel.Result) {
        if (!::appUpdateManager.isInitialized) {
            result.success(noUpdate("AppUpdateManager is not initialized"))
            return
        }

        appUpdateManager.appUpdateInfo
            .addOnSuccessListener { info -> result.success(updateInfoPayload(info)) }
            .addOnFailureListener { error ->
                Log.w(appUpdateLogTag, "Google Play update lookup failed", error)
                result.success(noUpdate(error.message))
            }
    }

    private fun updateInfoPayload(info: AppUpdateInfo): Map<String, Any> {
        val available = info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE

        return mapOf(
            "updateAvailable" to available,
            "availableVersionCode" to info.availableVersionCode(),
            "updateAvailability" to info.updateAvailability(),
            "installStatus" to info.installStatus(),
            "updatePriority" to info.updatePriority(),
        )
    }

    private fun noUpdate(error: String? = null): Map<String, Any> {
        val payload = mutableMapOf<String, Any>(
            "updateAvailable" to false,
        )
        if (!error.isNullOrBlank()) payload["error"] = error
        return payload
    }
}
