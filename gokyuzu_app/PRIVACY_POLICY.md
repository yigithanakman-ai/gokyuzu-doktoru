# Gökyüzü Doktoru — Gizlilik Politikası ve KVKK Aydınlatma Metni

**Son Güncelleme:** 15 Ekim 2026  
**Uygulama Adı:** Gökyüzü Doktoru  
**Paket Adı:** `com.gokyuzudoktoru.gokyuzu_app`  
**Sürüm:** 1.0.0+1  

Bu Gizlilik Politikası, **Gökyüzü Doktoru** mobil uygulamasını ("Uygulama") kullanan tüm kullanıcılarımızın kişisel verilerinin 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK"), Avrupa Birliği Genel Veri Koruma Tüzüğü ("GDPR") ve Google Play Geliştirici Programı Politikaları uyarınca nasıl toplandığını, işlendiğini, saklandığını ve korunduğunu açıklar.

---

## 1. Veri Sorumlusu

- **Veri Sorumlusu:** Yiğithan Akman (Gökyüzü Doktoru)
- **İletişim & Destek E-posta:** [yigithanakman@gokyuzudoktoru.com](mailto:yigithanakman@gokyuzudoktoru.com)
- **Resmi Web Sitesi:** [https://gokyuzudoktoru.com](https://gokyuzudoktoru.com)

---

## 2. Toplanan Kişisel Veriler ve İşlenme Amaçları

Gökyüzü Doktoru, kullanıcılara kişiselleştirilmiş derin astrolojik analizler, doğum haritası hesaplamaları ve gökyüzü transitleri sunabilmek amacıyla yalnızca hizmetin doğası gereği zorunlu olan sınırlı verileri işler:

1. **Astrolojik Doğum Verileri:**
   - **Doğum Tarihi ve Doğum Saati:** Geocentric ve tropikal Batı astrolojisi efemeris algoritmalarıyla gezegen derecelerini, ev çizgilerini ve yükselen burcu hesaplamak için.
   - **Doğum Yeri (Şehir, Ülke, Enlem/Boylam Koordinatları):** Kesin ev yerleşimlerini (Placidus, Whole Sign vb.) ve coğrafi zaman dilimi (Timezone / UTC offset) hesaplamalarını yapmak için.
2. **Kimlik ve Profil Bilgisi:**
   - **İsim / Rumuz:** Haritanızı kişiselleştirmek ve kayıtlı çoklu doğum haritalarını (arkadaş, aile vb.) ayırt edebilmeniz için.
   - **Cinsiyet:** Astrolojik harita kutuplaşması ve sembolik yorum zenginleştirmesi için (isteğe bağlı).
3. **İletişim Bilgileri:**
   - **E-posta Adresi:** Kullanıcı hesabı eşleme, satın alınan VIP / Pro üyeliklerin doğrulanması ve harita arşivi güvenliği için.
4. **Teknik ve Cihaz Verileri:**
   - **Cihaz Modeli ve İşletim Sistemi Sürümü:** Uygulamanın kararlı çalışması ve ekran optimizasyonu için.
   - **Anonim Hata / Çökme Günlükleri:** Olası uygulama çökmelerini gidermek amacıyla Firebase Crashlytics / Google Play Console üzerinden anonim olarak toplanır.
5. **Anlık Coğrafi Konum Verisi (GPS / Konum İzni):**
   - **Kullanım Amacı:** Kullanıcının o an bulunduğu coğrafi konuma (enlem, boylam ve saat dilimi) göre **Keldani Gezegen Saatleri (Planetary Hours)** ile **NOAA standartlarında kesin gün doğumu ve gün batımı** anlarını saniye-saniyesine hesaplamak.
   - **Gizlilik ve Güvenlik Güvencesi:** Konum verisi **kesinlikle arka planda izlenmez**, hiçbir uzak sunucuya **aktarılmaz, saklanmaz ve satılmaz**. Konum yalnızca uygulama ön plandayken ve kullanıcının açık rızasıyla cihaz üzerinde yerel olarak (`SharedPreferences`) işlenir.

---

## 3. Veri Güvenliği ve Üçüncü Taraflarla Paylaşım

- **Kişisel Veriler Satılmaz:** Kullanıcılarımıza ait hiçbir veri; ticari, reklam veya profilleme amacıyla **üçüncü taraf şirketlere, veri simsarlarına ya da reklam ajanslarına KESİNLİKLE SATILMAZ, KİRALANMAZ ve AKTARILMAZ**.
- **Cihaz Üzerinde Şifreleme:** Doğum haritası kayıtlarınız ve tercihleriniz cihazınızın güvenli yerel depolama alanında (`SharedPreferences` / `Hive` / `Encrypted Storage`) saklanır.
- **Güvenli Ödeme Altyapısı:** Uygulama içi satın alımlar (VIP / Pro üyelikler) doğrudan **Google Play Store In-App Billing (Google Play Faturalandırma Sistemi)** üzerinden gerçekleştirilir. Kredi kartı, banka kartı veya fatura bilgileriniz hiçbir zaman Gökyüzü Doktoru sunucularına iletilmez, görülmez ve saklanmaz.

---

## 4. İzinler (Permissions)

Gökyüzü Doktoru uygulaması cihazınızda yalnızca işlevsel zorunluluğu olan asgari izinleri talep eder:
- `android.permission.ACCESS_FINE_LOCATION` ve `android.permission.ACCESS_COARSE_LOCATION`: Kullanıcının anlık koordinatlarına göre yerel astronomik gezegen saatlerini ve gün doğumu/batımı döngülerini hesaplamak için (Yalnızca ön planda ve kullanıcı onayıyla).
- `android.permission.INTERNET`: Güncel efemeris ve transit gezegen verilerini almak ve VIP üyelik durumunu doğrulamak için.
- `android.permission.ACCESS_NETWORK_STATE`: Ağ bağlantısının aktif olup olmadığını kontrol etmek için.
- `com.android.vending.BILLING`: Google Play Store üzerinden VIP abonelik ve uygulama içi satın alımların güvenle işlenmesi için.
- `android.permission.POST_NOTIFICATIONS`: Kullanıcının izniyle günlük kozmik transit ve gökyüzü bildirimlerini iletmek için.
- `com.google.android.gms.permission.AD_ID`: Google AdMob reklam monetizasyonu ve sahtekarlık önleme için.

---

## 5. Çocukların Gizliliği (16 Yaş Altı Politikası)

Gökyüzü Doktoru uygulaması 16 yaşından küçük bireylerin doğrudan kullanımı için tasarlanmamıştır. 16 yaş altındaki kişilere ait doğum bilgileri yalnızca ebeveynleri veya yasal vasileri tarafından kendi sorumluluklarında harita analizi ve arşivleme amacıyla girilebilir. Ebeveyn izni olmadan 16 yaş altı bir çocuğun veri paylaştığı tespit edilirse ilgili kayıtlar derhal sistemden silinir.

---

## 6. Kullanıcı Hakları ve Veri Silme Talebi (KVKK Madde 11 / GDPR)

Kullanıcılarımız 6698 sayılı KVKK ve GDPR kapsamında aşağıdaki haklara sahiptir:
- Kişisel verilerinin işlenip işlenmediğini öğrenme,
- İşlenmişse buna ilişkin bilgi talep etme,
- Verilerin silinmesini veya yok edilmesini talep etme.

### Verilerinizi Nasıl Silebilirsiniz?
1. **Uygulama İçinden:** Uygulama içi `Profil / Ayarlar -> Verilerimi Sıfırla / Hesabımı Sil` seçeneğini kullanarak tüm yerel verilerinizi anında silebilirsiniz.
2. **E-posta Yoluyla:** Kayıtlı e-posta adresinizden [yigithanakman@gokyuzudoktoru.com](mailto:yigithanakman@gokyuzudoktoru.com) adresine *"Kişisel Verilerimin Silinmesi Talebi"* konulu bir e-posta göndererek sistemimizdeki tüm kayıtlarınızın kalıcı olarak silinmesini talep edebilirsiniz. Talebiniz en geç 48 saat içerisinde yerine getirilir.

---

## 7. Yasal ve Tıbbi Sorumluluk Reddi (Disclaimer)

> **ÖNEMLİ UYARI:**  
> Gökyüzü Doktoru uygulamasında yer alan tüm analizler, gezegen konumları, ev yorumları, transit etkileri ve içerikler; yalnızca kadim astroloji geleneklerine, sembolik gökyüzü döngülerine dayalı **kişisel farkındalık, kültürel bilgi ve eğlence amaçlıdır**.  
> Uygulamadaki hiçbir içerik **TIBBİ TEŞHİS, TIBBİ TEDAVİ, PSİKİYATRİK TERAPİ, HUKUKİ VEYA FİNANSAL YATIRIM TAVSİYESİ NİTELİĞİ TAŞIMAZ**. Sağlık problemleriniz için mutlaka yetkili bir tıp hekimine başvurunuz.

---

## 8. Politika Değişiklikleri

Bu Gizlilik Politikası zaman zaman güncellenebilir. Politikada önemli bir değişiklik yapıldığında uygulama içi bildirim veya sürüm notları aracılığıyla kullanıcılar bilgilendirilir.

---

## 9. İletişim

Gizlilik Politikamız veya kişisel verilerinizle ilgili her türlü soru, öneri ve talepleriniz için bize ulaşabilirsiniz:

- **E-posta:** [yigithanakman@gokyuzudoktoru.com](mailto:yigithanakman@gokyuzudoktoru.com)
- **Web Sitesi:** [https://gokyuzudoktoru.com](https://gokyuzudoktoru.com)
- **Geliştirici:** Yiğithan Akman (Gökyüzü Doktoru)
