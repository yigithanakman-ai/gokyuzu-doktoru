# 🪐 GÖKYÜZÜ DOKTORU — MASTER PROJE HAFIZASI & YAPAY ZEKA DEVİR (HANDOFF) RAPORU (v1.0.13+14)

> **Yeni Bir Yapay Zeka Asistanına Not:**  
> Bu doküman, **Yiğithan Akman (Patron 👑)** tarafından geliştirilen **Gökyüzü Doktoru** projesinin tüm teknik mimarisini, astronomik motorlarını, para kazanma (AdMob & In-App Purchase) altyapısını, gizli yönetici özelliklerini ve bugüne kadar yapılan tüm güncellemeleri en ince ayrıntısına kadar içerir. Kullanıcıya her zaman **"Patron 👑"** diye hitap et ve buradaki kuralları harfiyen koru.

---

## 📌 1. Proje Kimlik Kartı ve Temel Bilgiler

- **Uygulama Adı:** Gökyüzü Doktoru
- **Geliştirici / Kurucu:** Yiğithan Akman (Patron 👑)
- **Güncel Sürüm:** `v1.0.13+14` (`versionName: 1.0.13`, `versionCode: 14`)
- **Android / iOS Paket Adı (Bundle ID):** `com.gokyuzudoktoru.gokyuzu_app`
- **GitHub Deposu:** `https://github.com/yigithanakman-ai/gokyuzu-doktoru` (`main` dalı)
- **Çalışma Dizini:** `/Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/gokyuzu_app`
- **İletişim & Destek Kanalları:**
  - **WhatsApp:** `+90 552 255 08 10` (`https://wa.me/905522550810`)
  - **Instagram:** `@gokyuzudoktoru` (`https://www.instagram.com/gokyuzudoktoru`)
  - **Telegram Bot:** `https://t.me/gokyuzudoktoru_destek_bot`
  - **E-Posta:** `iletisim@gokyuzudoktoru.com`
- **Varsayılan Coğrafi Merkez (Fallback):** GPS izni verilmediğinde veya konum alınamadığında varsayılan şehir **Datça, Muğla** (`36.7237° N, 27.6842° E`) olarak ayarlıdır. GPS izni verildiğinde kullanıcının bulunduğu gerçek il/ilçe (`AppLocationService`) dinamik olarak yazılır.

---

## 🌟 2. v1.0.13 (Build 14) Sürümünde Yapılan 10 Büyük Güncelleme

### 1) Ay Düğümleri: True Node (Gerçek) ve Mean Node (Ortalama) Ayrımı
- **Dosyalar:**
  - `gokyuzu_app/lib/data/services/sky_transits_service.dart`
  - `gokyuzu_app/lib/data/services/astrology_engine.dart`
  - `gokyuzu_app/lib/presentation/screens/chart_detail_screen.dart`
  - `gokyuzu_app/lib/presentation/widgets/interactive_bi_wheel_modal.dart`
- **Detay:**
  - Jean Meeus astronomik formülleriyle hem **Ortalama Ay Düğümü (`Mean Node`)** hem de Ay'ın yörünge salınım (nutasyon/pertürbasyon) terimlerini içeren **Gerçek Ay Düğümü (`True Node`)** ayrı ayrı hesaplanır (`true_north_node`, `true_south_node`, `mean_north_node`, `mean_south_node`).
  - Doğum Haritası (Liste ve 360° Çark) ve Tam Ekran İkili Çark ekranlarına **True Node (Gerçek) / Mean Node (Ortalama)** geçiş butonu ve her iki düğümün derecelerini yan yana gösteren karşılaştırma rozeti eklendi.

### 2) Seçilebilir 9 Asteroit ve Özel Nokta (Filtrelenebilir)
- **Eklenen Noktalar:**
  1. **Lilith (`lilith` - ⚸):** Kara Ay Lilith (Mean Lunar Apogee)
  2. **Vesta (`vesta` - ⚶):** Kutsal adanmışlık ve içsel odak asteroiti
  3. **Juno (`juno` - ⚵):** Ruh eşi kontratları ve evlilik asteroiti
  4. **Amor (`amor` - ♡):** Koşulsuz sevgi ve romantik çekim asteroiti
  5. **Hekate (`hekate` - ⚝):** Yol ayrımları, sezgi ve kadim bilgelik asteroiti (Asteroid 100 Hekate)
  6. **Isis (`isis` - ☥):** Bütünleştirici şifa ve ruhsal yeniden doğuş asteroiti (Asteroid 42 Isis)
  7. **Vertex Noktası (`vertex` - Vx):** Yardımcı yükselen / kadersel karşılaşma noktası (Co-latitude & RAMC küresel trigonometrisi)
  8. **Pallas (`pallas` - ⚴):** Pallas Athena stratejik zeka ve bilgelik asteroiti
  9. **Ceres (`ceres` - ⚳):** Beslenme, bereket ve şefkat asteroiti
