# 🪐 Gökyüzü Doktoru — Proje Durumu, Yapılanlar ve Yol Haritası (Master El Kitabı)

> **Bu Belgenin Amacı:** Bu dosya, Gökyüzü Doktoru mobil uygulamasının geliştirme, derleme, mağaza varlıkları, reklam entegrasyonu, yasal formları, astrolojik hesaplama motorları ve Google Play Console yayın süreçlerinin **eksiksiz durum kaydıdır**. Yeni bir yapay zeka oturumu veya geliştirici bu dosyayı okuduğunda, projenin geçmişini, anlık durumunu ve sırada yapılması gerekenleri adım adım anlayacaktır.

---

## 📌 1. Temel Proje ve Kimlik Bilgileri

* **Uygulama Adı:** Gökyüzü Doktoru (Sky Doctor)
* **Paket Kimliği (Package Name / Application ID):** `com.gokyuzudoktoru.gokyuzu_app`
* **Geliştirici Hesabı:** Yiğithan Akman (Google Play Console Bireysel Geliştirici)
* **Hitap Kuralı:** Yiğithan Akman'a sistemde **"Patron" 👑** olarak hitap edilir.
* **Teknoloji:** Flutter & Dart (Cross-platform: Android, iOS, iPad, macOS, Web)
* **GitHub Repository:** [https://github.com/yigithanakman-ai/gokyuzu-doktoru](https://github.com/yigithanakman-ai/gokyuzu-doktoru)
* **Aktif Git Dalı (Branch):** `main`
* **Mevcut Sürüm:** `1.0.4+5` (VersionName: `1.0.4`, VersionCode: `5`)
* **Google Play Durumu:** Kapalı Testte İncelemede (`5 (1.0.4)`)
* **Resmi İletişim / Destek E-postası:** `yigithanakman@gokyuzudoktoru.com`
* **Resmi Yasal Merkez (GitHub Pages):** `https://yigithanakman-ai.github.io/gokyuzu-doktoru/`

---

## 🚀 2. v1.0.4 Sürümünde Canlıya Alınan Yeni Yetenekler

1. **Cihaz Üzerinde Matematiksel Gezegen Frekansları (`frequency_synth_service.dart`):**  
   Sıfır bulut depolama maliyeti, sıfır internet kotasıyla cihazın ses işlemcisinde 44.1kHz 16-bit PCM Stereo sinüs dalgası üreten on-device ses motoru.
2. **Kozmik Karar Pusulası (`cosmic_compass_service.dart`):**  
   Günde maksimum 1 reklam izleme sınırı ve tıbbi/hukuki konularda sorumluluk reddi yasal güvencesi.
3. **Arkadaşını Davet Et Tek Kullanımlık Kupon Zırhı (`referral_service.dart`):**  
   Kriptografik tek kullanımlık kuponlar (`GOK-XXXX-XXXX`), tükenen kodlar kalıcı kara defteri ve kaba kuvvet kilit sistemi.
4. **Güneş Dönüşü Doğum Günü Kutlama Kartı (`birthday_solar_return_modal.dart`):**  
   Tam doğum gününde açılan kutlama modalı ve 9:16 Instagram/WhatsApp paylaşım kartı.
5. **Kozmik Sezon & Bayram Temaları (`cosmic_theme_service.dart`):**  
   Cadılar Bayramı, Yılbaşı, Sevgililer Günü ve Ekinoks dönemlerinde otomatik devreye giren tema ve gezegen kostüm sistemi.
6. **Gezegen Saatleri & Günleri (`planetary_hours_service.dart`):**  
   Keldani sırasına göre yerel güneş hareketleriyle hesaplanan kozmik zamanlayıcı.

---

## 👑 3. Patron'un Küresel Vizyonu: "Modern Solar Fire & Astro Gold Katili"

Patron'un vizyonu: Gökyüzü Doktoru'nu **Solar Fire, Astro Gold ve Sirius** gibi 90'lardan kalma pahalı masaüstü yazılımların küresel çaptaki en güçlü, modern, yapay zekâ destekli ve estetik alternatifi haline getirmektir.

### Tamamlanan Yeni Yetenekler (18 Ekim 2026):
* **VIP Platinum Çoklu Profil Seçici (`active_profile_service.dart`, `ActiveProfileBar`):**  
  Arşivdeki kayıtlı haritalardan (çocuk, eş, danışan) birine tek tıkla geçiş yapıldığında; tüm uygulamanın (Solar Return, Secondary Progress, Numeroloji, Anlık Transitler ve 10 Sayfalık PDF Kitapçığı) seçilen kişi adına hesaplanması tamamlandı.
* **Gizli Kod Güvenliği & Teşvik:**  
  Müşteri yükseltme arayüzünden (`platinum_multiprofile_upsell_sheet.dart`) tüm promosyon kodu/gizli kod giriş alanları silindi; master erişim kodu (`gkyz2453`) yalnızca Patron ve Yapay Zekâ sırrı olarak korundu. Sayfada **"+1 Ekstra Kapsamlı PDF Raporu Hediye!"** teşvik teklifi bırakıldı.
* **360° Çark Sayfasına Gömülü İnteraktif Çift Çark & Zaman Makinesi (`chart_detail_screen.dart`):**  
  Doğum haritası detay ekranındaki 360° Çark sekmesine çift çark doğrudan gömüldü. Segmented switch (`[🪐 Tekli Doğum Çarkı]` / `[🔭 Canlı Çift Çark]`), Solar Fire zaman makinesi butonları (`-1 Ay`, `-1 G`, `-1 S`, `ŞİMDİ`, `+1 S`, `+1 G`, `+1 Ay`), parmakla 360° serbest döndürme, gezegen açı ışını odaklama filtreleri ve canlı transit açı akışı entegre edildi.
* **Atlas & Astrokartografi Notu:**  
  Astrokartografi özelliği, 200+ ülke koordinat (Geocoding) ve tarihsel saat dilimi (DST) altyapısı için Patron'un onayıyla Seçenek 2 & 3 (Cihaz içi gömülü atlas + OpenStreetMap/Photon, sıfır ücretli API) olarak planlandı.

---

## 🔐 4. Dijital İmza (Upload Keystore) Bilgileri

* **Keystore Konumu:** `gokyuzu_app/android/app/upload-keystore.jks`
* **Key Properties:** `gokyuzu_app/android/key.properties`
* **Key Alias:** `upload`
* **Store & Key Password:** `GokyuzuDoktoru2026!UploadKey`
* **Android Gradle Versiyonu:** Gradle 8.11.1, Kotlin Gradle Plugin 2.2.20, AGP 8.9.1, Java 17, `targetSdk = 36`.

---

## 📜 5. Yasal Belgeler ve Mağaza Uyumluluğu

* **Resmi Yasal Merkez:** `https://yigithanakman-ai.github.io/gokyuzu-doktoru/` (GitHub Pages üzerinde `docs/index.html` olarak barındırılmaktadır).
* **Gizlilik Politikası:** Canlı yayın anonsları, atölye bildirimleri ve yasal sorumluluk reddi metinleriyle günceldir.
* **Statik Kod Analizi:** `dart analyze lib/` çıktısı: **0 Hata (No issues found)**.

