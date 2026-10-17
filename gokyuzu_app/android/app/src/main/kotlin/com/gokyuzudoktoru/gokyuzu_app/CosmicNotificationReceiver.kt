package com.gokyuzudoktoru.gokyuzu_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.gokyuzudoktoru.gokyuzu_app.R

class CosmicNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "Gökyüzü Doktoru 🌌"
        val body = intent.getStringExtra("body") ?: "Günün kozmik enerjileri ve gezegen geçişleri haritanızda güncellendi."
        val id = intent.getIntExtra("id", 101)

        showNotification(context, id, title, body)
    }

    companion object {
        const val CHANNEL_ID = "gokyuzu_cosmic_channel"

        fun showNotification(context: Context, id: Int, title: String, body: String) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Günlük Kozmik Bildirimler",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Gün boyu gezegen geçişleri, Ay fazı ve burç enerjisi bildirimleri"
                    enableVibration(true)
                }
                manager.createNotificationChannel(channel)
            }

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, id, launchIntent, pendingFlags)

            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .build()

            try {
                manager.notify(id, notification)
            } catch (e: SecurityException) {
            }
        }
    }
}
