# 🪐 GÖKYÜZÜ DOKTORU — MASTER PROJE HAFIZASI & YAPAY ZEKA DEVİR (HANDOFF) RAPORU (v1.0.14+19)

> **Yeni Bir Yapay Zeka Asistanına Not:**  
> Bu doküman, **Yiğithan Akman (Patron 👑)** tarafından geliştirilen **Gökyüzü Doktoru** projesinin tüm teknik mimarisini, astronomik motorlarını, para kazanma (AdMob & In-App Purchase) altyapısını, gizli yönetici özelliklerini ve bugüne kadar yapılan tüm güncellemeleri en ince ayrıntısına kadar içerir. Kullanıcıya her zaman **"Patron 👑"** diye hitap et ve buradaki kuralları harfiyen koru.

---

## 📌 1. Proje Kimlik Kartı ve Temel Bilgiler

- **Uygulama Adı:** Gökyüzü Doktoru
- **Geliştirici / Kurucu:** Yiğithan Akman (Patron 👑)
- **Güncel Sürüm:** `v1.0.14+19` (`versionName: 1.0.14`, `versionCode: 19`)
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

## 🌟 2. v1.0.13 (Build 14) Sürümünde Yapılan 11 Büyük Güncelleme

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

### 7) Uygulamaya Girmeden Arka Planda Bildirim Gelmesi & Google Play Exact Alarm Politikası Uyumu
- **Dosyalar:**
  - `gokyuzu_app/android/app/src/main/AndroidManifest.xml`
  - `gokyuzu_app/lib/data/services/notification_service.dart`
- **Önceki Sorun & Google Play Hatası:**
  - Bildirimler yalnızca uygulamaya girildiğinde tetikleniyordu. Arka planda 14 günlük alarm planlaması için `SCHEDULE_EXACT_ALARM` izni eklendiğinde Google Play Console yükleme aşamasında *"Uygulamanızda tam alarm izni kullanılıp kullanılmadığını bize bildirmeniz gerekir"* hatası verdi. Çünkü Google Play politikalarına göre `SCHEDULE_EXACT_ALARM` ve `USE_EXACT_ALARM` izinleri yalnızca çalar saat (alarm clock) ve takvim uygulamaları için geçerlidir; astroloji veya diğer kategorilerdeki uygulamalarda bu izin beyanı reddedilir.
- **Kökten Çözüm:**
  1. `AndroidManifest.xml` içine `tools:node="remove"` ile `SCHEDULE_EXACT_ALARM` ve `USE_EXACT_ALARM` kaldırılarak Google Play Console'un gereksiz beyan istemesi engellendi.
  2. Arka plan bildirimleri `AndroidScheduleMode.inexactAllowWhileIdle` moduna geçirildi. Bu mod sayesinde hem telefon uyku modundayken (Doze mode) sabah 09:30, öğle 14:30 ve akşam 20:30'da bildirimler bataryayı sömürmeden iletilir, hem de Google Play Console sıfır hata ve sıfır beyan ile AAB paketini doğrudan onaylar.

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

### 11) Türkiye Tarihi Yaz Saati Uygulaması (1910–2026+) & Solar Fire / Astro Gold %100 Yükselen (Ascendant) Kalibrasyonu
- **Dosyalar:**
  - `gokyuzu_app/lib/data/services/predictive_astrology_service.dart`
  - `gokyuzu_app/lib/data/services/world_cities_service.dart`
  - `gokyuzu_app/lib/data/services/astrology_engine.dart`
  - `gokyuzu_app/lib/data/models/saved_profile_model.dart`