- **Kullanıcı Kontrolü:** Kullanıcı harita üzerindeki çiplerden istediği asteroiti/noktayı tek dokunuşla açıp kapatabilir (`Hepsini Seç` / `Temizle` butonları dahil). Seçilen noktalar hem Liste görünümüne, hem 360° Natal/Transit çarklarına, hem de Açı (Aspects) hesaplamalarına anında dahil olur.

### 3) Astro Gold / Solar Fire Tarzı Profesyonel 360° Çark Tasarımı (Natal & Transit)
- **Dosyalar:**
  - `gokyuzu_app/lib/presentation/widgets/chart_wheel_painter.dart`
  - `gokyuzu_app/lib/presentation/widgets/interactive_bi_wheel_modal.dart`
- **Detay:**
  - **Ev Giriş Kaspları (House Cusps 1-12):** Tüm 12 Placidus ev giriş çizgisi belirginleştirildi; 1. Ev (ASC), 4. Ev (IC), 7. Ev (DSC) ve 10. Ev (MC) ana aksları kalın ok/çizgi ve dış halka kasp dereceleriyle (`04°♑17'` formatında) gösterilir.
  - **İç Halka Ev Numaraları (`1..12`):** Her ev diliminin ortasında `1`'den `12`'ye kadar ev numaraları net biçimde yer alır.
  - **Gezegen Dereceleri & Burç Sembolleri:** Çarkın içindeki her gezegen sembolünün yanında kendi derecesi, burç sembolü ve dakikası (`11°♓04'`) çakışma önleyici (anti-collision) algoritmayla yazılır.
  - **Merkez Açı Çizgileri & Sembolleri:** Merkezdeki açı kirişlerinin üzerinde açı sembolleri (`☌, ☍, △, □, ✶`) gösterilir.

### 4) Evrensel Açı Orbları (Universal Aspect Orbs)
- **Dosya:** `gokyuzu_app/lib/data/services/aspects_service.dart`
- **Kural:** Tüm haritada (Natal, Transit-Natal, Transit-Transit, 360° Çark ve İkili Çark) eski dar `5°` transit orbu kaldırılarak Patron'un belirlediği evrensel orb kuralları standart hale getirildi:
  - **Kavuşum (`0°`):** `10°` orb
  - **Karşıt (`180°`):** `10°` orb
  - **Üçgen / 120'lik (`120°`):** `8°` orb
  - **Kare / 90'lık (`90°`):** `7°` orb
  - **Sekstil / 60'lık (`60°`):** `7°` orb
- Böylece Transit Ay ve diğer gezegenler açısız kalmaz, tüm gerçek açılar eksiksiz yakalanır.

### 5) 28 Ay Menzili (Sa'd el-Ahbiye Kalibrasyonu) & Derece Formatı Düzeltmesi
- **Dosya:** `gokyuzu_app/lib/data/services/lunar_mansions_service.dart`
- **Detay:**
  - Geleneksel Arap/İslam astrolojisi (Manazil el-Qamar) presesyon kalibrasyonu uygulandı: Ay **`11° Balık`** burcundayken tam olarak **25. Menzil: Sa'd el-Ahbiye (Saadülahbiye — Çadırların Şansı)** (`04° 17' dk Balık – 17° 08' dk Balık`) menzilini gösterir.
  - **Derece Yazımı Düzeltmesi:** Burçlar `00° 00' dk` ile `29° 59' dk` (ortalama 30°) arasında ayrılır. Eski `12°51'` şeklindeki bitişik yazım "51 derece" gibi okunduğu için tüm menzil aralıkları `12° 51' dk` şeklinde açık dakika (`dk`) birimiyle ve `00°..29°` sınırlarıyla yeniden formatlandı.

