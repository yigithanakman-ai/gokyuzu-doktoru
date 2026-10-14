# 🪐 GÖKYÜZÜ DOKTORU - PROJE ANA HAFIZA VE AKTARIM BELGESİ (MASTER CONTEXT)

> **⚠️ YENİ YAPAY ZEKÂ / AJAN İÇİN KRİTİK TALİMAT:**  
> Bu belge, **Gökyüzü Doktoru (Sky Doctor)** projesinin A'dan Z'ye tüm hafızasını, mimarisini, iş modellerini, kod yapısını, sunucu konfigürasyonlarını ve patronun beklentilerini içerir.  
> Yeni bir sohbet oturumuna geçtiğinde veya yeni bir yapay zekâ modeli devreye girdiğinde bu belgeyi okuyarak projeye sıfır bilgi kaybıyla, sanki en başından beri geliştiren senmişsin gibi devam etmelisin.

---

## 1. 🎯 PROJE VİZYONU VE TEMEL BİLGİLER
* **Uygulama Adı:** Gökyüzü Doktoru (Kozmik Astroloji, Numeroloji & Yapay Zekâ Rehberi)
* **Kullanıcı / Kurucu:** Yiğithan Akman (Sistemde kendisine samimi ve saygılı şekilde **"Patron" 👑** olarak hitap edilir).
* **Temel Amaç:** Kullanıcıların doğum verileri üzerinden milisaniyelik hassasiyette doğum haritası, kadim numeroloji matrisi, günlük gökyüzü transitleri ve ileri seviye öngörü astrolojisi (Solar Return, Sinastri, Firdaria vb.) sunan lüks, modern bir mobil platform.
* **Tasarım Dili:** Koyu Kozmik / Obsidyen Gece Mavisi (`#0F0C1B`), Parlayan Yıldız Altını (`#E5A93C`), Nane Yeşili (`#7AE2CF`), Pastel Lavanta (`#C8B6FF`) ve Glassmorphism (Buzlu Cam) kart mimarisi.

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
│   │   │       ├── storage_service.dart      # VIP seviyeleri, profil, yerel önbellek
│   │   │       ├── ad_service.dart           # Akıllı reklam yöneticisi (AdMob uyumlu)
│   │   │       ├── numerology_service.dart   # Pisagor/Keldani numeroloji algoritması
│   │   │       ├── chart_calculation_service.dart # Doğum haritası matematik motoru
│   │   │       ├── predictive_astrology_service.dart # Solar Return, Sinastri vb.
│   │   │       └── pdf_report_service.dart   # 10 sayfalık PDF kitapçık üreticisi
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── onboarding_input_screen.dart # Doğum bilgisi giriş ekranı
│   │       │   ├── home_screen.dart             # Ana kontrol paneli ve VIP modülleri
│   │       │   ├── chart_detail_screen.dart     # Evler, gezegenler, açılar, taşlar, Kabala
│   │       │   └── numerology_screen.dart       # Kozmik numeroloji ekranı (Herkese açık)
│   │       └── widgets/
│   │           ├── glass_card.dart              # Buzlu cam kart efekti
│   │           ├── chart_wheel_painter.dart     # Dinamik zodyak harita çarkı çizimi
│   │           ├── solar_return_modal.dart      # Solar Return relokasyonlu modal
│   │           ├── lunar_return_modal.dart      # Ay dönüşü duygusal takvim modalı
│   │           ├── synastry_modal.dart          # İlişki uyumu (Sinastri) modalı
│   │           └── rectification_modal.dart     # Hassas doğum saati bulma aracı
│   └── pubspec.yaml                  # Flutter paket bağımlılıkları
├── 1_Iletisim_Botlari/                # Telegram, IG, WhatsApp otonom yanıtlayıcıları
├── 2_Kitapcik_Motoru/                 # Python tabanlı PDF analiz motorları
├── 3_YapayZeka_Beyni/                 # RAG sistemi, Google Drive vektör indeksleyici
├── 4_Zamanli_Gorevler/                # Saatlik rapor ve günlük burç cron scriptleri
├── .github/workflows/build_apk.yml    # 🚀 CI/CD Otomatik Android APK derleme hattı
└── GOKYUZU_HAFIZA_TRANSFER.md         # (Bu Belge) Master Hafıza Dokümanı
```

### 🌐 GitHub & Canlı Dağıtım Bilgileri:
* **GitHub Deposu:** `git@github.com:yigithanakman-ai/gokyuzu-doktoru.git`
* **Web Arayüzü:** `https://github.com/yigithanakman-ai/gokyuzu-doktoru`
* **GitHub Hesabı:** `yigithanakman-ai`
* **GitHub Token:** `[PATRONUN GÜVENLİ KİŞİSEL ERİŞİM TOKENİ - Ortam Değişkeni Olarak Saklanır]`
* **Doğrudan APK İndirme Linki (Release):**  
  `https://github.com/yigithanakman-ai/gokyuzu-doktoru/releases/download/v1.0.0-apk/gokyuzu-doktoru.apk`
* **GitHub Releases Sayfası:** `https://github.com/yigithanakman-ai/gokyuzu-doktoru/releases`

