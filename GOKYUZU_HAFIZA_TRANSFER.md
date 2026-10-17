# 🪐 GÖKYÜZÜ DOKTORU - PROJE ANA HAFIZA VE AKTARIM BELGESİ (MASTER CONTEXT)

> **⚠️ YENİ YAPAY ZEKÂ / AJAN İÇİN KRİTİK TALİMAT:**  
> Bu belge, **Gökyüzü Doktoru (Sky Doctor)** projesinin A'dan Z'ye tüm hafızasını, mimarisini, iş modellerini, kod yapısını, matematiksel motorlarını, sunucu konfigürasyonlarını ve patronun beklentilerini içerir.  
> Yeni bir sohbet oturumuna geçtiğinde veya yeni bir yapay zekâ modeli devreye girdiğinde bu belgeyi okuyarak projeye sıfır bilgi kaybıyla, sanki en başından beri geliştiren senmişsin gibi devam etmelisin.

---

## 1. 🎯 PROJE VİZYONU VE TEMEL BİLGİLER
* **Uygulama Adı:** Gökyüzü Doktoru (Sky Doctor)
* **Kullanıcı / Kurucu:** Yiğithan Akman (Sistemde kendisine samimi ve saygılı şekilde **"Patron" 👑** olarak hitap edilir).
* **Temel Amaç:** Kullanıcıların doğum verileri üzerinden milisaniyelik hassasiyette Jeosantrik Placidus doğum haritası, kadim numeroloji matrisi, günlük gökyüzü transitleri, tutulma döngüleri ve ileri seviye öngörü astrolojisi (Solar Return, Sinastri, Firdaria vb.) sunan lüks, modern bir mobil platform.
* **Tasarım Dili:** Koyu Kozmik / Obsidyen Gece Mavisi (`#0F0C1B` / `#0D0A14`), Parlayan Yıldız Altını (`#FFD166` / `#E5A93C`), Nane Yeşili (`#7AE2CF`), Pastel Lavanta (`#C8B6FF`) ve Glassmorphism (Buzlu Cam) kart mimarisi.
* **Mevcut Sürüm:** `1.0.3+4` (VersionName: `1.0.3`, VersionCode: `4`)

---

## 2. 📁 PROJE KLASÖR YAPISI VE REPOLAR

### 📍 Lokal Çalışma Alanı: `/Users/yigithanakman/Desktop/Gökyüzü_YapayZeka_Sistemi/`
```text
Gökyüzü_YapayZeka_Sistemi/
├── gokyuzu_app/                       # 📱 ANA FLUTTER MOBİL UYGULAMASI
│   ├── lib/
│   │   ├── core/constants/           # Renk paleti (app_colors.dart), temalar
│   │   ├── data/
│   │   │   ├── models/               # Gezegen, ev, açı, burç ve profil modelleri
│   │   │   └── services/
│   │   │       ├── storage_service.dart          # VIP seviyeleri, profil, yerel önbellek
│   │   │       ├── app_translation_service.dart  # TR, EN, JA %100 gömülü çeviri motoru
│   │   │       ├── astrology_engine.dart         # Jeosantrik doğum haritası hesaplama motoru
│   │   │       ├── sky_transits_service.dart     # Canlı gökyüzü efemeris & transit servisi
│   │   │       ├── astro_bulletin_service.dart   # Günlük/haftalık burç & kozmik bülten servisi
│   │   │       ├── eclipses_service.dart         # 2026-2030 Placidus ev kasp tabanlı tutulma analizi
│   │   │       ├── predictive_astrology_service.dart # Placidus kasplar, Solar Return, Sinastri vb.
│   │   │       ├── ad_service.dart               # AdMob reklam yöneticisi
│   │   │       ├── notification_service.dart     # Kozmik bildirim altyapısı
│   │   │       ├── numerology_service.dart       # Pisagor/Keldani numeroloji algoritması
│   │   │       └── pdf_report_service.dart       # 10 sayfalık PDF kitapçık üreticisi
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── splash_screen.dart            # Açılış ve dil seçim ekranı
│   │       │   ├── onboarding_input_screen.dart # Doğum bilgisi ve KVKK onay ekranı
│   │       │   ├── home_screen.dart             # Ana kontrol paneli, günlük enerji & VIP modülleri
│   │       │   ├── chart_detail_screen.dart     # Evler, gezegenler, açılar, taşlar, Kabala
│   │       │   ├── numerology_screen.dart       # Kozmik numeroloji ekranı (Herkese açık)
│   │       │   └── profile_screen.dart          # Profil, dil değişimi ve ayarlar
│   │       └── widgets/
│   │           ├── glass_card.dart              # Buzlu cam kart efekti
│   │           ├── chart_wheel_painter.dart     # Dinamik zodyak harita çarkı çizimi
│   │           ├── astro_bulletin_section.dart  # Yükselen odaklı 12 burç bülteni & modalleri
│   │           ├── eclipses_academy_view.dart   # Tutulmalar & Saros Akademisi
│   │           ├── personal_eclipses_counseling_sheet.dart # Kişisel tutulma rehberliği
│   │           ├── solar_return_modal.dart      # Solar Return relokasyonlu modal
│   │           ├── lunar_return_modal.dart      # Ay dönüşü duygusal takvim modalı
│   │           ├── synastry_modal.dart          # İlişki uyumu (Sinastri) modalı
│   │           └── rectification_modal.dart     # Hassas doğum saati bulma aracı
│   └── pubspec.yaml                  # Flutter paket bağımlılıkları (1.0.3+4)
├── docs/                             # 🌐 GITHUB PAGES YASAL VE GİZLİLİK MERKEZİ (index.html)
├── store_assets/                     # 🎨 MAĞAZA GÖRSELLERİ (512x512 ikon, ekran görüntüleri)
├── .github/workflows/build_apk.yml    # 🚀 CI/CD Otomatik Android APK derleme hattı
├── GOKYUZU_HAFIZA_TRANSFER.md         # (Bu Belge) Master Hafıza Dokümanı
└── GOKYUZU_DOKTORU_PROJE_DURUMU.md    # Master Yayın ve Durum Raporu
```