### 6) Hermetik Adımların Ay Menzillerinden Ayrılması
- **Dosyalar:**
  - `gokyuzu_app/lib/data/services/lunar_mansions_service.dart`
  - `gokyuzu_app/lib/presentation/screens/home_screen.dart`
  - `gokyuzu_app/lib/presentation/screens/chart_detail_screen.dart`
- **Detay:**
  - Anasayfada (Canlı Gökyüzü) ve Doğum Haritası (Kadim & Melekler sekmesi) içinde **28 Kadim Ay Menzili** ile **Hermetik Adımlar & Tılsım Rehberi** birbirinden tamamen ayrıldı.
  - Hermetik Adımlar kendi ayrı kartına ve kendi ayrı 28 adımlık rehber modalına (`_showAllHermeticStepsModal`) kavuştu (Adım başlığı, Hermetik Tılsım sembolü, Tütsü/Frekans rezonansı ve Hermetik Uygulama adımı).

### 7) Uygulamaya Girmeden Arka Planda Bildirim Gelmesi (14 Günlük Tam Zamanlı Alarm Motoru)
- **Dosyalar:**
  - `gokyuzu_app/android/app/src/main/AndroidManifest.xml`
  - `gokyuzu_app/lib/data/services/notification_service.dart`
- **Önceki Sorun:** Bildirimler yalnızca uygulamaya girildiğinde anlık tetikleniyor, uygulama kapalıyken gün içinde gelmiyordu.
- **Çözüm:**
  1. `AndroidManifest.xml` dosyasına `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` ve `WAKE_LOCK` izinleri eklendi.
  2. Uygulama açıldığında `sendTestOrDailyNotification` ile anlık bildirim atma davranışı kaldırıldı; bunun yerine **gelecek 14 gün boyunca her gün 09:30, 14:30 ve 20:30** saatleri için (toplam 42 bağımsız tam zamanlı alarm + 3 döngüsel yedek alarm) o günün gerçek Ay burcu, derecesi ve fazı hesaplanarak işletim sistemine `AndroidScheduleMode.exactAllowWhileIdle` modunda kaydedilir.
  3. Kullanıcı uygulamaya günlerce hiç girmese bile telefonun işletim sistemi sabah 09:30, öğle 14:30 ve akşam 20:30'da bildirimleri otomatik olarak düşürür.

### 8) Taşma (Overflow) Sorunlarının Giderilmesi
- **Dosya:** `gokyuzu_app/lib/presentation/screens/chart_detail_screen.dart`
- **Çözüm:**
  - `"🔭 Canlı Çift Çark (Transit)"` sekme butonu içindeki `Row` dar ekranlarda sağdan taşıyordu; `Flexible` ve `TextOverflow.ellipsis` eklendi.
  - `"Dış Çark: Canlı Transitler"` ve `"İç Çark: Doğum (Natal)"` göstergeleri sabit `Row` yerine `Wrap` bileşenine alındı; hiçbir ekran boyutunda sağdan taşma yapmaz.

### 9) AdMob Canlı Reklam ve Anında Gösterim Motoru (Root-Cause Çözümü)
- **Dosya:** `gokyuzu_app/lib/data/services/ad_service.dart`
- **Kök Neden & Çözüm:**
  1. Kod içerisindeki `kReleaseMode ? live : test` koşulu kaldırıldı; tüm istekler doğrudan Patron'un AdMob hesabına bağlandı.
  2. 4. eylemde önceden yüklenmiş reklam yoksa atlanmıyordu; `loadAndShowInterstitial` çağrılarak ekranda gösterim güvenceye alındı.
  3. Android ve iOS platformları için ayrı değişkenler ve platform-aware getter'lar (`interstitialAdUnitId` ve `rewardedAdUnitId`) kurgulandı.

### 10) Gizli Patron Yönetici Girişi
- **Dosya:** `gokyuzu_app/lib/presentation/widgets/vip_upgrade_modal.dart`
- **Detay:**
  - Normal kullanıcılar için ham promosyon kodu giriş alanları arayüzden tamamen temizlendi.
  - VIP modalındaki en üstteki **Taç (👑) simgesine 5 kez art arda dokunulduğunda** gizli `👑 Patron Yönetici Girişi` açılır.
  - **Gizli Kod:** `gkyz2453` (veya `GKYZ-VIP-9999`). Girildiğinde tüm uygulama anında **VIP Platinum** olur ve reklamlar tamamen kapanır.

