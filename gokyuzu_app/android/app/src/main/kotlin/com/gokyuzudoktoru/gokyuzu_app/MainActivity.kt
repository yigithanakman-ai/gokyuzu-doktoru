package com.gokyuzudoktoru.gokyuzu_app

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gokyuzudoktoru.gokyuzu_app/notifications"
    private var permissionResultCallback: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val granted = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED
                        if (granted) {
                            result.success(true)
                        } else {
                            permissionResultCallback = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                1001
                            )
                        }
                    } else {
                        val enabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
                        result.success(enabled)
                    }
                }
                "areNotificationsEnabled" -> {
                    val enabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
                    result.success(enabled)
                }
                "showInstantNotification" -> {
                    val id = call.argument<Int>("id") ?: 999
                    val title = call.argument<String>("title") ?: "Gökyüzü Doktoru 🌌"
                    val body = call.argument<String>("body") ?: "Günlük kozmik bildirimleriniz aktif edildi."
                    CosmicNotificationReceiver.showNotification(this, id, title, body)
                    result.success(true)
                }
                "scheduleDailyNotifications" -> {
                    val items = call.argument<List<Map<String, Any>>>("items") ?: emptyList()
                    scheduleAlarms(items)
                    result.success(true)
                }
                "cancelAllNotifications" -> {
                    cancelAlarms()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResultCallback?.success(granted)
            permissionResultCallback = null
        }
    }

    private fun scheduleAlarms(items: List<Map<String, Any>>) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (item in items) {
            val id = (item["id"] as? Number)?.toInt() ?: 101
            val hour = (item["hour"] as? Number)?.toInt() ?: 9
            val minute = (item["minute"] as? Number)?.toInt() ?: 30
            val title = item["title"] as? String ?: "Gökyüzü Doktoru 🌌"
            val body = item["body"] as? String ?: "Günün kozmik enerjilerini inceleyin."

            val intent = Intent(this, CosmicNotificationReceiver::class.java).apply {
                putExtra("id", id)
                putExtra("title", title)
                putExtra("body", body)
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getBroadcast(this, id, intent, flags)

            val calendar = Calendar.getInstance().apply {
                timeInMillis = System.currentTimeMillis()
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                if (timeInMillis <= System.currentTimeMillis()) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }

            alarmManager.setInexactRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                AlarmManager.INTERVAL_DAY,
                pendingIntent
            )
        }
    }

    private fun cancelAlarms() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        for (id in listOf(101, 102, 103)) {
            val intent = Intent(this, CosmicNotificationReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(this, id, intent, flags)
            alarmManager.cancel(pendingIntent)
        }
    }
}
