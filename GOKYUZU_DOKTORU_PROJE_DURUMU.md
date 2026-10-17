# 🪐 Gökyüzü Doktoru — Proje Durumu, Yapılanlar ve Yol Haritası (Master El Kitabı)

> **Bu Belgenin Amacı:** Bu dosya, Gökyüzü Doktoru mobil uygulamasının geliştirme, derleme, mağaza varlıkları, reklam entegrasyonu, yasal formları, astrolojik hesaplama motorları ve Google Play Console yayın süreçlerinin **eksiksiz durum kaydıdır**. Yeni bir yapay zeka oturumu veya geliştirici bu dosyayı okuduğunda, projenin geçmişini, anlık durumunu ve sırada yapılması gerekenleri adım adım anlayacaktır.

---

## 📌 1. Temel Proje ve Kimlik Bilgileri

* **Uygulama Adı:** Gökyüzü Doktoru (Sky Doctor)
* **Paket Kimliği (Package Name / Application ID):** `com.gokyuzudoktoru.gokyuzu_app`
* **Geliştirici Hesabı:** Yiğithan Akman (Google Play Console Bireysel Geliştirici)
* **Hitap Kuralı:** Yiğithan Akman'a sistemde **"Patron" 👑** olarak hitap edilir.
* **Teknoloji:** Flutter & Dart (Cross-platform: Android, iOS, macOS)
* **GitHub Repository:** [https://github.com/yigithanakman-ai/gokyuzu-doktoru](https://github.com/yigithanakman-ai/gokyuzu-doktoru)
* **Aktif Git Dalı (Branch):** `main`
* **En Son Git Commit:** `6a9cab3` (*feat: default horoscopes to rising sign, fix Placidus eclipse house calculation, and ensure tablet/macbook vertical responsiveness*)
* **Mevcut Sürüm:** `1.0.3+4` (VersionName: `1.0.3`, VersionCode: `4`)
* **Resmi İletişim / Destek E-postası:** `yigithanakman@gokyuzudoktoru.com`
* **Resmi Yasal Merkez (GitHub Pages):** `https://yigithanakman-ai.github.io/gokyuzu-doktoru/`

---

## 🚀 2. En Son Tamamlanan Geliştirmeler & Kök Neden Çözümleri

### A. Astro Bülten Burç Yorumları (Yükselen Burç Önceliği & Bilgilendirme Notu)
* **Yükselen Burç Önceliği:** Astro Bülten modalı açıldığında, burç yorumları artık varsayılan olarak kullanıcının **Yükselen Burcu** seçilerek listelenir. Yükselen burç profilde boşsa Güneş burcuna düşer.
* **Bilgilendirme Notu:** 12 burç seçicisinin hemen üzerine şu not eklenmiştir:
  > *"Burç yorumları öncelikle Yükselen burcunuza göre takip edilmelidir. Yükselen burcunuzu bilmiyorsanız Güneş burcunuzu baz alabilirsiniz."*
* **Çoklu Dil Rozetleri:** Burç butonlarında kullanıcının yükselen burcuna altın sarısı `YÜKSELEN` (`RISING` / `上昇宮`), güneş burcuna nane yeşili `GÜNEŞ` (`SUN` / `太陽`) rozetleri yerleştirildi ve 12 burcun isimleri seçili dile göre dinamik çevrildi.

### B. Tutulma Ev Hesaplama Hatasının Düzeltilmesi (Placidus Kök Neden Çözümü)
* **Önceki Hata:** Tutulma servisi burç indeks farkına dayalı `(safeEcIdx - safeAscIdx + 12) % 12 + 1` Whole Sign mantığı kullandığı için, 4. Ev girişi 14° Aslan olan birinin 20° Aslan'daki tutulması yanlışlıkla 3. ev olarak yorumlanıyordu.
* **Kök Neden Düzeltmesi:** [eclipses_service.dart](file:///Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/gokyuzu_app/lib/data/services/eclipses_service.dart) içinde kullanıcının gerçek doğum saati ve koordinatlarına göre hesaplanan **Placidus ev kaspları** (`PredictiveAstrologyService.calculatePlacidusHouses`) bağlandı.
* **Sonuç:** 4. Ev kaspı 14° Aslan (134°) ve 5. Ev kaspı 10° Başak (160°) olan bir haritada, 20° Aslan (140°) tutulması artık kesin olarak **4. Ev (4. Ev - 10. Ev Aksı: Yuva & Kökler / Kariyer & Zirve)** olarak analiz edilmektedir. [predictive_astrology_test.dart](file:///Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/gokyuzu_app/test/predictive_astrology_test.dart) test paketi ile doğrulandı.

### C. Efemeris ve Astroloji Motoru Harmonizasyonu (Solar Fire / Astro Gold)
* `AstrologyEngine`, `SkyTransitsService` ve `AstroBulletinService` aynı jeosantrik matematiksel altyapıya bağlandı.
* Chiron anlık olarak Koç burcunun retro derecesindedir (`28°46' Retro Koç`).
* Venüs-Plüton karesi ve Jüpiter-Chiron sekstili gibi majör gökyüzü transitleri kesin efemeris gün ve derecesinde gösterilir.

### D. %100 Gömülü Çoklu Dil Desteği (TR / EN / JA)
* [app_translation_service.dart](file:///Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/gokyuzu_app/lib/data/services/app_translation_service.dart) servisi üzerinden tüm sistem (gezegenler, burçlar, evler, açılar, günlük enerjiler, butonlar, uyarılar) Türkçe, İngilizce ve Japonca dillerine eksiksiz çevrilmiştir.
* Dil değiştirildiğinde uygulama yeniden başlatma gerektirmeden anında reaktif olarak güncellenir.

### E. MacBook, iPad ve Tabletler İçin Dikey Format (Responsive Container)
* [main.dart](file:///Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/gokyuzu_app/lib/main.dart) `MaterialApp.builder` içerisine `BoxConstraints(maxWidth: 600)` ve `Color(0xFF0D0A14)` kozmik arka plan eklendi.
* Tüm `showModalBottomSheet` modallarına `maxWidth: 600` kısıtı tanımlandı.
* Geniş ekranlarda (MacBook, iMac, iPad Pro, Android tabletler) kartlar yatayda orantısız esnemez; telefon formundaki şık dikey kaset merkezde korunur.

### F. Aydınlatma Metni & KVKK Onayı
* Onboarding ekranındaki KVKK onay kutusu ekranın en altına, ana form butonunun hemen üzerine taşındı; ekran taşmaları tamamen engellendi.

---

## 🔐 3. Dijital İmza (Upload Keystore) Bilgileri

* **Keystore Konumu:** `gokyuzu_app/android/app/upload-keystore.jks`
* **Key Properties:** `gokyuzu_app/android/key.properties`
* **Key Alias:** `upload`
* **Store & Key Password:** `GokyuzuDoktoru2026!UploadKey`
* **Otomasyon:** GitHub Actions (`.github/workflows/build_apk.yml`), her `git push origin main` yapıldığında bu keystore'u otomatik decode eder ve resmi olarak imzalı `.apk` ile `.aab` paketlerini derleyip GitHub Releases üzerinde yayınlar.

---

## 💰 4. Google AdMob & Reklam Kimliği (AD_ID) Entegrasyonu

* **AdMob Resmi Uygulama Kimliği (App ID):** `ca-app-pub-1133172251227471~4078534665`
* **Manifest Ayarı (`AndroidManifest.xml`):**
  * `com.google.android.gms.ads.APPLICATION_ID` tanımlandı.
  * `com.google.android.gms.permission.AD_ID` resmi reklam kimliği izni eklendi.
* **Android SDK Seviyeleri (Google Play 2026 Zorunluluğu):**
  * `compileSdk = 36`
  * `targetSdk = 36` (Android 15 / 16 gereksinimi tam karşılandı)
  * `minSdk = 21`

---

## 📜 5. Yasal Belgeler ve Mağaza Uyumluluğu

* **Resmi Yasal Merkez:** `https://yigithanakman-ai.github.io/gokyuzu-doktoru/` (GitHub Pages üzerinde `docs/index.html` olarak barındırılmaktadır).
* **Gizlilik Politikası (KVKK / GDPR / Açık Rıza):** Mağaza gereksinimlerine uygun olarak Türkçe, İngilizce ve genel yasal standartlarla hazırlanmıştır.
* **Statik Kod Analizi:** `dart analyze lib/` ve `analyze_files` çıktısı: **0 Hata (No errors)**.
* **Birim Testleri:** `test/predictive_astrology_test.dart` içindeki Placidus ve tutulma testleri %100 başarılıdır.

---

## 🎨 6. Mağaza Varlıkları (Store Assets)

* **Uygulama İkonu (512x512 PNG):** `store_assets/google_play_icon_512x512.png`
* **Öne Çıkan Görsel / Banner (1024x500 JPG):** `store_assets/google_play_feature_graphic_1024x500.jpg`
* **Ekran Görüntüleri:** `store_assets/screenshots/screenshot_1.png` - `5.png` (1080x2160 dikey format).

---

## 🚀 7. Google Play Console Test Kanalları Anlık Durumu

### A. Dahili Test (Internal Testing)
* **Durum:** Aktif ve Canlı.

### B. Kapalı Test - Alpha (Closed Testing)
* **Durum:** **İncelemede ("Değişiklikleriniz şu anda inceleniyor")**
* **Hedeflenen Ülkeler:** 177 Ülke ve bölge.
* **Geri Bildirim Adresi:** `yigithanakman@gokyuzudoktoru.com`
* **Resmi Test Katılım Linki:**
  👉 **`https://play.google.com/apps/testing/com.gokyuzudoktoru.gokyuzu_app`**

---

## 🗺️ 8. Sırada Yapılacaklar (Adım Adım Yol Haritası)

1. **Google İnceleme Onayının Alınması:**  
   Google Play Console ekibi kapalı test sürümünü onayladığında durum "Kullanıma sunuldu / Yayında" durumuna geçecektir.
2. **20 Test Kullanıcısının Davet Edilmesi:**  
   Google Play Console -> **"Kontrol paneli"**ne girildiğinde, 20 test kullanıcısı ve 14 günlük test süreci ilerleme çubuğu açılacaktır. 20 kişinin Gmail adresi listeye eklenir ve yukarıdaki "testing" davet linki kendilerine iletilir.
3. **14 Günlük Süreç:**  
   20 kullanıcının uygulamayı telefonlarında 14 gün boyunca tutması ve ara sıra açması sağlanır.
4. **Resmi Yayına (Üretime) Alma:**  
   14 gün tamamlandığında Google Play Console'da "Üretime sun başvurusu yap" butonu açılır. Tek tıkla uygulama dünya çapında genel Google Play Store vitrinine çıkarılır!
