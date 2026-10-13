import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum LegalDocType {
  kvkk,
  privacy,
  terms,
  advertising,
  salesAndRefund,
  disclaimer,
}

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocType type;

  const LegalDocumentScreen({super.key, required this.type});

  String get _title {
    switch (type) {
      case LegalDocType.kvkk:
        return 'KVKK Aydınlatma Metni';
      case LegalDocType.privacy:
        return 'Gizlilik Politikası (Privacy Policy)';
      case LegalDocType.terms:
        return 'Kullanım Koşulları & Hizmet Şartları';
      case LegalDocType.advertising:
        return 'Çerez & Reklam Tercihleri Politikası';
      case LegalDocType.salesAndRefund:
        return 'Mesafeli Satış & İptal İade Koşulları';
      case LegalDocType.disclaimer:
        return 'Yasal Sorumluluk Reddi (Disclaimer)';
    }
  }

  String get _subtitle {
    switch (type) {
      case LegalDocType.kvkk:
        return '6698 Sayılı Kişisel Verilerin Korunması Kanunu Kapsamında Bilgilendirme';
      case LegalDocType.privacy:
        return 'Kişisel Verilerinizin Güvenliği ve İşlenmesine İlişkin İlkeler';
      case LegalDocType.terms:
        return 'Uygulama Kullanım Kuralları, Fikri Mülkiyet ve Hizmet Şartları';
      case LegalDocType.advertising:
        return 'Ödüllü Reklamlar, Cihaz Tanımlayıcıları ve Veri Koruma Standartları';
      case LegalDocType.salesAndRefund:
        return '6502 Sayılı Tüketici Kanunu Kapsamında Cayma Hakkı İstisnası ve İptal Şartları';
      case LegalDocType.disclaimer:
        return 'Öz Farkındalık ve Eğlence Amacı • Tıbbi, Hukuki veya Yatırım Tavsiyesi Değildir';
    }
  }

  List<Map<String, String>> get _sections {
    switch (type) {
      case LegalDocType.kvkk:
        return [
          {
            'title': '1. Veri Sorumlusunun Kimliği',
            'body':
                '6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca, Gökyüzü Yapay Zeka & Astroloji Sistemi ("Uygulama") tarafından toplanan kişisel verileriniz, veri sorumlusu sıfatıyla korunmakta ve işlenmektedir.',
          },
          {
            'title': '2. İşlenen Kişisel Verileriniz',
            'body':
                'Uygulamamızı kullanırken sağladığınız;\n• Kimlik Verileri: Ad, soyad, rumuz ve cinsiyet bilgisi.\n• Doğum Bilgileri: Doğum tarihi, kesin doğum saati, doğum yeri (ülke ve şehir) ve coğrafi enlem/boylam koordinatları.\n• İletişim Verileri: E-posta adresi (üyelik ve arşiv senkronizasyonu için).\n• Harita & Tercih Verileri: Hesaplanan doğum haritası gezegen konumları, açılar, notlar ve arşivlenmiş profiller.',
          },
          {
            'title': '3. Kişisel Verilerin İşlenme Amaçları',
            'body':
                'Kişisel verileriniz aşağıdaki amaçlarla sınırlı olarak işlenmektedir:\n• Geocentric ve Placidus efemeris algoritmaları üzerinden kişiselleştirilmiş doğum haritası, yükselen burç ve gezegen transitlerinin hesaplanması.\n• Solar Return, Lunar Return, İkincil İlerletim ve Rektifikasyon gibi astrolojik hesaplamaların yapılması.\n• VIP üyelik ve arşivleme özelliklerinin kişiye özel olarak sunulması.\n• Yasal mevzuattan kaynaklanan bilgi saklama ve güvenlik yükümlülüklerinin yerine getirilmesi.',
          },
          {
            'title': '4. Verilerin Aktarımı ve Üçüncü Taraflar',
            'body':
                'Kişisel verileriniz, astrolojik doğum bilgileriniz ve haritanız KESİNLİKLE hiçbir ticari amaçla satılmaz, pazarlama şirketleriyle paylaşılmaz ve üçüncü kişilere devredilmez. Verileriniz yalnızca güvenli yerel hafızada (cihazınızda) ve şifrelenmiş altyapıda saklanır.',
          },
          {
            'title': '5. KVKK Kapsamındaki Haklarınız (Madde 11)',
            'body':
                'KVKK\'nın 11. maddesi uyarınca veri sahipleri;\n• Kişisel verilerinin işlenip işlenmediğini öğrenme,\n• İşlenmişse buna ilişkin bilgi talep etme,\n• Amacına uygun kullanılıp kullanılmadığını öğrenme,\n• Eksik veya yanlış işlenmişse düzeltilmesini isteme,\n• Verilerin silinmesini ("Profili Sıfırla" veya hesap silme yoluyla) talep etme haklarına sahiptir.',
          },
        ];
      case LegalDocType.privacy:
        return [
          {
            'title': '1. Hangi Verileri Topluyoruz?',
            'body':
                '• Hesap Bilgileri: E-posta adresi ve şifre (şifreler şifrelenerek saklanır, bize dahi görünmez).\n'
                '• Profil ve Doğum Bilgileri: Adınız/rumuzunuz, cinsiyetiniz, doğum tarihiniz, doğum saatiniz, doğum şehriniz ve coğrafi koordinatlarınız (Placidus haritası ve efemeris için zorunludur).\n'
                '• Kullanıcı İçerikleri: Rektifikasyon geçmiş yaşam olay notları ve harita niyet metinleri.\n'
                '• Kullanım Verileri: Kayıtlı harita profilleri (arşiv), tercihler ve VIP üyelik durumu.\n'
                '• Reklam ve Cihaz Verileri: İsteğe bağlı ödüllü sponsorlu reklam izlendiğinde Google AdMob; reklam kimliği ve cihaz teknik verilerini işleyebilir.\n'
                '• Satın Alma Bilgileri: VIP aboneliği doğrudan Apple App Store veya Google Play Store üzerinden alınır. Kredi kartı ve ödeme bilgilerinize biz asla erişmeyiz.',
          },
          {
            'title': '2. Verileri Neden Kullanıyoruz?',
            'body':
                '• Kişiselleştirilmiş doğum haritası, yükselen burç ve gezegen konumlarını hesaplamak,\n'
                '• İkincil İlerletim, Solar/Lunar Return, Zodiacal Releasing ve Profeksiyon öngörü analizlerini üretmek,\n'
                '• 10 sayfalık profesyonel PDF analiz kitapçığını oluşturmak,\n'
                '• VIP abonelik, reklam ve arşivleme sistemlerini işletmek,\n'
                '• Yasal yükümlülüklere uymak ve müşteri destek taleplerini yanıtlamak.',
          },
          {
            'title': '3. Yapay Zekâ (Google Gemini AI) Kullanımı',
            'body':
                'Uygulamamız, kadim astroloji kurallarını modern yorumlarla sentezlemek amacıyla Google Gemini Yapay Zekâ altyapısından faydalanmaktadır.\n\n'
                '• Yalnızca astrolojik gezegen konumları, açılar ve harita verileri Gemini API modeline güvenli şifreli kanalla iletilir.\n'
                '• Kimlik ve doğrudan iletişim bilgileriniz modele gönderilmez.\n'
                '• Yapay zekâya sağlık, tıbbi teşhis, banka/finans şifresi gibi hassas kişisel verilerin girilmemesi kullanıcının sorumluluğundadır.\n'
                '• Yapay zekâ çıktıları bilgilendirme ve farkındalık amaçlıdır; tıbbi, hukuki veya yatırım tavsiyesi niteliği taşımaz.',
          },
          {
            'title': '4. Verilerinizi Kimlerle Paylaşıyoruz?',
            'body':
                'Kişisel verileriniz hiçbir üçüncü tarafa SATILMAZ veya kiralanmaz. Yalnızca şu zorunlu altyapı sağlayıcıları ile paylaşılır:\n\n'
                '• Apple App Store & Google Play: Abonelik doğrulama ve mağaza altyapısı.\n'
                '• Google Gemini AI: Doğum haritası yorumlarının üretilmesi için yapay zekâ motoru.\n'
                '• Google AdMob: Yalnızca ödüllü reklam gösterimleri (ücretsiz kullanıcılar için).\n'
                '• Güvenli Veritabanı ve Bulut: Verileriniz yüksek güvenlikli sunucularda şifreli saklanır.\n'
                '• Adli/Resmi Makamlar: Yalnızca yasal bir mahkeme kararı veya resmi zorunluluk halinde.',
          },
          {
            'title': '5. Reklam ve Takip İzinleri',
            'body':
                '• Google AdMob: Ücretsiz özelliklerde ödüllü reklamlar sunulur. VIP üyeler için tüm reklamlar %100 devre dışıdır.\n'
                '• iOS Uygulama Takibi (ATT): iOS cihazlarda kişiselleştirilmiş reklam için onayınız istenir. İzni dilediğiniz an Ayarlar > Gizlilik > Takip altından kapatabilirsiniz.',
          },
          {
            'title': '6. Veri Saklama Süresi',
            'body':
                '• Cihaz Verileri: Kayıtlı haritalarınız ve notlarınız uygulamayı silene kadar cihazınızda kalır.\n'
                '• Sunucu Verileri: Hesabınız aktif olduğu sürece saklanır. Hesabınızı sildiğinizde veya talep ettiğinizde 30 gün içinde tüm sistemlerden kalıcı olarak yok edilir.',
          },
          {
            'title': '7. KVKK ve GDPR Kapsamındaki Haklarınız',
            'body':
                '6698 sayılı KVKK ve AB GDPR uyarınca şu haklara sahipsiniz:\n'
                '• Hangi verilerinizin işlendiğini öğrenme ve bir kopyasını talep etme,\n'
                '• Yanlış veya eksik bilgilerin düzeltilmesini isteme,\n'
                '• Hesabınızın ve tüm verilerinizin kalıcı olarak silinmesini talep etme,\n'
                '• Otomatik kararlara ve yapay zekâ analizlerine itiraz etme.\n\n'
                'Talepleriniz için: destek@gokyuzudoktoru.com',
          },
          {
            'title': '8. Hesap ve Veri Silme (Apple 5.1.1 Uyumlu)',
            'body':
                'Apple App Store Kural 5.1.1 uyarınca, hesabınızı ve tüm verilerinizi uygulama içerisinden kolayca silebilirsiniz:\n\n'
                '• Profil sekmesindeki "Hesabımı ve Verilerimi Kalıcı Olarak Sil" butonuna tıklayarak anında silebilirsiniz.\n'
                '• Veya destek@gokyuzudoktoru.com adresine e-posta göndererek talep edebilirsiniz.\n\n'
                '⚠️ ÖNEMLİ: Uygulamadaki hesabınızı silmek, Apple App Store veya Google Play aboneliğinizi otomatik olarak iptal etmez. Aboneliğinizi cihaz ayarlarınızdan (Abonelikler menüsü) ayrıca iptal etmelisiniz.',
          },
          {
            'title': '9. Çocukların Gizliliği & Yaş Sınırı (16 Yaş Kuralı)',
            'body':
                'Uygulamamız 16 yaş altındaki kişilerin tek başına kullanımına yönelik değildir. 16 yaşından küçüklerin doğum haritaları yalnızca ebeveyn veya yasal vasileri tarafından arşivlenebilir ve kaydedilebilir. Ebeveyn izni olmadan kaydedilmiş bir veri tespit edilirse derhal silinir.',
          },
        ];
      case LegalDocType.terms:
        return [
          {
            'title': '1. Hizmetin Niteliği ve Kapsamı',
            'body':
                'Gökyüzü Yapay Zeka Sistemi; klasik ve modern Batı astrolojisi, kadim efemeris tabloları ve sembolik yaşam analizleri sunan dijital bir kişisel farkındalık platformudur.',
          },
          {
            'title': '2. Yasal Sorumluluk Reddi (Disclaimer)',
            'body':
                'Uygulama içerisinde yer alan hiçbir yorum, harita analizi, transit öngörüsü, rektifikasyon veya astrolojik hesaplama; TIBBİ, HUKUKİ, PSİKİYATRİK VEYA FİNANSAL YATIRIM TAVSİYESİ NİTELİĞİNDE DEĞİLDİR. Hayati kararlarınızda daima yetkili profesyonel hekim, uzman veya hukuk danışmanlarına başvurunuz.',
          },
          {
            'title': '3. Fikri Mülkiyet ve Telif Hakları',
            'body':
                'Uygulamada yer alan özgün algoritmalar, arayüz tasarımları, metinler, Kabala ağacı şemaları ve astroloji motoru Gökyüzü Doktoru\'na aittir. İzinsiz kopyalanamaz, çoğaltılamaz veya ticari amaçla dağıtılamaz.',
          },
          {
            'title': '4. VIP Abonelik, Cayma Hakkı İstisnası & Ücret İadesi Yapılmaması',
            'body':
                'Dijital ortamda anında teslim edilen ve ifa edilen gayri maddi haklar kapsamında (6502 sayılı Tüketicinin Korunması Hakkında Kanun ve Mesafeli Sözleşmeler Yönetmeliği Madde 15/1-ğ uyarınca), satın alınan Silver, Gold ve Platinum VIP aboneliklerinde ve dijital analiz paketlerinde KESİNLİKLE ÜCRET İADESİ YAPILMAZ. Kullanıcı ödemeyi gerçekleştirerek cayma hakkından feragat ettiğini peşinen kabul ve taahhüt eder.',
          },
          {
            'title': '5. Abonelik İptali & Otomatik Yenilemenin Kapatılması',
            'body':
                'Kullanıcı, dilediği zaman aboneliğini satın aldığı resmi mağaza üzerinden iptal edebilir:\n'
                '• Apple App Store (iOS): Cihazınızda Ayarlar > [Adınız / Apple Kimliği] > Abonelikler > Gökyüzü Doktoru > "Aboneliği İptal Et" adımlarını uygulayınız.\n'
                '• Google Play Store (Android): Google Play Store uygulaması > Profil Simgesi > Ödemeler ve Abonelikler > Abonelikler > Gökyüzü Doktoru > "Aboneliği İptal Et" adımlarını uygulayınız.\n'
                '• Abonelik iptal edildiğinde, bedeli ödenmiş olan cari fatura ve kullanım ayı/yılı sonuna kadar tüm VIP haklar eksiksiz ve kesintisiz devam eder. Dönem sonunda yeni ücret çekilmez ve abonelik otomatik olarak yenilenmez.',
          },
          {
            'title': '6. Reşit Olma ve Yaş Şartı (16 Yaş)',
            'body':
                'Bu sözleşmeyi onaylamak ve uygulama servislerinden bağımsız olarak faydalanmak için kullanıcının en az 16 yaşında olması zorunludur. 16 yaş altındaki kullanıcılar yalnızca ebeveyn onay ve denetiminde işlem yapabilir.',
          },
        ];
      case LegalDocType.advertising:
        return [
          {
            'title': '1. Reklam Modeli ve Ödüllü Gösterimler',
            'body':
                'Uygulamamızın ücretsiz özelliklerinin sürdürülebilirliğini sağlamak adına sponsorlu video reklamlar ve ödüllü gösterimler (Rewarded Ads) kullanılmaktadır.',
          },
          {
            'title': '2. Ödüllü Video Reklam Hakları',
            'body':
                'Kullanıcılar; anlık Ay fazı, boşlukta takvimi ve canlı transit gezegen konumları gibi premium verileri, kısa sponsorlu bir video reklam izleyerek 24 saat boyunca tamamen ücretsiz açabilirler. VIP üyeler için tüm reklamlar %100 devre dışıdır.',
          },
          {
            'title': '3. Reklam Ağı Gizlilik Standartları',
            'body':
                'Reklam gösterimleri Google AdMob standartlarına uygun şekilde sunulur. Doğum verileriniz ve haritanız reklam ağlarına KESİNLİKLE iletilmez.',
          },
        ];
      case LegalDocType.salesAndRefund:
        return [
          {
            'title': '1. Hizmetin Niteliği ve Anında İfa',
            'body':
                'Gökyüzü Doktoru bünyesinde sunulan VIP üyelik paketleri, rektifikasyon analizleri ve 10 sayfalık özel PDF doğum haritası kitapçıkları; elektronik ortamda anında ifa edilen dijital hizmetler ve kişiye özel gayrimaddi mallar kategorisindedir.',
          },
          {
            'title': '2. Cayma Hakkı İstisnası (6502 Sayılı Kanun Madde 15/1-ğ)',
            'body':
                '6502 sayılı Tüketicinin Korunması Hakkında Kanun ve Mesafeli Sözleşmeler Yönetmeliği\'nin 15. maddesinin 1. fıkrasının (ğ) bendi uyarınca; "Elektronik ortamda anında ifa edilen hizmetler veya tüketiciye anında teslim edilen gayrimaddi mallara ilişkin sözleşmelerde tüketici CAYMA HAKKINI KULLANAMAZ." Satın alma tamamlanıp dijital içerik veya VIP yetkisi kullanıcıya tanımlandıktan sonra ücret iadesi yapılması hukuken ve teknik olarak mümkün değildir.',
          },
          {
            'title': '3. Abonelik İptali ve Yenileme Durdurma',
            'body':
                'Kullanıcılar periyodik aboneliklerini (aylık/yıllık) diledikleri zaman bir sonraki fatura döneminden önce iptal edebilirler:\n• Apple (iOS): Ayarlar > [Apple Kimliği] > Abonelikler > Gökyüzü Doktoru > Aboneliği İptal Et\n• Google (Android): Google Play Store > Profil > Ödemeler ve Abonelikler > Gökyüzü Doktoru > Aboneliği İptal Et\nİptal durumunda mevcut dönemin sonuna kadar VIP haklar kesintisiz sürer.',
          },
          {
            'title': '4. Hatalı ve Mükerrer Çekimler',
            'body':
                'Teknik aksaklık kaynaklı mükerrer tahsilat durumunda, işlem dekontuyla birlikte destek@gokyuzudoktoru.com adresine başvurulması halinde ivedilikle inceleme yapılıp iade sağlanır.',
          },
        ];
      case LegalDocType.disclaimer:
        return [
          {
            'title': '1. Eğlence ve Öz Farkındalık Amacı',
            'body':
                'Gökyüzü Doktoru platformunda sunulan tüm gezegen konumları, ev yorumları, açılar, günlük transit bildirimleri, rektifikasyon hesaplamaları, öngörü metotları ve 10 sayfalık kitapçıklar; yalnızca sembolik kadim astroloji geleneklerine dayalı kişisel farkındalık, kültürel bilgi ve eğlence amaçlıdır.',
          },
          {
            'title': '2. Kesinlikle Tıbbi ve Psikolojik Danışmanlık Değildir',
            'body':
                'Uygulamada yer alan hiçbir ifade, burç yorumu veya element dengesi; ASLA TIBBİ TEŞHİS, TEDAVİ VEYA PSİKİYATRİK DANIŞMANLIK YERİNE GEÇMEZ. Fiziksel veya ruhsal sağlık sorunlarınızda mutlaka yetkili bir tıp doktoruna başvurunuz.',
          },
          {
            'title': '3. Hukuki ve Finansal Yatırım Tavsiyesi Değildir',
            'body':
                'Uygulamada yer alan hiçbir öngörü veya döngü analizi (retro dönemleri, tutulmalar, finansal ev yöneticilikleri vb.); YATIRIM TAVSİYESİ, BORSA ÖNGÖRÜSÜ VEYA HUKUKİ DANIŞMANLIK NİTELİĞİNDE DEĞİLDİR.',
          },
          {
            'title': '4. Kesin Gelecek Tahmini İddiası Yoktur',
            'body':
                'Astroloji olasılıklar ve kozmik sembolizmler dilidir. Uygulama, kullanıcının gelecekteki olaylarını kesin olarak bilmeyi veya kaderini mutlak surette tayin etmeyi iddia veya taahhüt etmez.',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161224),
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Top Badge Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.starlightGold.withValues(alpha: 0.15),
                    const Color(0xFF1E1A2E),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.starlightGold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppColors.starlightGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Son Güncelleme: 12 Ekim 2026 • Yürürlük Sürümü: v2.4.0',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Articles
            ...sections.map((sec) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF19162A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sec['title']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pastelLavender,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sec['body']!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),
            // Bottom Action
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.starlightGold,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Metni Okudum & Anladım',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
