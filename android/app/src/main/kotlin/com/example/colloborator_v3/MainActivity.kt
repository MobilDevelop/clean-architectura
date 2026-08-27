package com.example.app_setting

import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "colloborator_v3/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> result.success(
                        mapOf(
                            "uniqueId" to getUniqueId(),
                            "name" to getDeviceName(),
                            "brand" to Build.BRAND,
                            "osVersion" to getOsVersion(),
                        )
                    )

                    else -> result.notImplemented()
                }
            }
    }

    private fun getUniqueId(): String =
        Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: ""

    private fun getDeviceName(): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            val name = Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME)
            if (!name.isNullOrBlank()) return name
        }
        return Build.MODEL
    }

    private fun getOsVersion(): String = "Android ${Build.VERSION.RELEASE}"
}
