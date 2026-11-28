package com.example.sajilyatra.sajilyatra

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import android.view.KeyEvent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth (fingerprint / Face ID) needs a FragmentActivity.
// The panic alert also needs two things Dart cannot do alone: hear the volume
// buttons while the app is open, and send an SMS without opening any screen.
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var pendingPermission: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sajilyatra/panic")
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasSmsPermission" -> result.success(hasSmsPermission())
                "requestSmsPermission" -> {
                    if (hasSmsPermission()) {
                        result.success(true)
                    } else {
                        pendingPermission = result
                        ActivityCompat.requestPermissions(
                            this, arrayOf(Manifest.permission.SEND_SMS), SMS_REQUEST
                        )
                    }
                }
                "sendSms" -> result.success(sendSms(call.argument("numbers"), call.argument("body")))
                else -> result.notImplemented()
            }
        }
    }

    private fun hasSmsPermission() =
        ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) ==
            PackageManager.PERMISSION_GRANTED

    private fun sendSms(numbers: List<String>?, body: String?): Boolean {
        if (numbers == null || body == null || !hasSmsPermission()) return false
        return try {
            @Suppress("DEPRECATION")
            val sms = if (Build.VERSION.SDK_INT >= 31) {
                getSystemService(SmsManager::class.java)
            } else {
                SmsManager.getDefault()
            }
            val parts = sms.divideMessage(body)
            for (number in numbers) {
                sms.sendMultipartTextMessage(number, null, parts, null, null)
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_REQUEST) {
            pendingPermission?.success(
                grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            )
            pendingPermission = null
        }
    }

    // Tell Dart about each volume-button press (the volume still changes as usual).
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if ((keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) &&
            event?.repeatCount == 0
        ) {
            channel?.invokeMethod("volumeKey", null)
        }
        return super.onKeyDown(keyCode, event)
    }

    companion object {
        private const val SMS_REQUEST = 1001
    }
}
