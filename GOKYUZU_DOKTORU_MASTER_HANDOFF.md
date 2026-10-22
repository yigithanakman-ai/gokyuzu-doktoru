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

1. **Ay Düğümleri (True Node vs. Mean Node):** Jean Meeus formülleriyle hem Gerçek Ay Düğümü (`True Node`) hem Ortalama Ay Düğümü (`Mean Node`) ayrı ayrı hesaplanır ve kullanıcı tek dokunuşla geçiş yapabilir.
2. **Seçilebilir 9 Asteroit ve Özel Nokta:** Haritaya **Lilith, Vesta, Juno, Amor, Hekate, Isis, Vertex Noktası, Pallas, Ceres** eklendi; kullanıcı istediği noktaları filtre çipleriyle açıp kapatabilir.
3. **Astro Gold / Solar Fire Tarzı 360° Çark Tasarımı:** Hem Natal hem Transit çarklarda 12 Placidus ev giriş çizgisi (kaspları), dış halkada kasp dereceleri (`04°♑17'`), iç halkada ev numaraları (`1..12`), gezegenlerin yanında burç ve dereceleri (`11°♓04'`) ve merkezde açı sembolleri gösterilir.
4. **Evrensel Açı Orbları:** Tüm haritada (Natal, Transit-Natal, Transit-Transit) **Kavuşum (0°): 10°, Karşıt (180°): 10°, Üçgen (120°): 8°, Kare (90°): 7°, Sekstil (60°): 7°** orb kuralları standartlaştırıldı.
5. **28 Ay Menzili Kalibrasyonu & Derece Formatı:** `11° Balık` burcundaki Ay tam olarak **25. Menzil: Sa'd el-Ahbiye (Saadülahbiye)** olarak hesaplanır. Burç sınırları `00° 00' dk – 29° 59' dk` (30°) kuralına göre açık `dk` birimiyle yazıldı.
6. **Hermetik Adımların Ay Menzillerinden Ayrılması:** Hermetik Adımlar & Tılsım Rehberi, Ay Menzillerinden ayrı bir başlık, ayrı bir kart ve ayrı bir 28 adımlık rehber modalı olarak ayrıldı.
7. **Uygulamaya Girmeden Arka Plan Bildirimleri:** `SCHEDULE_EXACT_ALARM` ve `USE_EXACT_ALARM` izinleriyle gelecek 14 gün boyunca her gün 09:30, 14:30 ve 20:30 saatleri için 42 bağımsız tam zamanlı arka plan bildirimi işletim sistemine kaydedilir.
8. **Taşma (Overflow) Düzeltmeleri:** Canlı Çift Çark sekme butonu ve Dış/İç Çark bilgi rozetindeki sağdan taşmalar giderildi.
9. **AdMob Otomatik Yeniden Yükleme & Teşhis:** Başarısız reklam isteklerinde 20 saniyede bir otomatik yeniden deneme eklendi.
10. **Gizli Patron Yönetici Girişi:** VIP penceresindeki Taç (👑) simgesine 5 kez dokunularak `gkyz2453` koduyla VIP Platinum açılır.
