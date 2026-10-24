package com.gokyuzudoktoru.gokyuzu_app

import android.accounts.AccountManager
import android.app.Activity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gokyuzudoktoru.gokyuzu_app/google_auth"
    private val REQUEST_CODE_PICK_ACCOUNT = 9001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickGoogleAccount" -> {
                    if (pendingResult != null) {
                        result.error("ALREADY_ACTIVE", "Google hesap seçici zaten açık.", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            AccountManager.newChooseAccountIntent(
                                null,
                                null,
                                arrayOf("com.google"),
                                null,
                                null,
                                null,
                                null
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            AccountManager.newChooseAccountIntent(
                                null,
                                null,
                                arrayOf("com.google"),
                                false,
                                null,
                                null,
                                null,
                                null
                            )
                        }
                        pendingResult = result
                        startActivityForResult(intent, REQUEST_CODE_PICK_ACCOUNT)
                    } catch (e: Exception) {
                        pendingResult = null
                        result.error("INTENT_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_PICK_ACCOUNT) {
            val res = pendingResult
            pendingResult = null
            if (res != null) {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val accountName = data.getStringExtra(AccountManager.KEY_ACCOUNT_NAME)
                    val accountType = data.getStringExtra(AccountManager.KEY_ACCOUNT_TYPE)
                    if (!accountName.isNullOrBlank()) {
                        res.success(
                            mapOf(
                                "email" to accountName,
                                "accountType" to (accountType ?: "com.google")
                            )
                        )
                    } else {
                        res.success(null)
                    }
                } else {
                    res.success(null)
                }
            }
        }
    }
}
