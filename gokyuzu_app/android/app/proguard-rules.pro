# ==============================================================================
# Gökyüzü Doktoru — Tersine Mühendislik & Siber Güvenlik ProGuard/R8 Kuralları
# ==============================================================================

# Flutter Motoru ve Temel Eklentiler
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Bildirim Motoru (flutter_local_notifications)
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Google Play Billing (In-App Purchase)
-keep class com.android.billingclient.** { *; }
-keep class com.android.vending.billing.** { *; }

# Core Desugaring
-dontwarn java.time.**

# ==============================================================================
# Siber Güvenlik, Kod Karartma (Obfuscation) & Hata Ayıklama Bilgisi Temizleme
# ==============================================================================

# Log ve Debug çıktılarını ikili dosyadan tamamen sil (Tersine mühendislikte log analizi yapılamaz)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# Paket hiyerarşisini gizle ve tüm sınıfları şifreli tek bir gizli pakete topla
-repackageclasses 'com.gokyuzudoktoru.sec'
-allowaccessmodification

# Kaynak dosya isimlerini ve satır numaralarını gizle
-renamesourcefileattribute ''
-keepattributes !SourceFile,!LineNumberTable
