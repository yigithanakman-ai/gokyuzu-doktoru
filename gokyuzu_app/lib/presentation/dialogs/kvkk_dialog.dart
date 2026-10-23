import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class KvkkDialog {
  /// KVKK Aydınlatma Metni Modal
  static void show(BuildContext context) {
    _showCustomSheet(
      context: context,
      title: 'KVKK Aydınlatma Metni',
      icon: Icons.shield_outlined,
      color: AppColors.starlightGold,
      sections: [
        _SectionData(
          title: '1. Veri Sorumlusu ve Yasal Çerçeve',
          content:
              '6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca, "Gökyüzü Doktoru" mobil uygulaması kapsamında işlenen kişisel verileriniz, veri sorumlusu sıfatıyla korunmakta ve kanuna tam uyumlu olarak işlenmektedir.',
          icon: Icons.gavel_rounded,
        ),
        _SectionData(
          title: '2. İşlenen Kişisel Veriler',
          content:
              '• Kimlik Bilgileri: Ad, soyad, rumuz ve cinsiyet.\n'
              '• İletişim & Senkronizasyon Bilgileri: E-posta adresi ve isteğe bağlı Google hesabı eşleme bilgisi (telefon değişiminde veya Android ➔ iOS geçişinde harita ve VIP lisans haklarını korumak için).\n'
              '• Kozmik & Doğum Verileri: Doğum tarihi, kesin doğum saati, doğum yeri şehri ve ülkesi (enlem/boylam koordinatları).\n'
              '• Tercih & Not Verileri: Harita arşivi kayıtları, günlük astrolojik notlar ve hatırlatıcılar.',
          icon: Icons.person_pin_rounded,
        ),
        _SectionData(
          title: '3. Verilerin İşlenme Amaçları',
          content:
              '• Geocentric, Placidus ve Tropikal Batı efemeris algoritmalarıyla hassas doğum haritanızı hesaplamak,\n'
              '• Günlük transitler, anlık Ay fazı, Yanık Yol takvimi ve sabit yıldız etkilerini kişiselleştirmek,\n'
              '• Rektifikasyon ve öngörü analizlerini gerçekleştirmek,\n'
              '• Kullanıcı hesap güvenliğini, arşivlenmiş profilleri ve cihazlar arası bulut senkronizasyonunu yönetmek.',
          icon: Icons.auto_awesome_rounded,
        ),
        _SectionData(
          title: '4. Çocukların Gizliliği & Yaş Sınırı (16 Yaş Kuralı)',
          content:
              'Uygulamamız 16 yaş altındaki kişilerin ebeveyn veya yasal vasi izni olmaksızın kişisel veri sağlamasına yönelik değildir. 16 yaşından küçüklerin doğum haritaları ve verileri yalnızca ebeveyn veya yasal vasileri tarafından arşivlenebilir ve sisteme kaydedilebilir.',
          icon: Icons.family_restroom_rounded,
        ),
        _SectionData(
          title: '5. Veri Güvenliği ve Üçüncü Kişilere Aktarım',
          content:
              'Kişisel verileriniz ve doğum haritası koordinatlarınız yüksek standartlarda şifrelenerek saklanır. Verileriniz, yasal zorunluluklar haricinde hiçbir üçüncü taraf reklam şirketi veya veri komisyoncusuyla ticari amaçla PAYLAŞILMAZ ve SATILMAZ.',
          icon: Icons.lock_outline_rounded,
        ),
        _SectionData(
          title: '6. İlgili Kişinin Hakları (KVKK Madde 11)',
          content:
              'KVKK’nın 11. maddesi gereğince;\n'
              '• Kişisel verilerinizin işlenip işlenmediğini öğrenme,\n'
              '• Yanlış işlenmişse düzeltilmesini isteme,\n'
              '• Verilerinizin silinmesini, yok edilmesini veya anonim hale getirilmesini talep etme haklarına sahipsiniz.',
          icon: Icons.fact_check_outlined,
        ),
      ],
    );
  }

  /// Kullanıcı Sözleşmesi & Hizmet Koşulları Modal
  static void showTerms(BuildContext context) {
    _showCustomSheet(
      context: context,
      title: 'Kullanıcı Sözleşmesi & Hizmet Şartları',
      icon: Icons.description_outlined,
      color: AppColors.pastelMint,
      sections: [
        _SectionData(
          title: '1. Hizmetin Niteliği ve Kapsamı',
          content:
              'Gökyüzü Doktoru uygulaması; klasik ve modern Batı astrolojisi, kadim efemeris tabloları ve sembolik yaşam analizleri sunan dijital bir kişisel farkındalık platformudur.',
          icon: Icons.auto_stories_rounded,
        ),
        _SectionData(
          title: '2. Yasal ve Tıbbi Sorumluluk Reddi (Disclaimer)',
          content:
              'Uygulama içerisinde yer alan hiçbir yorum, harita analizi, transit öngörüsü veya astrolojik hesaplama; TIBBİ, HUKUKİ, PSİKİYATRİK VEYA FİNANSAL YATIRIM TAVSİYESİ NİTELİĞİNDE DEĞİLDİR. Hayati kararlarınızda daima yetkili profesyonel hekim, uzman veya yetkili hukuk danışmanlarına başvurunuz.',
          icon: Icons.warning_amber_rounded,
          isWarning: true,
        ),
        _SectionData(
          title: '3. Fikri Mülkiyet ve Telif Hakları',
          content:
              'Uygulamada yer alan özgün algoritmalar, arayüz tasarımları, metinler, Kabala ağacı şemaları ve astroloji motoru Gökyüzü Doktoru\'na aittir. İzinsiz kopyalanamaz, çoğaltılamaz veya ticari amaçla dağıtılamaz.',
          icon: Icons.copyright_rounded,
        ),
        _SectionData(
          title: '4. VIP Abonelik, Cayma Hakkı İstisnası & Ücret İadesi Yapılmaması',
          content:
              'Dijital ortamda anında teslim edilen ve ifa edilen gayri maddi haklar kapsamında (6502 sayılı Tüketicinin Korunması Hakkında Kanun ve Mesafeli Sözleşmeler Yönetmeliği Madde 15/1-ğ uyarınca), satın alınan Silver, Gold ve Platinum VIP aboneliklerinde ve dijital analiz paketlerinde KESİNLİKLE ÜCRET İADESİ YAPILMAZ. Kullanıcı ödemeyi gerçekleştirerek cayma hakkından feragat ettiğini peşinen kabul ve taahhüt eder.',
          icon: Icons.money_off_csred_rounded,
          isWarning: true,
        ),
        _SectionData(
          title: '5. Abonelik İptali & Otomatik Yenilemenin Kapatılması Rehberi',
          content:
              'Kullanıcı dilediği an aboneliğini ilgili mağaza üzerinden iptal edebilir:\n'
              '• Apple App Store (iOS): Cihaz Ayarları > [Apple Kimliği Adınız] > Abonelikler > Gökyüzü Doktoru > "Aboneliği İptal Et" adımlarını uygulayınız.\n'
              '• Google Play Store (Android): Google Play Store uygulaması > Profil Simgesi > Ödemeler ve Abonelikler > Abonelikler > Gökyüzü Doktoru > "Aboneliği İptal Et" adımlarını uygulayınız.\n'
              '• İptal edilen aboneliklerde, ödemesi yapılmış olan cari fatura ve kullanım ayı/yılı sonuna kadar tüm VIP haklar kesintisiz kullanılmaya devam eder. Dönem sonunda ise karttan yeni bir çekim yapılmaz ve üyelik sona erer.',
          icon: Icons.cancel_schedule_send_rounded,
        ),
        _SectionData(
          title: '6. Yaş Sınırı (16 Yaş Kuralı)',
          content:
              'Bu sözleşmeyi onaylamak ve uygulama servislerinden bağımsız olarak faydalanmak için kullanıcının en az 16 yaşında olması zorunludur. 16 yaş altındaki kullanıcılar yalnızca ebeveyn onay ve denetiminde işlem yapabilir.',
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  /// Gizlilik Politikası (Privacy Policy) Modal - Apple & Google Uyumlu
  static void showPrivacyPolicy(BuildContext context) {
    _showCustomSheet(
      context: context,
      title: 'Gizlilik Politikası (Privacy Policy)',
      icon: Icons.privacy_tip_outlined,
      color: const Color(0xFF4EA8DE),
      sections: [
        _SectionData(
          title: '1. Toplanan Bilgiler ve Doğum Verileri',
          content:
              '• Kimlik & İletişim: Ad, soyad, e-posta adresi, cinsiyet.\n'
              '• Kozmik Veriler: Doğum tarihi, kesin doğum saati, doğum şehri ve ülkesi (enlem/boylam koordinatları).\n'
              '• Cihaz Verileri: İşletim sistemi sürümü ve hata raporları (yalnızca kararlılık için).',
          icon: Icons.fingerprint_rounded,
        ),
        _SectionData(
          title: '2. Veri Güvenliği ve Üçüncü Taraflar',
          content:
              'Kişisel verileriniz hiçbir reklam kuruluşuna veya veri simsarına ticari amaçla SATILMAZ veya KİRALANMAZ. Tüm veri iletimi TLS 1.3 / SSL protokolleri ile şifrelenir.',
          icon: Icons.security_rounded,
        ),
        _SectionData(
          title: '3. Hesap ve Veri Silme Hakkı (Apple 5.1.1 Uyumlu)',
          content:
              'Kullanıcılarımız diledikleri zaman Profil ekranından veya yigithanakman@gokyuzudoktoru.com adresine başvurarak hesaplarını, kayıtlı haritalarını ve tüm verilerini kalıcı olarak sildirebilirler.',
          icon: Icons.delete_forever_rounded,
        ),
      ],
    );
  }

  /// Mesafeli Satış Sözleşmesi ve İptal/İade Şartları Modal
  static void showSalesAndRefund(BuildContext context) {
    _showCustomSheet(
      context: context,
      title: 'Mesafeli Satış & İptal İade Koşulları',
      icon: Icons.receipt_long_outlined,
      color: const Color(0xFFFFD166),
      sections: [
        _SectionData(
          title: '1. Hizmetin Niteliği ve Anında İfa',
          content:
              'Gökyüzü Doktoru platformunda satın alınan VIP üyelikler, rektifikasyon analizleri ve 10 sayfalık özel PDF astroloji raporları elektronik ortamda anında ifa edilen dijital hizmetler kapsamındadır.',
          icon: Icons.bolt_rounded,
        ),
        _SectionData(
          title: '2. Yasal Cayma Hakkı İstisnası (6502 Sayılı Kanun)',
          content:
              '6502 sayılı Tüketicinin Korunması Hakkında Kanun ve Mesafeli Sözleşmeler Yönetmeliği Madde 15/1-ğ uyarınca; "Elektronik ortamda anında ifa edilen hizmetler veya tüketiciye anında teslim edilen gayrimaddi mallarda CAYMA HAKKI KULLANILAMAZ." Satın alma tamamlanıp dijital içerik açıldığında ücret iadesi yapılmaz.',
          icon: Icons.gavel_rounded,
          isWarning: true,
        ),
        _SectionData(
          title: '3. Abonelik İptali ve Otomatik Yenileme',
          content:
              'Aboneliğinizi Apple App Store veya Google Play Store Ayarlar > Abonelikler menüsünden dilediğiniz an tek tıkla iptal edebilirsiniz. İptal durumunda fatura dönemi sonuna kadar VIP haklarınız kesintisiz sürer.',
          icon: Icons.event_repeat_rounded,
        ),
      ],
    );
  }

  /// Astrolojik ve Sağlık/Finans Sorumluluk Reddi (Disclaimer)
  static void showDisclaimer(BuildContext context) {
    _showCustomSheet(
      context: context,
      title: 'Yasal Sorumluluk Reddi (Disclaimer)',
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFEF476F),
      sections: [
        _SectionData(
          title: '1. Öz Farkındalık ve Eğlence Amacı',
          content:
              'Gökyüzü Doktoru uygulamasında yer alan tüm gezegen konumları, ev analizleri, açılar, transitler ve 10 sayfalık kitapçıklar; yalnızca sembolik kadim astroloji geleneklerine dayalı öz farkındalık, kültürel bilgi ve eğlence amaçlıdır.',
          icon: Icons.auto_awesome_rounded,
        ),
        _SectionData(
          title: '2. Kesinlikle Tıbbi, Psikolojik veya Hukuki Tavsiye Değildir',
          content:
              'Uygulama içerisindeki hiçbir ifade; TIBBİ TEŞHİS, TEDAVİ, PSİKİYATRİK DANIŞMANLIK, HUKUKİ MÜTALAA VEYA FİNANSAL YATIRIM TAVSİYESİ YERİNE GEÇMEZ. Hayati kararlarınızda daima yetkili hekimlere ve uzman profesyonellere başvurunuz.',
          icon: Icons.health_and_safety_outlined,
          isWarning: true,
        ),
      ],
    );
  }

  /// Tüm Yasal Metinler Portalı (Menü Seçimi)
  static void showAllLegalMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          color: Color(0xFF13111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF9D4EDD), width: 1.2)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: Color(0xFFFFD166), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Yasal Merkez & Şeffaflık',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMenuTile(ctx, 'KVKK Aydınlatma Metni', Icons.description_outlined, const Color(0xFFFFD166), () {
                Navigator.pop(ctx);
                show(context);
              }),
              _buildMenuTile(ctx, 'Kullanım Koşulları (EULA)', Icons.rule_rounded, AppColors.pastelMint, () {
                Navigator.pop(ctx);
                showTerms(context);
              }),
              _buildMenuTile(ctx, 'Gizlilik Politikası (Privacy Policy)', Icons.privacy_tip_outlined, const Color(0xFF4EA8DE), () {
                Navigator.pop(ctx);
                showPrivacyPolicy(context);
              }),
              _buildMenuTile(ctx, 'Mesafeli Satış & İade Koşulları', Icons.receipt_long_outlined, const Color(0xFFFFD166), () {
                Navigator.pop(ctx);
                showSalesAndRefund(context);
              }),
              _buildMenuTile(ctx, 'Yasal Feragatname (Disclaimer)', Icons.warning_amber_rounded, const Color(0xFFEF476F), () {
                Navigator.pop(ctx);
                showDisclaimer(context);
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuTile(BuildContext ctx, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
      onTap: onTap,
    );
  }

  static void _showCustomSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<_SectionData> sections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF13111C),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: color, width: 1.2),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    ...sections.map((sec) => _buildSectionCard(sec)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Sabit Alt Çubuk (Sistem çubuğundan asla kesilmez)
              SafeArea(
                top: false,
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13111C),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Okudum ve Anladım',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionCard(_SectionData sec) {
    final cardColor = sec.isWarning ? AppColors.warningOrange : AppColors.pastelMint;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sec.icon, color: cardColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sec.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sec.content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionData {
  final String title;
  final String content;
  final IconData icon;
  final bool isWarning;

  _SectionData({
    required this.title,
    required this.content,
    required this.icon,
    this.isWarning = false,
  });
}