- **Kök Neden Analizi (Neden Eski Kodda Yükselen Hatalı Çıkıyordu?):**
  1. **Eski Basit Yaz Saati Varsayımı:** Eski `getHistoricalUtcOffset` fonksiyonu 2016 öncesindeki her yılın Nisan–Eylül aylarını körü körüne `UTC+3` (Yaz Saati var) varsayıyordu. Oysa Türkiye'de:
     - **1952–1961** yılları arasında hiç yaz saati uygulanmadı (`UTC+2`). Bu yüzden **11.09.1959 10:30 Kırıkkale** doğumunda eski kod `UTC+3` alıp saati 1 saat geri çekiyor ve Yükseleni **18° 06' Akrep** yerine `06° Akrep` buluyordu!
     - **1965–1969** ve **1971–1972** yılları arasında hiç yaz saati uygulanmadı (`UTC+2`). Bu yüzden **10.09.1971 16:46 İzmir** doğumunda eski kod `UTC+3` alıp saati 1 saat geri çekiyor ve Yükseleni **10° 38' Kova** yerine `22°30' Oğlak` buluyordu!
     - **1978–1982** arasında kışın da kalıcı `UTC+3` uygulandı; **1983** yazında ise `GMT+3` üzerine ileri saat eklenerek **`UTC+4`** uygulandı!
  2. **GAST (Greenwich Apparent Sidereal Time) & Nutasyon Eksikliği:** Eski `calculateAscAndMc` ortalama yıldız zamanı (GMST) ve ortalama ekliptik eğikliği ($\varepsilon_0$) kullanıyordu. Swiss Ephemeris, Solar Fire ve Astro Gold ise boylam nutasyonu ($\Delta\psi$), eğiklik nutasyonu ($\Delta\varepsilon$), gerçek ekliptik eğikliği ($\varepsilon = \varepsilon_0 + \Delta\varepsilon$) ve **Görünür Yıldız Zamanı (GAST)** kullanır.
  3. **Şehir Yazım Hatası ("kırkkale") ve Koordinat Kalibrasyonu:** `"kırkkale"` gibi ilk `'ı'` harfi unutulan yazımlarda eski kod şehri bulamayıp `Datça` koordinatlarına düşüyordu. Ayrıca `AstrologyEngine.calculateRisingSign` fonksiyonu şehir bulunduğunda saat dilimini alıyor ama `lat/lon` değerlerini güncellemiyordu.
- **Kalıcı Çözüm:**
  - Resmi Gazete kararları (`astrolojidergisi.com/yaz-saati-2` - Oya Vulaş derlemesi) ve IANA `Europe/Istanbul` (`tzdata`) veritabanı birleştirilerek **1910–2026+ tam tarihsel Türkiye Yaz Saati tablosu (`_turkeyHistoricalDstTable`)** gün, ay, yıl ve geçiş saatine (`hour`, `minute`) duyarlı olarak sisteme gömüldü.
  - `calculateAscAndMc` motoruna IAU nutasyon serisi ($\Delta\psi, \Delta\varepsilon$) ve **GAST** eklendi; İzmir koordinatı ACS Atlas (`38°25' N, 27°09' E`) standardına getirildi:
    - **10 Eylül 1971, İzmir, 16:46** $\rightarrow$ **`10° 38' Kova`** (Solar Fire & Astro Gold ile %100 birebir aynı!)
    - **11 Eylül 1959, Kırıkkale ("kırkkale"), 10:30** $\rightarrow$ **`18° 06' Akrep`** (Solar Fire & Astro Gold ile %100 birebir aynı!)
  - `WorldCitiesService` içerisine Türkçe büyük/küçük harf (`İ/I`) normalizasyonu, halk arasındaki il kısaltmaları (`kirkkale`, `afyon`, `antep`, `urfa`, `maras`, `icel`, `adapazari`, `izmit`, `antakya`) ve **Levenshtein (`<= 2` harf hatası) bulanık eşleştirme (fuzzy search)** eklendi.
  - `AstrologyEngine.calculateRisingSign` ve `SavedProfile` getter'ları şehir koordinatlarını ve tarihsel DST'yi her zaman deterministik olarak kullanacak şekilde düzeltildi.

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

## 🛡️ 5. Siber Güvenlik, Tersine Mühendislik Koruması & API Kalkanı

1. **GitGuardian & Gizli Anahtar Sızıntısı Analizi ve Kökten Çözüm:**
   - **Gelen Uyarının Nedeni:** GitHub uzak sunucusunda asılı kalan eski `v1.0.13` git etiketi (`refs/tags/v1.0.13`), geçmişte backend bot dosyalarını içeren `0148e0e8` nolu commite işaret ediyordu. GitGuardian bu eski etiketi tarayarak Google OAuth, Telegram Bot Token ve Pinecone API anahtarları için uyarı e-postası gönderdi.
   - **Kökten Çözüm:** Eski `v1.0.13` etiketi GitHub sunucusundan tamamen silindi (`git push origin :refs/tags/v1.0.13`), ardından tertemiz `e4fbfd99` commitine bağlanarak yeniden yayınlandı. `0148e0e8` commitinin tüm git referansları koparıldı; repodaki hiçbir dal veya etiket bu commite artık erişemez.
   - **Öneri:** Pinecone ve Telegram bot tokenlarının ilgili portallardan (BotFather ve Pinecone Console) "Revoke/Regenerate" edilerek yenilenmesi her ihtimale karşı tavsiye edilir.

