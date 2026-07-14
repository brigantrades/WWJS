package com.wwjs.wwjs

import android.content.Intent
import android.util.Log
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val appUpdateChannelName = "wwjs/app_update"
private const val updateRequestCode = 8617
private const val appUpdateLogTag = "WWJSAppUpdate"

class MainActivity : FlutterActivity() {
    private lateinit var appUpdateManager: AppUpdateManager
    private var installStateListener: InstallStateUpdatedListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        appUpdateManager = AppUpdateManagerFactory.create(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appUpdateChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkForUpdate" -> checkForPlayUpdate(result)
                "startUpdate" -> startPlayUpdate(
                    call.argument<String>("type"),
                    result,
                )
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (!::appUpdateManager.isInitialized) return
        appUpdateManager.appUpdateInfo.addOnSuccessListener { info ->
            if (info.installStatus() == InstallStatus.DOWNLOADED) {
                appUpdateManager.completeUpdate()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == updateRequestCode && resultCode != RESULT_OK) {
            unregisterInstallStateListener()
        }
    }

    override fun onDestroy() {
        unregisterInstallStateListener()
        super.onDestroy()
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

    private fun startPlayUpdate(requestedType: String?, result: MethodChannel.Result) {
        appUpdateManager.appUpdateInfo
            .addOnSuccessListener { info ->
                val updateType = chooseUpdateType(info, requestedType)
                if (updateType == null) {
                    result.success(mapOf("started" to false))
                    return@addOnSuccessListener
                }

                if (updateType == AppUpdateType.FLEXIBLE) {
                    registerInstallStateListener()
                }

                try {
                    val options = AppUpdateOptions.newBuilder(updateType).build()
                    val started = appUpdateManager.startUpdateFlowForResult(
                            info,
                            this,
                            options,
                            updateRequestCode,
                        )
                    result.success(mapOf("started" to started))
                } catch (_: Exception) {
                    result.success(mapOf("started" to false))
                }
            }
            .addOnFailureListener { result.success(mapOf("started" to false)) }
    }

    private fun updateInfoPayload(info: AppUpdateInfo): Map<String, Any> {
        val installStatus = info.installStatus()
        val flexibleAllowed = info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)
        val immediateAllowed = info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
        val available =
            info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                (flexibleAllowed || immediateAllowed)

        return mapOf(
            "updateAvailable" to available,
            "availableVersionCode" to info.availableVersionCode(),
            "updateAvailability" to info.updateAvailability(),
            "installStatus" to installStatus,
            "updatePriority" to info.updatePriority(),
            "flexibleAllowed" to flexibleAllowed,
            "immediateAllowed" to immediateAllowed,
            "recommendedType" to when {
                flexibleAllowed -> "flexible"
                immediateAllowed -> "immediate"
                else -> "none"
            },
        )
    }

    private fun chooseUpdateType(info: AppUpdateInfo, requestedType: String?): Int? {
        if (info.updateAvailability() != UpdateAvailability.UPDATE_AVAILABLE) return null

        val preferred =
            if (requestedType == "immediate") AppUpdateType.IMMEDIATE
            else AppUpdateType.FLEXIBLE
        if (info.isUpdateTypeAllowed(preferred)) return preferred

        val fallback =
            if (preferred == AppUpdateType.FLEXIBLE) AppUpdateType.IMMEDIATE
            else AppUpdateType.FLEXIBLE
        return if (info.isUpdateTypeAllowed(fallback)) fallback else null
    }

    private fun registerInstallStateListener() {
        if (installStateListener != null) return
        val listener = InstallStateUpdatedListener { state ->
            if (state.installStatus() == InstallStatus.DOWNLOADED) {
                appUpdateManager.completeUpdate()
            }
        }
        installStateListener = listener
        appUpdateManager.registerListener(listener)
    }

    private fun unregisterInstallStateListener() {
        val listener = installStateListener ?: return
        if (::appUpdateManager.isInitialized) {
            appUpdateManager.unregisterListener(listener)
        }
        installStateListener = null
    }

    private fun noUpdate(error: String? = null): Map<String, Any> {
        val payload = mutableMapOf<String, Any>(
            "updateAvailable" to false,
            "recommendedType" to "none",
        )
        if (!error.isNullOrBlank()) payload["error"] = error
        return payload
    }
}
