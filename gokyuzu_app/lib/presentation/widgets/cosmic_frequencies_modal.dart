import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/frequency_synth_service.dart';

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
      frequencyHz: 252.44,
      chakraName: 'Solar Pleksus (3. Çakra)',
      themeColor: Color(0xFFFFB703),
      note: 'B3 (Si) • 252.44 Hz (33. Işıltılı Oktav)',
      title: 'Özgüven, Canlılık & Yüksek Güneş Frekansı',
      description:
          'Hans Cousto Kozmik Oktav yasasına göre Güneş\'in 33. harmonik frekansıdır (252.44 Hz). Alt bas oktavı (126.22 Hz) ile akustik olarak zenginleştirilen bu ışıltılı ton; zihinsel yorgunluğu dağıtır, solar pleksusu aktive eder ve kişisel auranızı parlatır.',
      bestUseCases: 'Önemli toplantılar öncesi, motivasyon düşüklüğünde, sabah uyanırken ve aura güçlendirmede.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Ay',
      symbol: '☽',
      frequencyHz: 210.42,
      chakraName: 'Sakral Çakra (2. Çakra)',
      themeColor: Color(0xFF90E0EF),
      note: 'G#3 (Sol Diyez) • 210.42 Hz (+5 Cent)',
      title: 'Bilinçaltı, Duygusal Denge & Sezgi',
      description:
          'Sinodik Ay döngüsünün (29.53 gün) 29. oktav titreşimidir. Duygusal tıkanıklıkları çözer, kadınsı şifa enerjisini dengeler ve sezgileri berraklaştırır.',
      bestUseCases: 'Uykudan önce, derin tefekkür, duygusal dalgalanmalarda ve su ritüellerinde.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Venüs',
      symbol: '♀\uFE0E',
      frequencyHz: 221.23,
      chakraName: 'Kalp Çakrası (4. Çakra)',
      themeColor: Color(0xFFFF758F),
      note: 'A3 (La) • 221.23 Hz (-9 Cent)',
      title: 'Aşk, Cazibe, Estetik & Koşulsuz Sevgi',
      description:
          'Venüs rotasyonunun 32. oktav titreşimidir. Kalbin elektromanyetik rezonansını genişleterek çekim yasasını, şefkati ve estetik yaratıcılığı aktive eder.',
      bestUseCases: 'İlişkilerde barış ve uyum ararken, kalp kırıklıklarını onarırken, sanat ve güzellik çalışmalarında.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Merkür',
      symbol: '☿',
      frequencyHz: 141.27,
      chakraName: 'Boğaz Çakrası (5. Çakra)',
      themeColor: Color(0xFF00B4D8),
      note: 'C#3 (Do Diyez) • 141.27 Hz (+33 Cent Mikroton)',
      title: 'Zihinsel Berraklık, İletişim & Analiz',
      description:
          'Merkür\'ün Güneş etrafındaki devrinin 30. oktavıdır. Standart Do# notasından +33 cent mikrotonal farkla titreşir. İki beyin yarım küresini senkronize eder; konuşma, hızlı kavrayış ve sözleşme gücünü keskinleştirir.',
      bestUseCases: 'Ders çalışırken, önemli sözleşmeler hazırlarken, hitabet ve sunum öncesi odaklanmada.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Mars',
      symbol: '♂\uFE0E',
      frequencyHz: 144.72,
      chakraName: 'Kök Çakra (1. Çakra)',
      themeColor: Color(0xFFE63946),
      note: 'D3 (Re) • 144.72 Hz (-25 Cent Dinamik Güç)',
      title: 'Cesaret, Fiziksel Canlılık & Eylem Gücü',
      description:
          'Mars döngüsünün 33. oktavıdır. Standart Re notasından 25 cent daha pes bir doğal frekanstır; atalet ve korkuyu dağıtarak kök çakrayı dinamik enerjiyle doldurur. Kararlılıkla adım atma motivasyonu verir.',
      bestUseCases: 'Spor ve antrenman öncesi, erteleme alışkanlığını kırmak ve cesaret gerektiren yüzleşmelerde.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Jüpiter',
      symbol: '♃',
      frequencyHz: 183.58,
      chakraName: 'Üçüncü Göz (6. Çakra)',
      themeColor: Color(0xFF9D4EDD),
      note: 'F#3 (Fa Diyez) • 183.58 Hz (-32 Cent Genişleme)',
      title: 'Bolluk, Bereket, Vizyon & Ruhsal Genişleme',
      description:
          'Güneş sisteminin en büyük koruyucusu Jüpiter\'in 36. oktav ilahi frekansıdır. Kıtlık bilincini dönüştürür, manevi teslimiyeti ve şans bilincini yükseltir.',
      bestUseCases: 'Maddi/manevi niyet çalışmaları, dua ve şükür ritüelleri, uzun vadeli vizyon belirleme.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'Satürn',
      symbol: '♄',
      frequencyHz: 147.85,
      chakraName: 'Taç Çakra & Kök Denge',
      themeColor: Color(0xFF6C757D),
      note: 'D3 (Re) • 147.85 Hz (+12 Cent Kristal Yapı)',
      title: 'Disiplin, Karmik Denge, Sabır & Olgunluk',
      description:
          'Satürn döngüsünün 37. oktavıdır. Mars ile aynı ana nota havuzunda (Re) olmasına rağmen, 147.85 Hz (+12 cent) kristalize mikrotonuyla sağlam yapılar inşa etmek, dağınık zihni toparlamak ve disiplin kurmak için idealdir.',
      bestUseCases: 'Stratejik planlama, bütçe yönetimi, derin tefekkür ve sabır gerektiren uzun vadeli işler.',
    ),
    PlanetaryFrequencyItem(
      planetName: 'OM / Dünya Yılı',
      symbol: '🕉️',
      frequencyHz: 136.10,
      chakraName: 'Kalp Çakrası (Anahata)',
      themeColor: Color(0xFF52B788),
      note: 'C#3 (Do Diyez) • 136.10 Hz (-31 Cent Meditatif)',
      title: 'Evrensel Huzur, Zihin Dinginliği & Meditasyon',
      description:
          'Dünyanın 25.920 yıllık Platonik presesyon döngüsünün 32. oktavıdır. Merkür ile aynı nota bölgesinde (Do#) yer alsa da -31 cent farkıyla Tibet çanaklarının ve kadim OM mantralarının temelidir; sinir sistemini gevşetir.',
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
                            'Hans Cousto • Kozmik Oktav & Mikrotonal Akort',
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
                    onPressed: () {
                      FrequencySynthService.stop();
                      Navigator.of(context).pop();
                    },
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
                  children: [
                    const Text(
                      '🔬 Hans Cousto Kozmik Oktav & Mikrotonal Gerçekler',
                      style: TextStyle(
                        color: AppColors.starlightGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'İsviçreli matematikçi ve müzikolog Hans Cousto (1978), gezegenlerin Güneş etrafındaki dönüş periyotlarını (T) akustik oktav yasasına (f = 1/T × 2^n) göre ses dalgalarına dönüştürdü. Evren piyanonun 12 eşit tuşuyla sınırlı değildir; gezegenler doğal mikrotonal Hertz (Hz) değerlerinde titreşir.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '♾️ Kesintisiz Meditasyon Döngüsü:',
                            style: TextStyle(color: AppColors.starlightGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sesler siz "Durdur" butonuna basana kadar kesintisiz döngüde (loop) çalar.',
                            style: TextStyle(color: Colors.white60, fontSize: 10.5),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '🎼 Neden Bazı Gezegenler Aynı Notada?',
                            style: TextStyle(color: AppColors.starlightGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Örn: Mars (144.7 Hz) ve Satürn (147.8 Hz) ikisi de "Re" ses havuzundadır ancak aralarında 3.1 Hz (+37 cent) mikrotonal fark vardır. Merkür ve OM da "Do Diyez" havuzunun farklı frekanslarıdır.',
                            style: TextStyle(color: Colors.white60, fontSize: 10.5),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '☀️ Güneş (252.44 Hz - Si):',
                            style: TextStyle(color: AppColors.starlightGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Güneş\'in 32. oktavı (126.22 Hz) sub-bass bas tonudur. Mobil hoparlörlerde berrak duyulabilmesi için 33. ışıltılı oktavı olan 252.44 Hz (Si3) sentezlenmiştir.',
                            style: TextStyle(color: Colors.white60, fontSize: 10.5),
                          ),
                        ],
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
                                    style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ValueListenableBuilder<double?>(
                              valueListenable: FrequencySynthService.playingFrequencyNotifier,
                              builder: (context, playingHz, _) {
                                final isThisPlaying = playingHz == item.frequencyHz;
                                return ElevatedButton.icon(
                                  onPressed: () => FrequencySynthService.togglePlayFrequency(item.frequencyHz),
                                  icon: Icon(
                                    isThisPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    isThisPlaying ? 'Durdur' : 'Başlat',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isThisPlaying ? const Color(0xFF00E676) : item.themeColor,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: isThisPlaying
                                          ? const BorderSide(color: Colors.white, width: 1.5)
                                          : BorderSide.none,
                                    ),
                                    elevation: isThisPlaying ? 6 : 2,
                                  ),
                                );
                              },
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