---

## 3. 👑 VIP ABONELİK KATMANLARI VE MONETİZASYON PLANI

Uygulamada tek seferlik VIP tamamen kaldırılmış, aylık ve yıllık sürdürülebilir gelir modeli kurulmuştur.

| Paket | Fiyat | Dahil Olan Özellikler |
| :--- | :--- | :--- |
| **Ücretsiz (Standart)** | `0 ₺` | Tam Doğum Haritası (Evler, Gezegenler, Açılar, Çark), Kozmik Numeroloji Matrisi, Günlük Ay Fazı & Canlı Transitler. Reklam gösterimi mevcuttur. |
| **Silver VIP** | `179 ₺/ay` (~$5) | %100 Reklamsız + Ayda 1 Adet 10 Sayfalık Kapsamlı PDF Rapor İndirme. (İleri VIP analizleri kilitlidir). |
| **Gold VIP** | `319 ₺/ay` (~$9) | Silver'daki her şey + Ayda 2 PDF İndirme + **Sinastri (İlişki Uyumu)** + **Lunar Return (Ay Döngüleri)** + **Majör Gezegensel Yaşam Döngüleri** (29.5 Yaş Satürn Dönüşü, Jüpiter 12 yıl, Uranüs Karşıtlığı, Chiron). |
| **Platinum VIP (Aylık)** | `459 ₺/ay` (~$13) | **Tüm Modüller Açık:** Solar Return (Yıllık Öngörü & Relokasyon), İkincil İlerletimler (Secondary Progressions), Solar Arc, Firdaria (Fars Gezegen Dönemleri), Yıllık Profection, Zodiacal Releasing, Rektifikasyon (Saat Doğrulama), Gölge Harita ve Sınırsız PDF İndirme. |
| **Platinum VIP (Yıllık İndirimli)** | `4.199 ₺/yıl` (Aylık 10$ hesabıyla) | Platinum'daki tüm özellikler + Yıllık özel indirim rozetiyle sunulur. |

### 💡 Mağaza Fiyat Esnekliği Kuralı:
* Bu fiyatlar Google Play Console ve Apple App Store Connect mağaza panellerinden **uygulamaya yeni güncelleme göndermeden istenildiği an tek tıkla güncellenebilir.**

### 🔑 Gizli VIP Geliştirici Kodu:
* Ana sayfadaki profil fotoğrafına peş peşe **5 kez tıklandığında** gizli şifre penceresi açılır.
* Şifre: **`gkyz2453`**
* Bu şifre girildiğinde kullanıcı otomatik olarak **Platinum VIP (Tam Yetkili)** mertebesine yükselir ve tüm özellikler anında kilitsiz hale gelir.

---

## 4. 📢 AKILLI REKLAM SİSTEMİ MANTIĞI (`ad_service.dart`)
* **VIP Üyelere:** İster Silver, ister Gold, ister Platinum olsun; reklam gösterimi **%100 kapatılır.**
* **Sekmeler Arası Reklam (Interstitial):** Tam Doğum Haritası sekmeleri (Gezegenler, Evler, Açılar, Harita Çarkı) arasında her tıkta reklam çıkmaz. Kullanıcıyı boğmamak ve uygulamayı sildirmemek için **yalnızca her 4 sekme geçişinde bir (`_tabSwitchCounter % 4 == 0`)** kibar bir geçiş reklamı tetiklenir.
* **Açılış Reklamı (App Open):** Uygulama her açıldığında reklam çıkmaz; en az **10 dakikalık zaman aşımı (cooldown)** kuralı vardır.
* **Altyapı:** Google AdMob resmi test ID'leri tanımlıdır, canlı AdMob hesabına geçildiğinde doğrudan ID'ler değiştirilebilir.

---

## 5. 🔢 KOZMİK NUMEROLOJİ MOTORU (`numerology_service.dart`)
* **Erişim:** **HERKESE AÇIKTIR** (Ücretsiz ve VIP tüm kullanıcılar faydalanır).
* **Hesaplanan Değerler:**
  1. **Yaşam Yolu Sayısı (Life Path):** Doğum tarihi toplamı (1-9 ile 11, 22, 33 Üstat Sayılar). Yönetici gezegen, aura rengi, ışık güçleri ve gölge tuzaklar.
  2. **Kader / İsim Sayısı (Destiny):** Pisagor Türkçe harf matrisi (Ç, Ğ, İ, Ö, Ş, Ü uyumlu).
  3. **Ruh Güdüsü (Soul Urge):** İsimdeki sesli harfler üzerinden ruhun gerçek arzusu.
  4. **Kişilik Sayısı (Personality):** Sessiz harfler üzerinden dış dünyaya yansıyan sosyal maske.
  5. **2026 Kişisel Yıl Döngüsü:** 2026 yılı için kullanıcının içinde bulunduğu 9 yıllık döngü aşaması ve yıllık kehanet.

---