---

## 💰 3. AdMob Reklam Birimleri İncelemesi ve Platform Eşleştirmesi

Patron'un paylaştığı AdMob Reklam Birimleri paneli ekran görüntüsüne göre doğrulamalar:

| AdMob Birim Adı | Tür | AdMob Panelindeki ID | Kod Tarafındaki Değişken (`ad_service.dart`) | Sıklık Sınırı (Frequency) | Durum |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Gokyuzu_Gecis_Sekmeler** | Geçiş (Interstitial) | `ca-app-pub-1133172251227471/7656178404` | `androidInterstitialAdId` | Sınır Yok (Uygulama kontrolünde) | ✅ %100 Eşleşti |
| **Gokyuzu_Odullu_Pusula** | Ödüllü (Rewarded) | `ca-app-pub-1133172251227471/1704268715` | `androidRewardedAdId` | Sınır Yok (Uygulama kontrolünde) | ✅ %100 Eşleşti |

### Kritik Notlar:
1. **Sıklık Sınırının "Sınır Yok" Olması:**  
   AdMob panelinde sıklık sınırının "Sınır yok" olması mükemmel bir tercihtir. Eğer AdMob tarafında günlük 2-3 sınır konulsaydı, uygulamadaki 4-aksiyon kuralımız Google tarafından engellenebilirdi. Kontrol tamamen bizim akıllı sayacımızdadır.
2. **Android vs. iOS AdMob Ayrımı:**  
   Ekran görüntüsünde görünen uygulama **Gökyüzü Doktoru Android**'dir. Google AdMob, Android ve iOS platformlarını iki ayrı uygulama olarak kabul eder. Kodumuzda `ad_service.dart` hem Android hem iOS kimliklerini bağımsız yönetecek şekilde ayrılmıştır. iOS için App Store yayını öncesinde AdMob panelinden `Uygulamalar -> Uygulama ekle -> iOS` seçilerek 2 birim açılması yeterlidir.

---

## 📱 4. Platform Uyumluluğu: Android & iOS Senkronizasyonu

### Android Yapılandırması (`android/app/src/main/AndroidManifest.xml`)
- **AdMob App ID:** `ca-app-pub-1133172251227471~4078534665`
- **İzinler:**
  - `com.google.android.gms.permission.AD_ID` (Google Play 2026 reklam ID politikası)
  - `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`
  - `POST_NOTIFICATIONS`
  - `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
  - Gereksiz medya izinleri (`READ_MEDIA_*`, `*_EXTERNAL_STORAGE`) Play Store reddini önlemek için `tools:node="remove"` ile temizlenmiştir.

### iOS Yapılandırması (`ios/Runner/Info.plist`)
- **GADApplicationIdentifier:** `ca-app-pub-1133172251227471~4078534665`
- **SKAdNetworkItems:** Google AdNetwork ID (`cstr6suwn9.skadnetwork`) eklenerek iOS 14+ dönüşüm ve reklam istek uyumluluğu garanti altına alındı.
- **Konum İzni:** `NSLocationWhenInUseUsageDescription` gezegen saatleri ve yükselen hesabı için açıklamalı olarak mevcuttur.

---

## 🛡️ 5. Güvenlik, Git Deposu & API Koruması

1. **Git Geçmişi Temizliği:**
   - Eski `0148e0e8` nolu committe kazara yer alan Pinecone/Google anahtarı yerel dosyadan temizlendi ve git geçmişi geriye sarılarak anahtarsız tertemiz hale getirildi.
   - `.gitignore` katı kurallarla donatıldı: `1_Iletisim_Botlari/`, `2_ Sosyal_Medya_Gorselleri/`, `3_YapayZeka_Beyni/`, `4_Zamanli_Gorevler/`, `Arsiv_Eski_Kodlar/`, `*.csv`, `*.env`, `*credentials*.json`, `*token*.json`, `*.apk`, `*.aab`, `*.ipa` asla GitHub'a gitmez.
   - GitHub `origin main` dalı sıfır sızıntı ile senkronize edildi.

---

## 🧪 6. Test ve Doğrulama Durumu

- **Statik Kod Analizi (`dart analyze lib`):** 0 hata, 0 uyarı.
- **Birim Testleri (`flutter test test/v1013_features_test.dart`):**
  - `True Node vs Mean Node calculation and difference test`: **PASSED**
  - `All 9 asteroids calculation and valid zodiac degrees test`: **PASSED**
  - `Aspect engine universal orbs test`: **PASSED**
  - `Lunar Mansion 25 Sa'd el-Ahbiye at 11 Pisces test`: **PASSED**
  - `Aspect symbols formatting test`: **PASSED**
  - **Sonuç:** 5/5 test başarıyla geçti.