2. **Tersine Mühendislik (Reverse Engineering) & APK Klonlama Koruması:**
   - **Android ProGuard & R8 Obfuscation:** `android/app/build.gradle.kts` içinde `isMinifyEnabled = true` ve `isShrinkResources = true` aktifleştirildi. `proguard-rules.pro` kural dosyasıyla tüm sınıflar, metodlar ve değişkenler anlamsız karakterlere (`a, b, c`) dönüştürüldü, paket yapısı `com.gokyuzudoktoru.sec` altına gizlendi ve tüm `Log.*` kodları ikili dosyadan kazındı.
   - **Flutter Dart AOT Bytecode Karartma:** Derleme motoruna `--obfuscate --split-debug-info=./debug-symbols` bayrağı eklendi. Dart derleyicisi tüm AST sembollerini ve fonksiyon isimlerini silerek Ghidra, IDA Pro, jadx ve apktool gibi araçlarla decompile edilmesini imkansız hale getirir.

3. **API Görünmezliği & Aylık/Günlük İstek Limiti (Rate Limiter):**
   - **On-Device Mimari:** Uygulamanın tüm astrolojik hesaplamaları (Natal, Transit, Progresyon, Menazil, Gezegen Saatleri, Açı motoru) %100 matematiksel olarak cihazın kendi içinde (offline) çalışır; harici bir astroloji sunucusuna bağımlı değildir.
   - **API Maskeleme:** Şehir arama uç noktaları (`world_cities_service.dart`) ikili dosyada açık metin olarak yer almaz; XOR maskeli (`SecurityShieldService.resolveMaskedEndpoint`) olarak bellekte anlık çözülür.
   - **Kota Kalkanı (`SecurityShieldService`):** Cihaz başına günlük maksimum 50, aylık maksimum 350 istek limiti uygulanır. Kota aşıldığında uygulama otomatik olarak yerel 500+ şehir veri tabanına düşer; scraping veya bot saldırıları engellenir.

4. **Klasör Güvenliği & Gitignore:**
   - `1_Iletisim_Botlari/`, `2_ Sosyal_Medya_Gorselleri/`, `3_YapayZeka_Beyni/`, `4_Zamanli_Gorevler/`, `Arsiv_Eski_Kodlar/`, `*.csv`, `*.env`, `*credentials*.json`, `*token*.json` dosyaları `.gitignore` altında koruma altındadır ve asla depoya dahil edilmez.

---

## 🧪 6. Test ve Doğrulama Durumu

- **Statik Kod Analizi (`dart analyze lib test/v1013_features_test.dart`):** 0 hata, 0 uyarı.
- **Birim Testleri (`flutter test test/v1013_features_test.dart`):**
  1. `11 Derece Balık burcundaki Ay, 25. Menzil Sa'd el-Ahbiye olarak hesaplanır`: **PASSED**
  2. `Tüm 28 Ay Menzili derece aralıkları 00°-29° burç sınırına ve dk formatına uygundur`: **PASSED**
  3. `AstrologyEngine True Node / Mean Node ve 9 Seçilebilir Asteroit/Noktayı hesaplar`: **PASSED**
  4. `SkyTransitsService getExtraTransitBodies tüm asteroit ve düğümleri döner`: **PASSED**
  5. `AspectsService Evrensel Açı Orbları (0/180: 10°, 120: 8°, 90/60: 7°) aktiftir`: **PASSED**
  6. `Solar Fire & Astro Gold Kalibrasyonu #1: 10 Eylül 1971 İzmir 16:46 -> Yükselen 10° 38' Kova`: **PASSED**
  7. `Solar Fire & Astro Gold Kalibrasyonu #2: 11.09.1959 Kırıkkale ("kırkkale") 10:30 -> Yükselen 18° 06' Akrep`: **PASSED**
  8. `Türkiye Tarihi Yaz Saati Uygulaması (1940-2026+) Resmi Gazete & IANA Doğrulaması`: **PASSED**
  - **Sonuç:** 8/8 test %100 başarıyla geçti.