## 6. 📱 MOBİL DİKEY EKRAN (RESPONSIVE) TASARIM KURALLARI
Geçmişte yaşanan ekran taşmaları tamamen çözülmüştür. Gelecekte kod yazarken şu kurallara **kesinlikle uyulmalıdır:**
1. **Asla çıplak `Row` içine uzun `Text` koyma:** `Row` içindeki metin alanları her zaman `Expanded` veya `Flexible` ile sarılmalıdır.
2. **Kart Başlıkları ve Rozetler:** `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)` kullanılırken başlık `Expanded` içine alınmalı, sağdaki rozet (`Container`) ile arasına `const SizedBox(width: 8)` konulmalı ve `crossAxisAlignment: CrossAxisAlignment.start` verilmelidir.
3. **Doğal Taşlar ve Sephira Kartları:** `crystal.turkishName` veya `s.turkishName` gibi uzun metinler `maxLines: 2` ve `TextOverflow.ellipsis` ile desteklenmelidir; böylece "HARİTANDA AKTİF" gibi rozetler kartın dışına taşmaz.

---

## 7. 🎨 MARKA VE GRAFİK VARLIKLARI (BRANDING ASSETS)
Uygulama için yapay zekâ tarafından üretilen resmi yüksek çözünürlüklü görseller:
1. **Google Play Store / Vitrin Afişi (16:9):**  
   Altın kadim usturlap, holografik zodyak çarkı, şifacı hekim kanatlı asası (caduceus), aurora borealis ve derin galaksi ışıltıları.  
   *(Dosya: `gokyuzu_doktoru_banner_1791934685860.jpg`)*
2. **Lüks Mobil Uygulama İkonu (1:1):**  
   Obsidyen koyu zemin üzerinde altın güneş, hilal, kanatlı hekim asası ve kutsal geometri yıldızları.  
   *(Dosya: `gokyuzu_app_icon_1791934705907.jpg`)*

---

## 8. 🌐 BULUT SUNUCUSU VE ARKA PLAN BOTLARI (GCP VM)
* **GCP Proje ID:** `gen-lang-client-0557106544`
* **Compute Engine VM:** `gokyuzu-bot-vm` (Bölge: `europe-west4-a`)
* **Kullanıcı:** `yigithanakman`
* **Uzak Proje Dizini:** `/home/yigithanakman/app/`
* **Aktif systemd Servisleri:**
  * `telegramcustomer.service` (Müşteri botu)
  * `telegramagent.service` (Ajan/Yönetici botu)
  * `whatsapp.service` (WhatsApp VIP iletişim botu)
* **Zamanlanmış Görevler (Cron):**
  * `hourly_reporter.py` (Her saat başı gökyüzü raporu)
  * `daily_horoscope.py` (Her sabah 06:00 günlük burç yorumu)
  * `send_reminders.py` (Takip ve hatırlatıcılar)
* **RAG Bilgi Bankası (Astroloji Arşivi):**
  * 1450+ kitap/doküman Google Drive üzerinden taranıp `processed_files.db` (SQLite) içine `gemini-embedding-2` modeliyle indekslenmektedir.

---

## 9. 📞 İLETİŞİM, DESTEK VE SOSYAL MEDYA BİLGİLERİ
* **Kurumsal Destek E-postası:** `yigithanakman@gokyuzudoktoru.com`
* **WhatsApp VIP Danışmanlık:** `+90 552 255 08 10`
* **Resmi Instagram:** `@yigithan.akman` (`https://instagram.com/yigithan.akman`)
* **Telegram Destek Botu:** `@destek_bot`
* **Telegram Yönetici Chat ID:** `6925060630`

---

## 10. 🛠️ GELİŞTİRME VE DAĞITIM TALİMATLARI (DEV RUNBOOK)

### 📲 Yeni Bir APK Derlemesi Nasıl Başlatılır?
1. Kodlarda değişiklik yapıldıktan sonra yerel testler tamamlanır.
2. Değişiklikler git'e eklenir:
   ```bash
   git add .
   git commit -m "feat: Yapılan yenilik açıklaması"
   ```
3. GitHub'a push edilir (Sandbox ağ kısıtı nedeniyle `BypassSandbox: true` ile):
   ```bash
   git push origin main
   ```
4. GitHub Actions (`.github/workflows/build_apk.yml`) otomatik olarak Ubuntu üzerinde:
   * Java 17 kurar.
   * Flutter Stable kurar.
   * `flutter pub get` çalıştırır.
   * `flutter build apk --release --no-tree-shake-icons` ile APK'yı derler.
   * Üretilen `gokyuzu-doktoru.apk` dosyasını `v1.0.0-apk` release etiketine yükler.
5. Kullanıcı telefonundan doğrudan release linkine basarak güncel APK'yı indirir.

---

### 👑 Patron ile Çalışma İlkeleri:
* Samimi, enerjik, hürmetli ve daima çözüm üreten bir üslup benimse.
* Asla lafı uzatma; yapılan işi özetle, linkleri ve aksiyon adımlarını açıkça sun.
* Patron onay vermeden veritabanı veya sunucuda yıkıcı/geri dönüşsüz işlem yapma.
* Sistemin pürüzsüz, hatasız ve lüks bir deneyim sunması en yüksek önceliktir.