---

## 📋 7. Yapılanlar ve Yapılacaklar Listesi (Roadmap)

### ✅ Yapılanlar (v1.0.13+14 Tamamlandı):
- [x] AdMob test birimi yönlendirme hatası (`kReleaseMode ? live : test`) kaldırıldı; tüm istekler canlı kimliklere bağlandı.
- [x] AdMob panelindeki `Gokyuzu_Gecis_Sekmeler` (`7656178404`) ve `Gokyuzu_Odullu_Pusula` (`1704268715`) kodla birebir doğrulandı.
- [x] 4. eylemde reklam bellekte yoksa atlama hatası giderildi; anında yükleyip gösterme (`loadAndShowInterstitial`) eklendi.
- [x] Android `AndroidManifest.xml` (`APPLICATION_ID`, `AD_ID`, alarmlar) tam uyarlandı.
- [x] iOS `Info.plist` (`GADApplicationIdentifier`, `SKAdNetworkItems`) eklendi.
- [x] True Node / Mean Node, 9 Asteroit, Astro Gold 360 Çark, Evrensel Orblar, Sa'd el-Ahbiye ve Hermetik Adımlar teslim edildi.
- [x] Gizli Patron yönetici girişi kuruldu.

### 📌 Yapılacaklar (Gelecek Adımlar):
- [ ] **Google Play Console Kapalı Teste Yeni AAB Yükleme:** Canlı AdMob düzeltmelerini içeren `v1.0.13+14` bundle'ının kapalı test kanalına yüklenmesi.
- [ ] **AdMob Paneli İzleme:** Güncelleme yüklendikten 24-48 saat sonra AdMob panelindeki "İstekler" ve "Eşleşme Oranı" istatistiklerinin sıfırdan yukarı tırmandığının kontrol edilmesi.
- [ ] **AdMob iOS Uygulaması Oluşturma:** iOS App Store sürümü öncesinde AdMob panelinden `Uygulama Ekle -> iOS` adımıyla iOS için özel 2 reklam birimi alınıp `ad_service.dart` içindeki `iosInterstitialAdId` ve `iosRewardedAdId` değişkenlerine yazılması.
- [ ] **Google Play In-App Purchase Aboneliklerini Etkinleştirme:** Play Console -> Para Kazanma -> Abonelikler altındaki 4 abonelik ID'sinin aktifleştirilmesi.

---

## 🚀 8. Sürüm Dağıtım Notları (Google Play & App Store v1.0.13+14)

```text
Gökyüzü Doktoru v1.0.13 Yayında! 🪐✨

Bu sürümde astronomi motorumuzu ve harita deneyimini baştan aşağı yeniledik:
• Ay Düğümleri Seçimi: True Node (Gerçek) ve Mean Node (Ortalama) ayrımı eklendi.
• 9 Yeni Asteroit & Nokta: Lilith, Vesta, Juno, Amor, Hekate, Isis, Vertex, Pallas ve Ceres'i haritanıza ekleyebilir veya filtreleyebilirsiniz.
• Astro Gold Tarzı 360° Çark: Belirgin Placidus ev kaspları, kasp dereceleri, ev numaraları ve gezegen açı sembolleriyle profesyonel görselleştirme.
• Evrensel Açı Orbları: Kavuşum/Karşıt 10°, Üçgen 8°, Kare/Sekstil 7° standart kuralları haritaya entegre edildi.
• 28 Ay Menzili & Hermetik Adımlar: Ay Balık burcundayken Sa'd el-Ahbiye menzili kalibrasyonu sağlandı ve Hermetik Adımlar müstakil bir rehbere dönüştürüldü.
• Kesintisiz Bildirimler: Uygulamaya girmeseniz bile günlük gezegen ve ay rehberliği bildirimleri tam zamanında telefonunuza ulaşır.
• Arayüz İyileştirmeleri ve Performans: Taşmalar giderildi, reklam ve abonelik geçişleri hızlandırıldı.
```