### 🌐 GitHub & Canlı Dağıtım Bilgileri:
* **GitHub Deposu:** `git@github.com:yigithanakman-ai/gokyuzu-doktoru.git`
* **Web Arayüzü:** `https://github.com/yigithanakman-ai/gokyuzu-doktoru`
* **Aktif Dal:** `main` (Son commit: `6a9cab3` - 76 dosya senkronize edildi)
* **GitHub Pages Canlı URL:** `https://yigithanakman-ai.github.io/gokyuzu-doktoru/` (Google Play & App Store Yasal Merkezi)

---

## 3. 📐 ASTROLOJİK HESAPLAMA MOTORLARI & MATEMATİKSEL İLKELER

1. **Jeosantrik (Yer Merkezli) Placidus Sistemi:**
   - Tüm doğum haritaları ve ev girişleri (`House Cusps`) kullanıcının enlem, boylam, doğum tarihi ve doğum saatine göre Placidus yönteminde hesaplanır.
   - Gece/Gündüz haritası ayrımı (`Sect`), kıstırılmış burçlar (`Intercepted Signs`) tam doğrulukla tespit edilir.
2. **Efemeris Harmonizasyonu (Solar Fire / Astro Gold Standardı):**
   - Chiron, Jüpiter, Satürn, Uranüs, Neptün, Plüton ve Ay Düğümleri tek bir merkezden (`SkyTransitsService` ve `AstrologyEngine`) hesaplanır.
   - Chiron anlık olarak Koç burcunun retro derecesindedir (`28°46' Retro Koç`).
   - Venüs-Plüton karesi ve Jüpiter-Chiron sekstili gibi majör açılar ±5° orb aralığıyla kesin efemeris gününde gösterilir.
3. **Astro Bülten & Günlük Yorumlar (Yükselen Burç Önceliği):**
   - Günlük ve haftalık burç yorumları kullanıcının **Yükselen Burcuna (Ascendant)** göre varsayılan olarak açılır.
   - 12 burç seçicisinin üzerine şu uyarı notu yerleştirilmiştir:
     > *"Burç yorumları öncelikle Yükselen burcunuza göre takip edilmelidir. Yükselen burcunuzu bilmiyorsanız Güneş burcunuzu baz alabilirsiniz."*
   - Burç çiplerinde `YÜKSELEN` ve `GÜNEŞ` rozetleri bulunur ve burç isimleri seçili dile (TR, EN, JA) göre dinamik çevrilir.
4. **Tutulma Ev Hesabı (Placidus Kasp Çözümü):**
   - Tutulmalar Whole Sign basitliğiyle değil, haritanın gerçek Placidus ev çizgilerine (`cusps[h]` ile `cusps[h+1]`) göre yerleştirilir.
   - Örneğin; 4. Ev girişi 14° Aslan olan bir kişinin 20° Aslan'daki tutulması kesinlikle **4. Ev (4. Ev - 10. Ev Aksı)** olarak analiz edilir.

---

## 4. 🌍 ÇOKLU DİL MOTORU (TR, EN, JA — %100 GÖMÜLÜ)
* **Servis:** `gokyuzu_app/lib/data/services/app_translation_service.dart`
* **Diller:** Türkçe (`tr`), İngilizce (`en`), Japonca (`ja`).
* **Özellikler:**
  - Uygulama ilk açılışta veya Profil sayfasında dil değiştirildiğinde, `currentLangNotifier` aracılığıyla tüm uygulama anında ve yeniden başlatma gerektirmeden seçilen dile geçer.
  - Gezegen isimleri, burçlar, evler, açılar, elementler, nitelikler, butonlar, modallar ve yasal bildirimler her 3 dilde eksiksiz çevrilmiştir.