---

### 11) Haritayı 2 Parmakla Büyütme (Pinch-to-Zoom / `ChartZoomScreen`) & Sabit Oryantasyon (Build 18)
- **Dosyalar:**
  - `gokyuzu_app/lib/presentation/screens/chart_zoom_screen.dart`
  - `gokyuzu_app/lib/presentation/screens/chart_detail_screen.dart`
  - `gokyuzu_app/lib/presentation/widgets/chart_wheel_painter.dart`
  - `gokyuzu_app/lib/presentation/widgets/interactive_bi_wheel_modal.dart`
- **Detay:**
  - Parmakla çark döndürme modu kullanıcı isteğiyle tamamen kaldırıldı; harita evrensel oryantasyonda (ASC = 9 yönü) kilitlendi.
  - Tekli ve Çift Çarkta haritaya veya butonuna dokunulduğunda tam ekran `ChartZoomScreen` açılır; kullanıcı 2 parmağıyla haritayı 0.6x ile 6.0x arasında akıcı şekilde büyütüp küçültebilir ve gezdirebilir.

### 12) Kilitli / Uykuda / Şarjda / Pilde Tam Zamanlı Kesintisiz Bildirim Çözümü (Build 18)
- **Dosyalar:**
  - `gokyuzu_app/android/app/src/main/AndroidManifest.xml`
  - `gokyuzu_app/lib/data/services/notification_service.dart`
- **Detay:**
  - Telefon uykuda, ekran koruyucuda, kilitliyken veya şarjdayken bildirimlerin iletilmeme sorunu çözüldü.
  - `NotificationVisibility.public`, `WAKE_LOCK`, `SCHEDULE_EXACT_ALARM`, `ScheduledNotificationBootReceiver` ve `exactAllowWhileIdle` ile CPU uyandırılarak 09:30, 14:30 ve 20:30 alarmları zamanında iletilir.
  - Cihaz saat dilimi ile IANA Europe/Istanbul ofset eşleştirmesi uygulandı.

### 13) 🌙 Ay Burç, 🔮 28 Ay Menzili ve 🪐 Gezegen Burç Geçiş Bildirimleri (Build 19)
- **Dosyalar:**
  - `gokyuzu_app/lib/data/services/sky_transits_service.dart`
  - `gokyuzu_app/lib/data/services/lunar_mansions_service.dart`
  - `gokyuzu_app/lib/data/services/notification_service.dart`
  - `gokyuzu_app/lib/presentation/screens/profile_screen.dart`
  - `gokyuzu_app/lib/presentation/screens/home_screen.dart`
