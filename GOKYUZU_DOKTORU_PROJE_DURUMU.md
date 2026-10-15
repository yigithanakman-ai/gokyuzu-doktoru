# 🪐 Gökyüzü Doktoru — Proje Durumu, Yapılanlar ve Yol Haritası (Master El Kitabı)

> **Bu Belgenin Amacı:** Bu dosya, Gökyüzü Doktoru mobil uygulamasının geliştirme, derleme, mağaza varlıkları, reklam entegrasyonu, yasal formları ve Google Play Console yayın süreçlerinin **eksiksiz durum kaydıdır**. Yeni bir yapay zeka oturumu veya geliştirici bu dosyayı okuduğunda, projenin geçmişini, anlık durumunu ve sırada yapılması gerekenleri adım adım anlayacaktır.

---

## 📌 1. Temel Proje ve Kimlik Bilgileri

* **Uygulama Adı:** Gökyüzü Doktoru
* **Paket Kimliği (Package Name / Application ID):** `com.gokyuzudoktoru.gokyuzu_app`
* **Geliştirici Hesabı:** Yiğithan Akman (Google Play Console Bireysel Geliştirici)
* **Teknoloji:** Flutter & Dart (Cross-platform)
* **GitHub Repository:** [https://github.com/yigithanakman-ai/gokyuzu-doktoru](https://github.com/yigithanakman-ai/gokyuzu-doktoru)
* **Aktif Git Dalı (Branch):** `main`
* **Son Canlıya Alınan Sürüm:** `1.0.2` (Sürüm Kodu / VersionCode: `3`)
* **Resmi İletişim / Destek E-postası:** `yigithanakman@gokyuzudoktoru.com`
* **Resmi Web Sitesi:** `https://gokyuzudoktoru.com`

---

## 🔐 2. Dijital İmza (Upload Keystore) Bilgileri

Google Play Store'a `.aab` (Android App Bundle) yükleyebilmek için resmi upload anahtarı oluşturulmuş ve CI/CD hattına bağlanmıştır:

* **Keystore Konumu:** `gokyuzu_app/android/app/upload-keystore.jks`
* **Key Properties:** `gokyuzu_app/android/key.properties`
* **Key Alias:** `upload`
* **Store & Key Password:** `GokyuzuDoktoru2026!UploadKey`
* **Otomasyon:** GitHub Actions (`.github/workflows/build_apk.yml`), her `git push origin main` yapıldığında bu keystore'u otomatik decode eder ve resmi olarak imzalı `.apk` ile `.aab` paketlerini derleyip GitHub Releases üzerinde yayınlar.

---

## 💰 3. Google AdMob & Reklam Kimliği (AD_ID) Entegrasyonu

* **AdMob Resmi Uygulama Kimliği (App ID):** `ca-app-pub-1133172251227471~4078534665`
* **Manifest Ayarı (`AndroidManifest.xml`):**
  * `com.google.android.gms.ads.APPLICATION_ID` tanımlandı.
  * `com.google.android.gms.permission.AD_ID` resmi reklam kimliği izni eklendi.
* **Flutter Kod Entegrasyonu:**
  * `google_mobile_ads: ^5.2.0` paketi entegre edildi.
  * `main.dart` içinde `MobileAds.instance.initialize()` ile başlatıldı.
  * `gokyuzu_app/lib/data/services/ad_service.dart` servisi yazıldı.
  * Doğum haritası detay sayfası ve analiz geçişlerine Interstitial (Tam ekran geçiş reklamı) bağlandı.
* **Android SDK Seviyeleri (Google Play 2026 Şartı):**
  * `compileSdk = 36`
  * `targetSdk = 36` (Google'ın zorunlu tuttuğu Android 16 düzeyi)
  * `minSdk = 21`

---

## 📜 4. Yasal Belgeler ve Google Play Politikaları (100% Tamamlandı)

* **Gizlilik Politikası (KVKK & GDPR Uyumlu):**
  * Barındırılan Canlı Link: `https://github.com/yigithanakman-ai/gokyuzu-doktoru/blob/main/PRIVACY_POLICY.md`
  * Raw Format: `https://raw.githubusercontent.com/yigithanakman-ai/gokyuzu-doktoru/main/PRIVACY_POLICY.md`
* **Play Console Anketleri:**
  * **Uygulama Erişimi:** Giriş kimlik bilgisi tanımlandı (`test@gokyuzudoktoru.com` / `Gokyuzu2026!`), misafir modunda kısıtlama olmadığı belirtildi.
  * **İçerik Derecelendirmesi (IARC):** "Diğer Tüm Uygulama Türleri" seçildi, Genel İzleyici (PEGI 3) sertifikası alındı.
  * **Hedef Kitle:** 18 yaş ve üzeri seçildi, çocuklara hitap etmediği beyan edildi.
  * **Veri Güvenliği (Data Safety):** Cihaz dışına veri aktarılmadığı (on-device processing) belirtildi.
  * **Reklam Kimliği (AD_ID):** "Evet, reklam ve pazarlama amacıyla kullanılıyor" olarak işaretlendi.

---

## 🎨 5. Mağaza Varlıkları (Store Assets)

* **Uygulama İkonu (512x512 PNG):** Hermetik Caduceus ve kozmik yörüngeler (`store_assets/google_play_icon_512x512.png`). Mağazada yayında.
* **Öne Çıkan Görsel / Banner (1024x500 JPG):** Kozmik Zodyak ve derin gökyüzü (`store_assets/google_play_feature_graphic_1024x500.jpg`).
* **Ekran Görüntüleri (Phone Screenshots):** 1080x2160 boyutunda 5 adet standart mağaza görseli (`store_assets/screenshots/screenshot_1.png` - `5.png`).
* **Mağaza Metinleri:**
  * **Kısa Açıklama:** `Derin doğum haritası analizi, kadim gökyüzü bilgeliği ve transit rehberi.`
  * **Tam Açıklama:** 4 sütunlu kadim astroloji, tıp tarihi ve hekimlik felsefesiyle harmanlanmış detaylı açıklama.

---

## 🚀 6. Google Play Console Test Kanalları Anlık Durumu

### A. Dahili Test (Internal Testing)
* **Durum:** Aktif ve Canlı.
* **Yüklü Sürüm:** `1.0.0 (1)`
* **Özellik:** Google onayı beklemez, eklenen test kullanıcıları anında indirebilir.

### B. Kapalı Test - Alpha (Closed Testing)
* **Durum:** **İncelemede ("Değişiklikleriniz şu anda inceleniyor")**
* **Yüklü Sürüm:** `3 (1.0.2)`
* **Hedeflenen Ülkeler:** 177 Ülke ve bölge (Türkiye, Almanya, ABD dahil tüm dünya).
* **Geri Bildirim Adresi:** `yigithanakman@gokyuzudoktoru.com`
* **Test Grubu:** `geliştirici` listesi bağlı.

---

## ⚠️ 7. Test Kullanıcılarına Link Gönderme Kuralı (HAYATİ BİLGİ)

Kullanıcılara doğrudan normal Play Store linki (`play.google.com/store/apps/details?id=...`) **gönderilmemelidir**.  
Eğer doğrudan o link gönderilirse Google kullanıcının testçi olduğunu algılayamaz ve ekranda uyuyan uydu (**"Nicht gefunden / Bulunamadı"**) çıkar!

### Doğru Davet Yöntemi:
Kullanıcılara Google Play Console'daki **"Web'de katılın"** altındaki davet linki gönderilmelidir:
👉 **`https://play.google.com/apps/testing/com.gokyuzudoktoru.gokyuzu_app`**

1. Kullanıcı bu linke tıklar.
2. Açılan resmi Google sayfasında mavi **"PROGRAMA KATIL" (Become a tester)** butonuna basar.
3. Ardından sayfadaki **"Google Play'den İndir"** linkine tıklayarak mağazadan uygulamayı indirir.

> **NOT:** Kapalı test sürümü şu anda Google'ın inceleme masasında olduğu için, bu link Google incelemeyi bitirip onayladığı an (birkaç saat içinde) aktifleşecektir.

---

## 🗺️ 8. Sırada Yapılacaklar (Adım Adım Yol Haritası)

1. **Google Onayını Beklemek:**  
   Google ekibi Kapalı Test sürümünü onayladığında (genellikle 24 saat içinde) Gmail adresine bildirim gelir ve durum "Kullanıma sunuldu / Yayında" olur.
2. **20 Test Kullanıcısının Dahil Edilmesi:**  
   Google Play Console -> **"Kontrol paneli"**ne girildiğinde, 20 test kullanıcısı ve 14 günlük test süreci ilerleme çubuğu açılacaktır. 20 kişinin Gmail adresi listeye eklenir ve yukarıdaki "testing" davet linki kendilerine iletilir.
3. **14 Günlük Süreç:**  
   20 kullanıcının uygulamayı telefonlarında 14 gün boyunca tutması ve ara sıra açması sağlanır.
4. **Resmi Yayına (Üretime) Alma:**  
   14 gün tamamlandığında Google Play Console'da "Üretime sun başvurusu yap" butonu açılır. Tek tıkla uygulama dünya çapında genel Google Play Store vitrinine çıkarılır!