---

## 5. 💻 CİHAZ UYUMLULUĞU: MACBOOK, IPAD, TABLET, KATLANABİLİR VE MOBİL (TAM GENİŞLİK VE ESNEK TASARIM)
* **Kısıtlamasız Doğal Tasarım:** Daraltıcı `maxWidth: 600` kaset kısıtı tamamen kaldırılmıştır.
* **Tam Ekran Deneyimi:** MacBook (macOS), iPad, Android tabletler ve katlanabilir cihazlarda uygulama ekranın tüm genişliğini doğal olarak kullanır; siyah boşluklar veya minik bir telefon kasetine sıkışma yaşanmaz.
* **Esnek ve Akıcı Yerleşim:** Tüm kartlar ve listeler cihazın sunduğu geniş alana ferah bir şekilde yayılır.

---

## 6. 👑 VIP ABONELİK KATMANLARI VE MONETİZASYON PLANI

| Paket | Fiyat | Dahil Olan Özellikler |
| :--- | :--- | :--- |
| **Ücretsiz (Standart)** | `0 ₺` | Tam Doğum Haritası (Evler, Gezegenler, Açılar, Çark), Kozmik Numeroloji Matrisi, Günlük Ay Fazı & Canlı Transitler. |
| **Silver VIP** | `179 ₺/ay` (~$5) | %100 Reklamsız + Ayda 1 Adet 10 Sayfalık Kapsamlı PDF Rapor İndirme. |
| **Gold VIP** | `319 ₺/ay` (~$9) | Silver'daki her şey + Ayda 2 PDF İndirme + **Sinastri (İlişki Uyumu)** + **Lunar Return (Ay Döngüleri)** + **Majör Gezegensel Yaşam Döngüleri**. |
| **Platinum VIP (Aylık)** | `459 ₺/ay` (~$13) | **Tüm Modüller Açık:** Solar Return, İkincil İlerletimler (Secondary Progressions), Solar Arc, Firdaria, Yıllık Profection, Zodiacal Releasing, Rektifikasyon, Gölge Harita ve Sınırsız PDF. |
| **Platinum VIP (Yıllık İndirimli)** | `4.199 ₺/yıl` | Platinum'daki tüm özellikler + Yıllık özel indirim rozetiyle sunulur. |

### 🔑 Gizli VIP Geliştirici Kodu:
* Ana sayfadaki profil fotoğrafına peş peşe **5 kez tıklandığında** gizli şifre penceresi açılır.
* Şifre: **`gkyz2453`** (Kullanıcıyı anında yetkili Platinum VIP yapar).

---

## 7. 📢 REKLAM SİSTEMİ MANTIĞI (`ad_service.dart`)
* **VIP Üyelere:** Reklam gösterimi **%100 kapatılır.**
* **Sekmeler Arası Reklam (Interstitial):** Yalnızca her 4 sekme geçişinde bir (`_tabSwitchCounter % 4 == 0`) geçiş reklamı gösterilir.
* **Açılış Reklamı (App Open):** En az **10 dakikalık zaman aşımı (cooldown)** kuralı vardır.

---

## 8. 📜 GOOGLE PLAY VE APPLE APP STORE UYUMLULUK VE POLİTİKALARI
1. **Hedef SDK:** `targetSdk = 36` (Android 15 gereksinimi tam karşılandı), `compileSdk = 36`, `minSdk = 21`.
2. **Yasal Merkez (Privacy & Terms):** `https://yigithanakman-ai.github.io/gokyuzu-doktoru/` canlı ve yayındadır.
3. **KVKK Onayı:** Giriş ekranında checkbox ekranın en altına, ana butonun üstüne alınmıştır.
4. **Kod Kalitesi:** `dart analyze lib/` çıktısı: **0 Hata (No errors)**.
5. **Otomatik Testler:** `test/predictive_astrology_test.dart` içindeki Placidus ve tutulma testleri %100 geçmektedir.

---

## 9. 🗺️ MEVCUT DURUM VE SIRADAKİ ADIMLAR (YOL HARİTASI)

1. **Kapalı Test İnceleme Onayı:**  
   Google Play Console'daki Kapalı Test (Closed Testing) incelemesinin tamamlanması bekleniyor.
2. **20 Test Kullanıcısının Girişi:**  
   Onay geldiğinde 20 kullanıcının Gmail adresi listeye eklenecek ve resmi davet linki gönderilecek:  
   👉 `https://play.google.com/apps/testing/com.gokyuzudoktoru.gokyuzu_app`
3. **14 Günlük Süreç:**  
   20 kullanıcının uygulamayı 14 gün cihazlarında tutması sağlanacak.
4. **Üretime Çıkış:**  
   14 gün bitiminde "Üretime Sun" butonu ile dünya geneline yayınlanacak.
