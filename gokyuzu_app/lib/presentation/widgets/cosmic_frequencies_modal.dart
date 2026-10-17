import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PlanetaryFrequencyItem {
  final String planetName;
  final String symbol;
  final double frequencyHz;
  final String chakraName;
  final Color themeColor;
  final String note;
  final String title;
  final String description;
  final String bestUseCases;

  const PlanetaryFrequencyItem({
    required this.planetName,
    required this.symbol,
    required this.frequencyHz,
    required this.chakraName,
    required this.themeColor,
    required this.note,
    required this.title,
    required this.description,
    required this.bestUseCases,
  });
}

class CosmicFrequenciesModal extends StatelessWidget {
  const CosmicFrequenciesModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CosmicFrequenciesModal(),
    );
  }

  static const List<PlanetaryFrequencyItem> frequencies = [
    PlanetaryFrequencyItem(
      planetName: 'Güneş',
      symbol: '☉',
      frequencyHz: 126.22,
      chakraName: 'Solar Pleksus (3. Çakra)',
      themeColor: Color(0xFFFFB703),
      note: 'H (Si)',
      title: 'Özgüven, Yaşam Sevinci & İrade Frekansı',
      description:
          'Güneş frekansı, bedenin enerji santrali olan solar pleksus çakrasını aktive eder. Zihinsel yorgunluğu dağıtır, kişisel karizmayı ve liderlik kudretini besler.',
      bestUseCases: 'Önemli toplantılar öncesi, motivasyon düşüklüğünde, sabah uyanırken dinleme veya tefekkür.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Ay',
      symbol: '☽',
      frequencyHz: 210.42,
      chakraName: 'Sakral Çakra (2. Çakra)',
      themeColor: Color(0xFF90E0EF),
      note: 'G# (Sol Diyez)',
      title: 'Bilinçaltı, Duygusal Denge & Sezgi',
      description:
          'Sinodik Ay döngüsünün titreşimidir. Duygusal blokajları çözer, kadınsı şifa enerjisini dengeler ve derin rüyaları berraklaştırır.',
      bestUseCases: 'Uykudan önce, su kenarında meditasyon, duygusal iniş çıkışlarda ve sezgisel çalışmalarda.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Venüs',
      symbol: '♀',
      frequencyHz: 221.23,
      chakraName: 'Kalp Çakrası (4. Çakra)',
      themeColor: Color(0xFFFF758F),
      note: 'A (La)',
      title: 'Aşk, Cazibe, Estetik & Koşulsuz Sevgi',
      description:
          'Venüs rotasyonunun oktav frekansı, kalbin elektromanyetik alanını genişleterek çekim yasasını ve şefkati aktive eder. Sanatsal ilhamı tetikler.',
      bestUseCases: 'İlişkilerde uyum ararken, kalp kırıklıklarını onarırken, resim/müzik icra ederken.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Merkür',
      symbol: '☿',
      frequencyHz: 141.27,
      chakraName: 'Boğaz Çakrası (5. Çakra)',
      themeColor: Color(0xFF00B4D8),
      note: 'C# (Do Diyez)',
      title: 'Zihinsel Berraklık, İletişim & Analiz',
      description:
          'Merkür\'ün Güneş etrafındaki devrinin oktavıdır. İki beyin yarım küresini senkronize eder. Konuşma, yazma ve karmaşık sorunları çözme yeteneğini güçlendirir.',
      bestUseCases: 'Ders çalışırken, sözleşme hazırlarken, hitabet ve sunum öncesi odaklanma için.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Mars',
      symbol: '♂',
      frequencyHz: 144.72,
      chakraName: 'Kök Çakra (1. Çakra)',
      themeColor: Color(0xFFE63946),
      note: 'D (Re)',
      title: 'Cesaret, Fiziksel Canlılık & Eylem Gücü',
      description:
          'Mars döngüsünün frekansı, atalet ve tembelliği dağıtan dinamik bir yaşam enerjisidir. Korkuları aşmak ve kararlılıkla adım atmak için bedeni tetikler.',
      bestUseCases: 'Fiziksel antrenman, spor, erteleme alışkanlığını kırmak ve cesaret gerektiren kararlar.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Jüpiter',
      symbol: '♃',
      frequencyHz: 183.58,
      chakraName: 'Üçüncü Göz (6. Çakra)',
      themeColor: Color(0xFF9D4EDD),
      note: 'F# (Fa Diyez)',
      title: 'Bolluk, Bereket, Vizyon & Ruhsal Genişleme',
      description:
          'Güneş sisteminin en büyük koruyucusu Jüpiter\'in ilahi şans ve bilgelik titreşimidir. Kıtlık bilincini dönüştürür ve ufku genişletir.',
      bestUseCases: 'Maddi/manevi niyet çalışmaları, dua ve şükür ritüelleri, uzun vadeli vizyon belirleme.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Satürn',
      symbol: '♄',
      frequencyHz: 147.85,
      chakraName: 'Taç Çakra & Kök Denge',
      themeColor: Color(0xFF6C757D),
      note: 'D (Re)',
      title: 'Disiplin, Karmik Denge, Sabır & Olgunluk',
      description:
          'Zamanın efendisi Satürn\'ün titreşimi, sağlam yapılar inşa etmek, dağınık zihni toplamak ve ruhsal dersleri olgunlukla kabul etmek için zemin hazırlar.',
      bestUseCases: 'Stratejik planlama, bütçe yönetimi, derin tefekkür ve sabır gerektiren süreçler.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'OM / Dünya Yılı',
      symbol: '🕉️',
      frequencyHz: 136.10,
      chakraName: 'Kalp Çakrası (Anahata)',
      themeColor: Color(0xFF52B788),
      note: 'C# (Do Diyez)',
      title: 'Evrensel Huzur, Zihin Dinginliği & Meditasyon',
      description:
          'Dünyanın presesyon döngüsünün (Büyük Platonik Yıl) frekansıdır. Tibet çanaklarının ve kadim mantraların temelidir. Stresi sıfırlayarak huzur verir.',
      bestUseCases: 'Genel meditasyon, stres atma, yoga ve derin rahatlama.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF130F26),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎵', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gezegen Frekansları & Çakra Şifası',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Hans Cousto • Kozmik Oktav Rehberi',
                            style: TextStyle(
                              color: AppColors.starlightGold.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Giriş Bilgilendirme Kartı (Ders Niteliğinde)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2C1E55).withValues(alpha: 0.6),
                      const Color(0xFF150D2E).withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '🔬 Gezegen Frekansları Nedir?',
                      style: TextStyle(
                        color: AppColors.starlightGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'İsviçreli matematikçi ve müzikolog Hans Cousto, 1978\'de gezegenlerin Güneş etrafındaki dönüş periyotlarını akustik oktav yasasına (f = 1/T × 2^n) göre ses dalgalarına (Hertz) dönüştürdü. Her gök cisminin titreşimi, insan bedenindeki belirli bir sinir düğümü ve çakrayla tam rezonansa girer.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Frekans Kartları Listesi
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: frequencies.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = frequencies[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.themeColor.withValues(alpha: 0.4),
                        width: 1.1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Başlık Satırı
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: item.themeColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Text(item.symbol, style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.planetName} • ${item.frequencyHz} Hz',
                                    style: TextStyle(
                                      color: item.themeColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${item.chakraName} | Nota: ${item.note}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡 ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  'Kullanım: ${item.bestUseCases}',
                                  style: TextStyle(
                                    color: item.themeColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