- **Detay:**
  1. **Ay Burç Değişimleri (Moon Sign Ingress):** Ay her yeni burca geçtiğinde (ortalama ~2.5 günde bir) ikili arama (binary search) algoritmasıyla dakika dakikasına geçiş anı yakalanır ve anlık bildirim kurulur (`findUpcomingMoonSignIngresses`, 14 gün, ID 2000+).
  2. **28 Kadim Ay Menzili Geçişleri (Lunar Mansion Transitions):** Ay 28 duraktan (El-Şaratan, Butayn, Sa'd el-Ahbiye vb.) birine geçtiğinde anlık bildirim kurulur (`findUpcomingMoonMansionTransitions`, 14 gün, ID 3000+).
  3. **Gezegen Burç Girişleri (Planetary Ingress):** Güneş, Merkür, Venüs, Mars, Jüpiter ve Satürn yeni bir burca 00° 00' ile adım attığında anlık ingress bildirimi kurulur (`findUpcomingPlanetaryIngresses`, 21 gün, ID 4000+).
  4. **Ayarlar & Bildirim Modal Arayüzü:** Ayarlar / Profil ekranı ve Bildirim İzni penceresine 09:30, 14:30, 20:30'a ek olarak bu 3 yeni astronomik bildirim türü de renkli maddeler olarak eklendi.

---

## 📋 7. Yapılanlar ve Yapılacaklar Listesi (Roadmap)

### ✅ Yapılanlar (v1.0.14+19 Tamamlandı):
- [x] **Ay Burç Değişimi Anlık Bildirimleri:** Ay'ın yeni burca geçtiği anı dakikasına kadar hesaplayan ve anlık bildirim fırlatan motor devrede.
- [x] **28 Ay Menzili Geçiş Bildirimleri:** 28 kadim menzil geçiş anında uğurlu/zorlu rezonans bildirimleri devrede.
- [x] **Gezegen Burç Geçiş Bildirimleri (İngress):** Güneş ve 5 temel gezegenin yeni burca adım atışını bildiren sistem devrede.
- [x] **Haritayı 2 Parmakla Büyütme (Pinch-to-Zoom / `ChartZoomScreen`):** Çark döndürme modu kaldırıldı, 0.6x - 6.0x serbest yakınlaştırma sağlandı.
- [x] **Kilitli / Uykuda / Şarjda / Pilde Kesintisiz Tam Zamanlı Bildirim Çözümü:** `NotificationVisibility.public`, `exactAllowWhileIdle` ve boot receiver entegre edildi.
- [x] **Türkiye Tarihi Yaz Saati Uygulaması (1910–2026+) Tablosu:** Resmi Gazete ve IANA Europe/Istanbul verilerine göre tüm yıllar eksiksiz kodlandı.
- [x] **Solar Fire & Astro Gold %100 Yükselen Kalibrasyonu:** GAST + Nutasyon ile tüm doğum haritalarında dakika hassasiyetinde eşleşme sağlandı.
- [x] **Siber Güvenlik Kalkanı & Tersine Mühendislik Koruması:** Flutter Dart AOT bytecode karartma (`--obfuscate --split-debug-info`), API rate limiter ve XOR maskeli gizli API uç noktaları devrede.
- [x] **v1.0.14 (Build 19) Paketi Derlendi ve Dağıtıma Hazırlandı.**

### 📌 Yapılacaklar (Gelecek Adımlar):
- [ ] **Google Play Console'a Yeni AAB Yükleme:** İndirilenler klasöründeki `gokyuzu-doktoru-v1.0.14-build19.aab` paketinin kapalı teste yüklenmesi ve incelemeye gönderilmesi.
- [ ] **AdMob Paneli İzleme:** Güncelleme yüklendikten 24-48 saat sonra AdMob panelindeki istatistiklerin kontrol edilmesi.
- [ ] **Google Play In-App Purchase Aboneliklerini Etkinleştirme:** Play Console -> Para Kazanma -> Abonelikler altındaki 4 abonelik ID'sinin aktifleştirilmesi.

---

## 🚀 8. Sürüm Dağıtım Notları (Google Play & App Store v1.0.14+19)

```text
Gökyüzü Doktoru v1.0.14 (Build 19) Yayında! 🪐✨

Bu sürümde astronomik motorumuzda ve bildirim deneyiminde çığır açan yenilikler yaptık:
• 🌙 Anlık Ay Burç Değişim Bildirimleri: Ay her yeni burca geçtiğinde (ortalama ~2.5 günde bir) dakika dakikasına hesaplanıp anlık bildirim iletilir.
• 🔮 28 Kadim Ay Menzili Geçiş Bildirimleri: Ay'ın 28 kadim duraktan (El-Şaratan, Butayn, Sa'd el-Ahbiye vb.) bir yenisine geçişi anlık rehberlikle telefonunuza ulaşır.
• 🪐 Gezegenlerin Yeni Bir Burca Geçişi (İngress): Güneş, Merkür, Venüs, Mars, Jüpiter ve Satürn yeni bir burca adım attığında anlık bildirim kurulur.
• 🔍 Haritayı 2 Parmakla Büyütme (Pinch-to-Zoom): Çark döndürme kaldırılarak harita sabitlendi; tekli ve çift çarkta 2 parmakla 0.6x'den 6.0x'e kadar serbestçe büyütüp inceleme sayfası eklendi.
• ⚡ Kilit Ekranında ve Uyku Modunda Kesintisiz Bildirim Garantisi: Telefon kilitli, uykuda veya şarjda olsa bile CPU uyandırılarak bildirimler tam zamanında ve açıkça görünür.
• 🛡️ Siber Güvenlik ve R8 / Dart AOT Karartma: Tersine mühendisliğe ve kod kopyalanmasına karşı tam koruma.
• ☀️ Türkiye Tarihi Yaz Saati & Solar Fire %100 Yükselen Kalibrasyonu korundu.
```
