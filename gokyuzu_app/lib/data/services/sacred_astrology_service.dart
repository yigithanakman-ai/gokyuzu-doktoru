class DecanInfo {
  final String sign;
  final int dekanNumber; // 1, 2, 3
  final String degreeRange;
  final String chaldeanRuler;
  final String triplicityRuler;
  final String description;

  const DecanInfo({
    required this.sign,
    required this.dekanNumber,
    required this.degreeRange,
    required this.chaldeanRuler,
    required this.triplicityRuler,
    required this.description,
  });

  int get decanNumber => dekanNumber;
}

class EgyptianTermInfo {
  final String sign;
  final int startDegree;
  final int endDegree;
  final String rulingPlanet;
  final String meaning;

  const EgyptianTermInfo({
    required this.sign,
    required this.startDegree,
    required this.endDegree,
    required this.rulingPlanet,
    required this.meaning,
  });

  String get degreeRange => '$startDegree° - $endDegree° $sign';
}

class KabbalahAngelInfo {
  final int number; // 1 - 72
  final String name;
  final String sign;
  final int startDegree;
  final int endDegree;
  final String choir; // Serafim, Kerubim, Tahtlar, vs.
  final String virtue;
  final String meaning;

  const KabbalahAngelInfo({
    required this.number,
    required this.name,
    required this.sign,
    required this.startDegree,
    required this.endDegree,
    required this.choir,
    required this.virtue,
    required this.meaning,
  });

  String get degreeRange => '$startDegree° - $endDegree° $sign';
}

class SacredAstrologyService {
  static const List<String> zodiacSigns = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  // 36 DEKAN TABLOSU (Keldani ve Üçlü Yöneticileri)
  static final List<DecanInfo> _allDecans = [
    // Koç
    const DecanInfo(
      sign: 'Koç',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Mars ♂︎',
      triplicityRuler: 'Mars ♂︎ (Koç)',
      description: 'Saf ateş enerjisi, mutlak cesaret, öncülük ve tavizsiz eylem arzusu.',
    ),
    const DecanInfo(
      sign: 'Koç',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Güneş ☉',
      triplicityRuler: 'Güneş ☉ (Aslan)',
      description: 'Liderlik ateşi, soylu duruş, gurur ve merkezde olma kudreti.',
    ),
    const DecanInfo(
      sign: 'Koç',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Venüs ♀︎',
      triplicityRuler: 'Jüpiter ♃ (Yay)',
      description: 'Genişleme arzusu, fetih tutkusu, felsefi ve maceracı ateş.',
    ),

    // Boğa
    const DecanInfo(
      sign: 'Boğa',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Merkür ☿',
      triplicityRuler: 'Venüs ♀︎ (Boğa)',
      description: 'Maddi üretkenlik, somut zeka, estetik ve fiziksel zevklerin temeli.',
    ),
    const DecanInfo(
      sign: 'Boğa',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Ay ☽',
      triplicityRuler: 'Merkür ☿ (Başak)',
      description: 'Bereket, zanaat ustalığı, güvenli alan inşa etme ve besleme kudreti.',
    ),
    const DecanInfo(
      sign: 'Boğa',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Satürn ♄',
      triplicityRuler: 'Satürn ♄ (Oğlak)',
      description: 'Sarsılmaz dayanıklılık, somut miras biriktirme ve zamanın testinden geçen güç.',
    ),

    // İkizler
    const DecanInfo(
      sign: 'İkizler',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Jüpiter ♃',
      triplicityRuler: 'Merkür ☿ (İkizler)',
      description: 'Hızlı kavrayış, merak, konuşma ve fikirleri etrafa yayma yeteneği.',
    ),
    const DecanInfo(
      sign: 'İkizler',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Mars ♂︎',
      triplicityRuler: 'Venüs ♀︎ (Terazi)',
      description: 'Zihinsel çekim gücü, ikna sanatı, zeki tartışmalar ve sosyal diplomatik güç.',
    ),
    const DecanInfo(
      sign: 'İkizler',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Güneş ☉',
      triplicityRuler: 'Uranüs/Satürn (Kova)',
      description: 'Kolektif vizyon, sıra dışı fikirler, dahi zihin ve entelektüel aydınlanma.',
    ),

    // Yengeç
    const DecanInfo(
      sign: 'Yengeç',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Venüs ♀︎',
      triplicityRuler: 'Ay ☽ (Yengeç)',
      description: 'Derin koruma içgüdüsü, şefkat, anaç kucaklayış ve köklere bağlılık.',
    ),
    const DecanInfo(
      sign: 'Yengeç',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Merkür ☿',
      triplicityRuler: 'Mars/Plüton (Akrep)',
      description: 'Duygusal sezgi gücü, dedektif hisler, koruyucu zırh ve psikolojik derinlik.',
    ),
    const DecanInfo(
      sign: 'Yengeç',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Ay ☽',
      triplicityRuler: 'Jüpiter/Neptün (Balık)',
      description: 'Evrensel şefkat, psişik rüyalar, manevi fedakarlık ve yaratıcı hayal gücü.',
    ),

    // Aslan
    const DecanInfo(
      sign: 'Aslan',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Satürn ♄',
      triplicityRuler: 'Güneş ☉ (Aslan)',
      description: 'Otoriter liderlik, karizma, egonun asaleti ve hükmetme metaneti.',
    ),
    const DecanInfo(
      sign: 'Aslan',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Jüpiter ♃',
      triplicityRuler: 'Jüpiter ♃ (Yay)',
      description: 'Cömert hükümdar, vizyoner büyüme, yaşam sahnesinde sınırsız neşe.',
    ),
    const DecanInfo(
      sign: 'Aslan',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Mars ♂︎',
      triplicityRuler: 'Mars ♂︎ (Koç)',
      description: 'Savaşçı kral enerjisi, tavizsiz irade, tutku ve fethetme ateşi.',
    ),

    // Başak
    const DecanInfo(
      sign: 'Başak',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Güneş ☉',
      triplicityRuler: 'Merkür ☿ (Başak)',
      description: 'Analitik mükemmeliyet, detaylara hakimiyet ve kusursuz pratik zeka.',
    ),
    const DecanInfo(
      sign: 'Başak',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Venüs ♀︎',
      triplicityRuler: 'Satürn ♄ (Oğlak)',
      description: 'Disiplinli emek, somut organizasyon ve kurallara bağlı verimlilik.',
    ),
    const DecanInfo(
      sign: 'Başak',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Merkür ☿',
      triplicityRuler: 'Venüs ♀︎ (Boğa)',
      description: 'Zanaat ve estetik birlikteliği, şifa sanatı ve somut değer yaratımı.',
    ),

    // Terazi
    const DecanInfo(
      sign: 'Terazi',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Ay ☽',
      triplicityRuler: 'Venüs ♀︎ (Terazi)',
      description: 'Zarafet, sosyal uyum arzusu, adil terazi ve ilişkilerde zarafet.',
    ),
    const DecanInfo(
      sign: 'Terazi',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Satürn ♄',
      triplicityRuler: 'Uranüs/Satürn (Kova)',
      description: 'Sözleşme ve ilkesel adalet, entelektüel tarafsızlık ve yüksek ahlak.',
    ),
    const DecanInfo(
      sign: 'Terazi',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Jüpiter ♃',
      triplicityRuler: 'Merkür ☿ (İkizler)',
      description: 'Konuşma ve diplomasi sanatı, felsefi uzlaşma ve estetik zeka.',
    ),

    // Akrep
    const DecanInfo(
      sign: 'Akrep',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Mars ♂︎',
      triplicityRuler: 'Mars/Plüton (Akrep)',
      description: 'Saf kriz ve dönüşüm gücü, küllerinden doğuş ve sarsılmaz tutku.',
    ),
    const DecanInfo(
      sign: 'Akrep',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Güneş ☉',
      triplicityRuler: 'Jüpiter/Neptün (Balık)',
      description: 'Okült güç, psişik sezgi, manevi simya ve derin ruhsal kurtuluş.',
    ),
    const DecanInfo(
      sign: 'Akrep',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Venüs ♀︎',
      triplicityRuler: 'Ay ☽ (Yengeç)',
      description: 'Manyetik çekim, ruh eşi arayışı, tutkulu sadakat ve koruyucu güç.',
    ),

    // Yay
    const DecanInfo(
      sign: 'Yay',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Merkür ☿',
      triplicityRuler: 'Jüpiter ♃ (Yay)',
      description: 'Bilgi arayışı, hakikat avcısı, felsefi seyahatler ve iyimser vizyon.',
    ),
    const DecanInfo(
      sign: 'Yay',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Ay ☽',
      triplicityRuler: 'Mars ♂︎ (Koç)',
      description: 'Kutsal dava savaşçısı, doğrudan sözler, cesur adımlar ve inanç ateşi.',
    ),
    const DecanInfo(
      sign: 'Yay',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Satürn ♄',
      triplicityRuler: 'Güneş ☉ (Aslan)',
      description: 'Ruhsal otorite, aydınlanma, usta öğretmen ve soylu liderlik.',
    ),

    // Oğlak
    const DecanInfo(
      sign: 'Oğlak',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Jüpiter ♃',
      triplicityRuler: 'Satürn ♄ (Oğlak)',
      description: 'Hırslı tırmanış, dağın zirvesine odaklanma ve stratejik sabır.',
    ),
    const DecanInfo(
      sign: 'Oğlak',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Mars ♂︎',
      triplicityRuler: 'Venüs ♀︎ (Boğa)',
      description: 'Kalıcı eserler inşa etme, finansal imparatorluk kurma ve çelik irade.',
    ),
    const DecanInfo(
      sign: 'Oğlak',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Güneş ☉',
      triplicityRuler: 'Merkür ☿ (Başak)',
      description: 'Usta yöneticilik, analitik sistem kuruculuğu ve zamanın fethi.',
    ),

    // Kova
    const DecanInfo(
      sign: 'Kova',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Venüs ♀︎',
      triplicityRuler: 'Satürn/Uranüs (Kova)',
      description: 'Hümanist devrim, özgürlük aşkı, yenilikçi reform ve bağımsız ruh.',
    ),
    const DecanInfo(
      sign: 'Kova',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Merkür ☿',
      triplicityRuler: 'Merkür ☿ (İkizler)',
      description: 'Dahi zeka, teknolojik buluşlar, evrensel iletişim ve vizyoner fikirler.',
    ),
    const DecanInfo(
      sign: 'Kova',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Ay ☽',
      triplicityRuler: 'Venüs ♀︎ (Terazi)',
      description: 'Kolektif kardeşlik, adil dünya ideali ve geleceğe rehberlik.',
    ),

    // Balık
    const DecanInfo(
      sign: 'Balık',
      dekanNumber: 1,
      degreeRange: '0° - 10°',
      chaldeanRuler: 'Satürn ♄',
      triplicityRuler: 'Jüpiter/Neptün (Balık)',
      description: 'Manevi disiplin, gizli alemler, derin empati ve sınırları aşan teslimiyet.',
    ),
    const DecanInfo(
      sign: 'Balık',
      dekanNumber: 2,
      degreeRange: '10° - 20°',
      chaldeanRuler: 'Jüpiter ♃',
      triplicityRuler: 'Ay ☽ (Yengeç)',
      description: 'Psişik sezgiler, duygusal şifa, koruyucu melekler ve kalpten dua gücü.',
    ),
    const DecanInfo(
      sign: 'Balık',
      dekanNumber: 3,
      degreeRange: '20° - 30°',
      chaldeanRuler: 'Mars ♂︎',
      triplicityRuler: 'Mars/Plüton (Akrep)',
      description: 'Kozmik arınma, simyasal sonlanış, yeniden doğuş kapısı ve mutlak birlik.',
    ),
  ];

  // MISIR TERİMLERİ (EGYPTIAN BOUNDS / TERMS)
  static final Map<String, List<EgyptianTermInfo>> _egyptianTerms = {
    'Koç': [
      const EgyptianTermInfo(sign: 'Koç', startDegree: 0, endDegree: 6, rulingPlanet: 'Jüpiter ♃', meaning: 'Girişimci bilgelik, vizyoner genişleme ve şans kapıları.'),
      const EgyptianTermInfo(sign: 'Koç', startDegree: 6, endDegree: 12, rulingPlanet: 'Venüs ♀︎', meaning: 'Cesur çekim, zarafetle harmanlanmış eylem arzusu.'),
      const EgyptianTermInfo(sign: 'Koç', startDegree: 12, endDegree: 20, rulingPlanet: 'Merkür ☿', meaning: 'Hızlı strateji, taktik zeka ve ani karar alma gücü.'),
      const EgyptianTermInfo(sign: 'Koç', startDegree: 20, endDegree: 25, rulingPlanet: 'Mars ♂︎', meaning: 'Saf savaşçı güç, engelleri yıkıp geçen irade.'),
      const EgyptianTermInfo(sign: 'Koç', startDegree: 25, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Sertleşen disiplin, sınırları koruma ve dayanıklılık.'),
    ],
    'Boğa': [
      const EgyptianTermInfo(sign: 'Boğa', startDegree: 0, endDegree: 8, rulingPlanet: 'Venüs ♀︎', meaning: 'Maddi lüks, doğanın bereketi, somut zevkler ve estetik.'),
      const EgyptianTermInfo(sign: 'Boğa', startDegree: 8, endDegree: 14, rulingPlanet: 'Merkür ☿', meaning: 'Ticari akıl, bütçe yönetimi ve somut hesap gücü.'),
      const EgyptianTermInfo(sign: 'Boğa', startDegree: 14, endDegree: 22, rulingPlanet: 'Jüpiter ♃', meaning: 'Toprak zenginliği, bereketli hasat ve cömertlik.'),
      const EgyptianTermInfo(sign: 'Boğa', startDegree: 22, endDegree: 27, rulingPlanet: 'Satürn ♄', meaning: 'Kaya gibi sağlam temel, sabırlı inşaat ve mülkiyet.'),
      const EgyptianTermInfo(sign: 'Boğa', startDegree: 27, endDegree: 30, rulingPlanet: 'Mars ♂︎', meaning: 'İnatçı savunma, fiziksel dayanıklılık ve direnç.'),
    ],
    'İkizler': [
      const EgyptianTermInfo(sign: 'İkizler', startDegree: 0, endDegree: 6, rulingPlanet: 'Merkür ☿', meaning: 'Sözlü ustalık, kıvrak zeka ve bilgi akışı.'),
      const EgyptianTermInfo(sign: 'İkizler', startDegree: 6, endDegree: 12, rulingPlanet: 'Jüpiter ♃', meaning: 'Felsefi merak, yüksek öğrenim ve hoşgörülü iletişim.'),
      const EgyptianTermInfo(sign: 'İkizler', startDegree: 12, endDegree: 17, rulingPlanet: 'Venüs ♀︎', meaning: 'Sosyal cazibe, esprili konuşmalar ve tatlı dilli diplomasi.'),
      const EgyptianTermInfo(sign: 'İkizler', startDegree: 17, endDegree: 24, rulingPlanet: 'Mars ♂︎', meaning: 'Keskin dil, polemik cesareti ve hızlı zihinsel refleksler.'),
      const EgyptianTermInfo(sign: 'İkizler', startDegree: 24, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Derin araştırma, zihinsel disiplin ve şüpheci akıl.'),
    ],
    'Yengeç': [
      const EgyptianTermInfo(sign: 'Yengeç', startDegree: 0, endDegree: 7, rulingPlanet: 'Mars ♂︎', meaning: 'Yuvayı koruma ateşi, savunmacı cesaret ve içsel güç.'),
      const EgyptianTermInfo(sign: 'Yengeç', startDegree: 7, endDegree: 13, rulingPlanet: 'Venüs ♀︎', meaning: 'Duygusal bağlar, ev içi huzur ve besleyici sevgi.'),
      const EgyptianTermInfo(sign: 'Yengeç', startDegree: 13, endDegree: 19, rulingPlanet: 'Merkür ☿', meaning: 'Sezgisel zihin, anıları saklama ve duygusal empati.'),
      const EgyptianTermInfo(sign: 'Yengeç', startDegree: 19, endDegree: 26, rulingPlanet: 'Jüpiter ♃', meaning: 'Geniş aile bereketi, ruhsal koruma ve cömert şefkat.'),
      const EgyptianTermInfo(sign: 'Yengeç', startDegree: 26, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Karmik soy bağları, katı sınırlar ve duygusal mesafe.'),
    ],
    'Aslan': [
      const EgyptianTermInfo(sign: 'Aslan', startDegree: 0, endDegree: 6, rulingPlanet: 'Jüpiter ♃', meaning: 'Muazzam asalet, cömert hükümdarlık ve saygı görme.'),
      const EgyptianTermInfo(sign: 'Aslan', startDegree: 6, endDegree: 11, rulingPlanet: 'Venüs ♀︎', meaning: 'Sanat tutkusu, sahne karizması ve romantik cömertlik.'),
      const EgyptianTermInfo(sign: 'Aslan', startDegree: 11, endDegree: 18, rulingPlanet: 'Satürn ♄', meaning: 'Ağırbaşlı liderlik, sorumluluk alan gurur ve ciddiyet.'),
      const EgyptianTermInfo(sign: 'Aslan', startDegree: 18, endDegree: 24, rulingPlanet: 'Merkür ☿', meaning: 'Etkileyici hitabet, yaratıcı organizasyon ve parlak sunum.'),
      const EgyptianTermInfo(sign: 'Aslan', startDegree: 24, endDegree: 30, rulingPlanet: 'Mars ♂︎', meaning: 'Yenilmez savaşçı, fethetme tutkusu ve cesur iddialar.'),
    ],
    'Başak': [
      const EgyptianTermInfo(sign: 'Başak', startDegree: 0, endDegree: 7, rulingPlanet: 'Merkür ☿', meaning: 'Kusursuz tahlil, veri analizi ve metodik ustalık.'),
      const EgyptianTermInfo(sign: 'Başak', startDegree: 7, endDegree: 17, rulingPlanet: 'Venüs ♀︎', meaning: 'Zarif detaylar, el sanatları ve şifalı bitkiler.'),
      const EgyptianTermInfo(sign: 'Başak', startDegree: 17, endDegree: 21, rulingPlanet: 'Jüpiter ♃', meaning: 'Ahlaki dürüstlük, adil hizmet ve verimli organizasyon.'),
      const EgyptianTermInfo(sign: 'Başak', startDegree: 21, endDegree: 28, rulingPlanet: 'Mars ♂︎', meaning: 'Eleştirel keskinlik, problem çözme cerrahisi ve azim.'),
      const EgyptianTermInfo(sign: 'Başak', startDegree: 28, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Çileci disiplin, sadeleşme ve hatasız sonuç odaklılık.'),
    ],
    'Terazi': [
      const EgyptianTermInfo(sign: 'Terazi', startDegree: 0, endDegree: 6, rulingPlanet: 'Satürn ♄', meaning: 'Adaletin terazisi, tarafsız mahkeme ve sarsılmaz ilkeler.'),
      const EgyptianTermInfo(sign: 'Terazi', startDegree: 6, endDegree: 14, rulingPlanet: 'Merkür ☿', meaning: 'Diplomatik arabuluculuk, zarif müzakere ve anlaşmalar.'),
      const EgyptianTermInfo(sign: 'Terazi', startDegree: 14, endDegree: 21, rulingPlanet: 'Jüpiter ♃', meaning: 'Hukuksal zaferler, soylu ilişkiler ve sosyal denge.'),
      const EgyptianTermInfo(sign: 'Terazi', startDegree: 21, endDegree: 28, rulingPlanet: 'Venüs ♀︎', meaning: 'Saf güzellik, romantik uyum, stil ve estetik cazibe.'),
      const EgyptianTermInfo(sign: 'Terazi', startDegree: 28, endDegree: 30, rulingPlanet: 'Mars ♂︎', meaning: 'Hak arama mücadelesi, adalet savaşçılığı ve sınır çekme.'),
    ],
    'Akrep': [
      const EgyptianTermInfo(sign: 'Akrep', startDegree: 0, endDegree: 7, rulingPlanet: 'Mars ♂︎', meaning: 'Derin hayatta kalma gücü, tavizsiz irade ve sezgisel savunma.'),
      const EgyptianTermInfo(sign: 'Akrep', startDegree: 7, endDegree: 11, rulingPlanet: 'Venüs ♀︎', meaning: 'Ölümcül çekim, derin tutku ve ruhsal bağlılık.'),
      const EgyptianTermInfo(sign: 'Akrep', startDegree: 11, endDegree: 19, rulingPlanet: 'Merkür ☿', meaning: 'Gizli sırları çözme, okült zeka ve stratejik sırdaşlık.'),
      const EgyptianTermInfo(sign: 'Akrep', startDegree: 19, endDegree: 24, rulingPlanet: 'Jüpiter ♃', meaning: 'Dönüşüm simyası, miras ve krizlerden zenginlikle çıkış.'),
      const EgyptianTermInfo(sign: 'Akrep', startDegree: 24, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Karmik bedeller, sarsılmaz gizlilik ve kaya gibi sabır.'),
    ],
    'Yay': [
      const EgyptianTermInfo(sign: 'Yay', startDegree: 0, endDegree: 12, rulingPlanet: 'Jüpiter ♃', meaning: 'Sınırsız ufuklar, yüksek inanç ve ilahi korunma.'),
      const EgyptianTermInfo(sign: 'Yay', startDegree: 12, endDegree: 17, rulingPlanet: 'Venüs ♀︎', meaning: 'Evrensel sevgi, yabancı diyarlarda aşk ve şans.'),
      const EgyptianTermInfo(sign: 'Yay', startDegree: 17, endDegree: 21, rulingPlanet: 'Merkür ☿', meaning: 'Yabancı diller, felsefi yazılar ve vizyoner yayıncılık.'),
      const EgyptianTermInfo(sign: 'Yay', startDegree: 21, endDegree: 26, rulingPlanet: 'Satürn ♄', meaning: 'Geleneksel inançlar, kadim doktrinler ve ahlaki kurallar.'),
      const EgyptianTermInfo(sign: 'Yay', startDegree: 26, endDegree: 30, rulingPlanet: 'Mars ♂︎', meaning: 'Hedefe kilitlenen ok, macera cesareti ve gözü karalık.'),
    ],
    'Oğlak': [
      const EgyptianTermInfo(sign: 'Oğlak', startDegree: 0, endDegree: 7, rulingPlanet: 'Venüs ♀︎', meaning: 'Sosyal statü, saygın evlilik ve mülk zarafeti.'),
      const EgyptianTermInfo(sign: 'Oğlak', startDegree: 7, endDegree: 14, rulingPlanet: 'Merkür ☿', meaning: 'Kurumsal strateji, yönetim zekası ve bürokratik akıl.'),
      const EgyptianTermInfo(sign: 'Oğlak', startDegree: 14, endDegree: 22, rulingPlanet: 'Jüpiter ♃', meaning: 'Kariyerde yükseliş, itibar ve devlet erkanıyla uyum.'),
      const EgyptianTermInfo(sign: 'Oğlak', startDegree: 22, endDegree: 26, rulingPlanet: 'Mars ♂︎', meaning: 'Yücelen azim, yıkılmaz çalışma disiplini ve fetih.'),
      const EgyptianTermInfo(sign: 'Oğlak', startDegree: 26, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Zirvedeki tek başına güç, nihai otorite ve ebedi miras.'),
    ],
    'Kova': [
      const EgyptianTermInfo(sign: 'Kova', startDegree: 0, endDegree: 7, rulingPlanet: 'Merkür ☿', meaning: 'Öncü bilimsel fikirler, dahi zeka ve icatlar.'),
      const EgyptianTermInfo(sign: 'Kova', startDegree: 7, endDegree: 13, rulingPlanet: 'Venüs ♀︎', meaning: 'Özgür dostluklar, sıra dışı sanat ve hümanizm.'),
      const EgyptianTermInfo(sign: 'Kova', startDegree: 13, endDegree: 20, rulingPlanet: 'Jüpiter ♃', meaning: 'Kolektif vizyon, insanlık idealleri ve küresel projeler.'),
      const EgyptianTermInfo(sign: 'Kova', startDegree: 20, endDegree: 25, rulingPlanet: 'Mars ♂︎', meaning: 'Sosyal isyan, reform cesareti ve tabuları yıkma gücü.'),
      const EgyptianTermInfo(sign: 'Kova', startDegree: 25, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Yeni çağın yapı taşları, kurallar ve bağımsız güç.'),
    ],
    'Balık': [
      const EgyptianTermInfo(sign: 'Balık', startDegree: 0, endDegree: 12, rulingPlanet: 'Venüs ♀︎', meaning: 'Yüce aşk, ilahi sanat, koşulsuz kabul ve ruhsal zarafet.'),
      const EgyptianTermInfo(sign: 'Balık', startDegree: 12, endDegree: 16, rulingPlanet: 'Jüpiter ♃', meaning: 'Manevi sırlar, evrensel bereket ve koruyucu lütuflar.'),
      const EgyptianTermInfo(sign: 'Balık', startDegree: 16, endDegree: 19, rulingPlanet: 'Merkür ☿', meaning: 'Telepatik iletişim, şairane ilham ve mistik sezgi.'),
      const EgyptianTermInfo(sign: 'Balık', startDegree: 19, endDegree: 28, rulingPlanet: 'Mars ♂︎', meaning: 'Ruhsal savaşçılık, negatif enerjileri defetme gücü.'),
      const EgyptianTermInfo(sign: 'Balık', startDegree: 28, endDegree: 30, rulingPlanet: 'Satürn ♄', meaning: 'Karmik döngünün kapanışı, mutlak teslimiyet ve bilgelik.'),
    ],
  };

  // KABALA 72 MELEK (SHEM HAMEPHORASH) - 360° ÇARKTA HER 5 DERECE
  static final List<KabbalahAngelInfo> _allAngels = [
    // 0° - 30° Koç
    const KabbalahAngelInfo(number: 1, name: 'Vehuiah', sign: 'Koç', startDegree: 0, endDegree: 5, choir: 'Serafim', virtue: 'İlahi İrade', meaning: 'Yaratıcı irade, girişim cesareti, ilahi ilham ve zorlukları aşan yüksek enerji.'),
    const KabbalahAngelInfo(number: 2, name: 'Jeliel', sign: 'Koç', startDegree: 5, endDegree: 10, choir: 'Serafim', virtue: 'Huzur ve Adalet', meaning: 'Huzur, sadakat, adalet duygusu ve ilişkilerde barışın tesisi.'),
    const KabbalahAngelInfo(number: 3, name: 'Sitael', sign: 'Koç', startDegree: 10, endDegree: 15, choir: 'Serafim', virtue: 'İnşa Gücü', meaning: 'İnşa edici güç, verilen sözleri tutma ve güçlükleri aşma metaneti.'),
    const KabbalahAngelInfo(number: 4, name: 'Elemiah', sign: 'Koç', startDegree: 15, endDegree: 20, choir: 'Serafim', virtue: 'İçsel Huzur', meaning: 'İçsel huzur, yolculuklarda himaye ve ruhsal krizlerin şifası.'),
    const KabbalahAngelInfo(number: 5, name: 'Mahasiah', sign: 'Koç', startDegree: 20, endDegree: 25, choir: 'Serafim', virtue: 'Kozmik Uyum', meaning: 'Kozmik uyum, yüksek ilimler, barışçıl mizaç ve zihinsel dinginlik.'),
    const KabbalahAngelInfo(number: 6, name: 'Lelahel', sign: 'Koç', startDegree: 25, endDegree: 30, choir: 'Serafim', virtue: 'Evrensel Şifa', meaning: 'Evrensel şifa, sevgi ışığı, sanatsal ilham ve aydınlanma.'),

    // 0° - 30° Boğa
    const KabbalahAngelInfo(number: 7, name: 'Achaiah', sign: 'Boğa', startDegree: 0, endDegree: 5, choir: 'Kerubim', virtue: 'Sabır ve Sır', meaning: 'Sabır, doğanın sırlarını çözme ve derin tefekkür gücü.'),
    const KabbalahAngelInfo(number: 8, name: 'Cahetel', sign: 'Boğa', startDegree: 5, endDegree: 10, choir: 'Kerubim', virtue: 'Bereket', meaning: 'Bereket, şükür bilinci ve doğanın lütuflarıyla uyum içinde yaşama.'),
    const KabbalahAngelInfo(number: 9, name: 'Haziel', sign: 'Boğa', startDegree: 10, endDegree: 15, choir: 'Kerubim', virtue: 'İlahi Merhamet', meaning: 'İlahi merhamet, samimi dostluklar ve verilen sözlerin bereketi.'),
    const KabbalahAngelInfo(number: 10, name: 'Aladiah', sign: 'Boğa', startDegree: 15, endDegree: 20, choir: 'Kerubim', virtue: 'Karmik Arınma', meaning: 'Ruhsal ve bedensel şifa, karmik arınma ve yeniden başlama şansı.'),
    const KabbalahAngelInfo(number: 11, name: 'Lauviah', sign: 'Boğa', startDegree: 20, endDegree: 25, choir: 'Kerubim', virtue: 'Zafer', meaning: 'Zafer, hakikate ulaşma ve yüksek manevi bilgelik.'),
    const KabbalahAngelInfo(number: 12, name: 'Hahaiah', sign: 'Boğa', startDegree: 25, endDegree: 30, choir: 'Kerubim', virtue: 'Manevi Sığınak', meaning: 'Manevi sığınak, derin rüyalar ve sezgisel içsel dinginlik.'),

    // 0° - 30° İkizler
    const KabbalahAngelInfo(number: 13, name: 'Yezalel', sign: 'İkizler', startDegree: 0, endDegree: 5, choir: 'Tahtlar', virtue: 'Sadakat ve Birlik', meaning: 'Sadakat, dostluk ve zihin-ruh dengesinin kusursuz tesisi.'),
    const KabbalahAngelInfo(number: 14, name: 'Mebahel', sign: 'İkizler', startDegree: 5, endDegree: 10, choir: 'Tahtlar', virtue: 'Adalet ve Hakikat', meaning: 'Hakikat, adalet, özgürlük ve masumların göksel koruması.'),
    const KabbalahAngelInfo(number: 15, name: 'Hariel', sign: 'İkizler', startDegree: 10, endDegree: 15, choir: 'Tahtlar', virtue: 'Ruhsal Saflık', meaning: 'Ruhsal saflık, arınma ve bilimle inancın sentezi.'),
    const KabbalahAngelInfo(number: 16, name: 'Hakamiah', sign: 'İkizler', startDegree: 15, endDegree: 20, choir: 'Tahtlar', virtue: 'Liderlik Asaleti', meaning: 'Sadakat, asalet, liderlik gücü ve sözünün eri olma erdemi.'),
    const KabbalahAngelInfo(number: 17, name: 'Lauviah II', sign: 'İkizler', startDegree: 20, endDegree: 25, choir: 'Tahtlar', virtue: 'Rüya İlhamı', meaning: 'Uyku ve rüya vahiyleri, melankoliyi aşma ve derin sevinç.'),
    const KabbalahAngelInfo(number: 18, name: 'Caliel', sign: 'İkizler', startDegree: 25, endDegree: 30, choir: 'Tahtlar', virtue: 'Masumiyetin Zaferi', meaning: 'Masumiyetin zaferi, hakikatin açığa çıkması ve adil muhakeme.'),

    // 0° - 30° Yengeç
    const KabbalahAngelInfo(number: 19, name: 'Leuviah', sign: 'Yengeç', startDegree: 0, endDegree: 5, choir: 'Hakimiyetler', virtue: 'Bereketli Hafıza', meaning: 'Bereketli hafıza, yüksek zeka ve sabırlı duygusal bilgelik.'),
    const KabbalahAngelInfo(number: 20, name: 'Pahaliah', sign: 'Yengeç', startDegree: 5, endDegree: 10, choir: 'Hakimiyetler', virtue: 'Manevi Uyanış', meaning: 'Ahlaki erdem, manevi uyanış ve içsel arınma tutkusu.'),
    const KabbalahAngelInfo(number: 21, name: 'Nelchael', sign: 'Yengeç', startDegree: 10, endDegree: 15, choir: 'Hakimiyetler', virtue: 'Öğrenme Tutkusu', meaning: 'Öğrenme aşkı, astronomi ve soyut bilimlerde ustalık.'),
    const KabbalahAngelInfo(number: 22, name: 'Yeiayel', sign: 'Yengeç', startDegree: 15, endDegree: 20, choir: 'Hakimiyetler', virtue: 'Diplomasi ve Saygınlık', meaning: 'Diplomasi, saygınlık, deniz aşırı koruma ve ticaret bereketi.'),
    const KabbalahAngelInfo(number: 23, name: 'Melahel', sign: 'Yengeç', startDegree: 20, endDegree: 25, choir: 'Hakimiyetler', virtue: 'Doğa Tıbbı', meaning: 'Şifalı bitkiler, doğa tıbbı ve bedensel şifalanma bereketi.'),
    const KabbalahAngelInfo(number: 24, name: 'Haheuiah', sign: 'Yengeç', startDegree: 25, endDegree: 30, choir: 'Hakimiyetler', virtue: 'İlahi Koruma', meaning: 'Sığınma, ilahi koruma ve tehlikelerden muhafaza olma gücü.'),

    // 0° - 30° Aslan
    const KabbalahAngelInfo(number: 25, name: 'Nithaiah', sign: 'Aslan', startDegree: 0, endDegree: 5, choir: 'Güçler', virtue: 'Yüksek Bilgelik', meaning: 'Manevi sırlar, yüksek bilgelik ve zamanın ruhunu kavrama.'),
    const KabbalahAngelInfo(number: 26, name: 'Haaiah', sign: 'Aslan', startDegree: 5, endDegree: 10, choir: 'Güçler', virtue: 'Sağduyu', meaning: 'Sağduyu, gizli planları sezme ve siyasi/diplomatik adalet.'),
    const KabbalahAngelInfo(number: 27, name: 'Yerathel', sign: 'Aslan', startDegree: 10, endDegree: 15, choir: 'Güçler', virtue: 'Işığın Yayılması', meaning: 'Işığın yayılması, haksız ithamlardan arınma ve özgürlük.'),
    const KabbalahAngelInfo(number: 28, name: 'Seheiah', sign: 'Aslan', startDegree: 15, endDegree: 20, choir: 'Güçler', virtue: 'Uzun Ömür', meaning: 'Uzun ömür, kazalardan korunma ve basiretli sağduyu.'),
    const KabbalahAngelInfo(number: 29, name: 'Reyiel', sign: 'Aslan', startDegree: 20, endDegree: 25, choir: 'Güçler', virtue: 'Özgürleşme', meaning: 'Özgürleşme, manevi meditasyon ve hakikati cesaretle savunma.'),
    const KabbalahAngelInfo(number: 30, name: 'Omael', sign: 'Aslan', startDegree: 25, endDegree: 30, choir: 'Güçler', virtue: 'Üretkenlik ve Neşe', meaning: 'Üretkenlik, sabır, canlılara şefkat ve yaşama sevinci.'),

    // 0° - 30° Başak
    const KabbalahAngelInfo(number: 31, name: 'Lecabel', sign: 'Başak', startDegree: 0, endDegree: 5, choir: 'Erdemler', virtue: 'Stratejik Akıl', meaning: 'Parlak fikirler, matematik ve stratejik zihinsel berraklık.'),
    const KabbalahAngelInfo(number: 32, name: 'Vasariah', sign: 'Başak', startDegree: 5, endDegree: 10, choir: 'Erdemler', virtue: 'Merhametli Adalet', meaning: 'Merhametli adalet, bağışlama ve zarif ifade gücü.'),
    const KabbalahAngelInfo(number: 33, name: 'Yehuiah', sign: 'Başak', startDegree: 10, endDegree: 15, choir: 'Erdemler', virtue: 'Düzen ve Sadakat', meaning: 'Sadakat, hiyerarşide düzen ve sorumluluk bilinci.'),
    const KabbalahAngelInfo(number: 34, name: 'Lehahiah', sign: 'Başak', startDegree: 15, endDegree: 20, choir: 'Erdemler', virtue: 'Kırılmaz Sadakat', meaning: 'Kırılmaz sadakat, barışçıl mizaç ve sadık hizmet erdemi.'),
    const KabbalahAngelInfo(number: 35, name: 'Chavakiah', sign: 'Başak', startDegree: 20, endDegree: 25, choir: 'Erdemler', virtue: 'Ailede Uzlaşma', meaning: 'Aile içi uzlaşma, miraslarda adalet ve dargınlıkları bitirme.'),
    const KabbalahAngelInfo(number: 36, name: 'Menadel', sign: 'Başak', startDegree: 25, endDegree: 30, choir: 'Erdemler', virtue: 'İç Huzur', meaning: 'Rızık bereketi, iç huzur ve kayıpları geri kazanma metaneti.'),

    // 0° - 30° Terazi
    const KabbalahAngelInfo(number: 37, name: 'Aniel', sign: 'Terazi', startDegree: 0, endDegree: 5, choir: 'Hükümranlıklar', virtue: 'Zafer İradesi', meaning: 'Zafer, engelleri aşma iradesi ve felsefi kavrayış.'),
    const KabbalahAngelInfo(number: 38, name: 'Haamiah', sign: 'Terazi', startDegree: 5, endDegree: 10, choir: 'Hükümranlıklar', virtue: 'Yüksek Ahlak', meaning: 'Manevi ritüeller, yüksek ahlak ve hakikati arayış.'),
    const KabbalahAngelInfo(number: 39, name: 'Rehael', sign: 'Terazi', startDegree: 10, endDegree: 15, choir: 'Hükümranlıklar', virtue: 'Aile Sevgisi', meaning: 'Evlat ve ebeveyn sevgisi, saygı ve hızlı bedensel iyileşme.'),
    const KabbalahAngelInfo(number: 40, name: 'Ieiazel', sign: 'Terazi', startDegree: 15, endDegree: 20, choir: 'Hükümranlıklar', virtue: 'Edebi İlham', meaning: 'Kederden kurtulma, edebi yetenek ve yazma ilhamı.'),
    const KabbalahAngelInfo(number: 41, name: 'Hahahel', sign: 'Terazi', startDegree: 20, endDegree: 25, choir: 'Hükümranlıklar', virtue: 'Kutsal Adanmışlık', meaning: 'Kutsal adanmışlık, inanç gücü ve manevi misyon bilinci.'),
    const KabbalahAngelInfo(number: 42, name: 'Mikael', sign: 'Terazi', startDegree: 25, endDegree: 30, choir: 'Hükümranlıklar', virtue: 'Siyasi Denge', meaning: 'Siyasi denge, kamu güvenliği ve liderlik basireti.'),

    // 0° - 30° Akrep
    const KabbalahAngelInfo(number: 43, name: 'Veuliah', sign: 'Akrep', startDegree: 0, endDegree: 5, choir: 'Başmelekler', virtue: 'İçsel Refah', meaning: 'Bereket, esaretten kurtuluş ve içsel refahın yükselişi.'),
    const KabbalahAngelInfo(number: 44, name: 'Yelahiah', sign: 'Akrep', startDegree: 5, endDegree: 10, choir: 'Başmelekler', virtue: 'Cesaret Kalkanı', meaning: 'Cesaret, cesur kararlar alma ve zor davaları kazanma gücü.'),
    const KabbalahAngelInfo(number: 45, name: 'Sealiah', sign: 'Akrep', startDegree: 10, endDegree: 15, choir: 'Başmelekler', virtue: 'Yeniden Canlanma', meaning: 'Alçakgönüllülük, yeniden canlanma ve doğanın gizli gücü.'),
    const KabbalahAngelInfo(number: 46, name: 'Ariel', sign: 'Akrep', startDegree: 15, endDegree: 20, choir: 'Başmelekler', virtue: 'Keşif Yeteneği', meaning: 'Gizli hazineler, vizyoner rüyalar ve derin keşif yeteneği.'),
    const KabbalahAngelInfo(number: 47, name: 'Asaliah', sign: 'Akrep', startDegree: 20, endDegree: 25, choir: 'Başmelekler', virtue: 'Göksel Adalet', meaning: 'Göksel adaleti anlama, hakikate övgü ve derin kavrayış.'),
    const KabbalahAngelInfo(number: 48, name: 'Mihael', sign: 'Akrep', startDegree: 25, endDegree: 30, choir: 'Başmelekler', virtue: 'Sadakat ve Aşk', meaning: 'Evlilikte sadakat, eşler arası aşk ve duygusal uyum.'),

    // 0° - 30° Yay
    const KabbalahAngelInfo(number: 49, name: 'Vehuel', sign: 'Yay', startDegree: 0, endDegree: 5, choir: 'Melekler', virtue: 'Yüce Gönüllülük', meaning: 'Yüce gönüllülük, affedicilik ve ruhsal yüceliş.'),
    const KabbalahAngelInfo(number: 50, name: 'Daniel', sign: 'Yay', startDegree: 5, endDegree: 10, choir: 'Melekler', virtue: 'Belagat', meaning: 'Belagat, güzel konuşma, teselli ve bağışlayıcı merhamet.'),
    const KabbalahAngelInfo(number: 51, name: 'Hahasiah', sign: 'Yay', startDegree: 10, endDegree: 15, choir: 'Melekler', virtue: 'Ezoterik Bilgelik', meaning: 'Ezoterik bilgelik, kadim tıp ve kimya/simya sırları.'),
    const KabbalahAngelInfo(number: 52, name: 'Imamiah', sign: 'Yay', startDegree: 15, endDegree: 20, choir: 'Melekler', virtue: 'Hatalardan Dönüş', meaning: 'Kefaret, esaretten kurtulma ve hatalardan dönme erdemi.'),
    const KabbalahAngelInfo(number: 53, name: 'Nanael', sign: 'Yay', startDegree: 20, endDegree: 25, choir: 'Melekler', virtue: 'Manevi Öğretmenlik', meaning: 'Manevi ilimler, tefekkür ve yüksek manevi öğretmenlik.'),
    const KabbalahAngelInfo(number: 54, name: 'Nithael', sign: 'Yay', startDegree: 25, endDegree: 30, choir: 'Melekler', virtue: 'Hükümdarlık Zarafeti', meaning: 'Hükümdarlık zarafeti, meşruiyet ve uzun ömür bereketi.'),

    // 0° - 30° Oğlak
    const KabbalahAngelInfo(number: 55, name: 'Mebahiah', sign: 'Oğlak', startDegree: 0, endDegree: 5, choir: 'Melekler', virtue: 'Ahlaki Eylem', meaning: 'Ahlaki eylemler, verimli fikirler ve üretken sorumluluk.'),
    const KabbalahAngelInfo(number: 56, name: 'Poyel', sign: 'Oğlak', startDegree: 5, endDegree: 10, choir: 'Melekler', virtue: 'Talih ve Şöhret', meaning: 'Şöhret, talih, nezaket ve sınırsız manevi zenginlik.'),
    const KabbalahAngelInfo(number: 57, name: 'Nemamiah', sign: 'Oğlak', startDegree: 10, endDegree: 15, choir: 'Serafim', virtue: 'Stratejik Önderlik', meaning: 'Stratejik önderlik, sabır ve yüksek ideallere adanmışlık.'),
    const KabbalahAngelInfo(number: 58, name: 'Yeialel', sign: 'Oğlak', startDegree: 15, endDegree: 20, choir: 'Serafim', virtue: 'Demir İrade', meaning: 'Zihinsel berraklık, demir irade ve basiret.'),
    const KabbalahAngelInfo(number: 59, name: 'Harahel', sign: 'Oğlak', startDegree: 20, endDegree: 25, choir: 'Serafim', virtue: 'Entelektüel Zenginlik', meaning: 'Entelektüel zenginlik, kütüphaneler, kitaplar ve bilgelik.'),
    const KabbalahAngelInfo(number: 60, name: 'Mitzrael', sign: 'Oğlak', startDegree: 25, endDegree: 30, choir: 'Serafim', virtue: 'Zihinsel İyileşme', meaning: 'Ruhsal ve zihinsel iyileşme, otoriteyle barış ve erdem.'),

    // 0° - 30° Kova
    const KabbalahAngelInfo(number: 61, name: 'Umabel', sign: 'Kova', startDegree: 0, endDegree: 5, choir: 'Kerubim', virtue: 'Evren Sevgisi', meaning: 'Dostluk, astronomi/astroloji sevgisi ve fiziksel evreni anlama.'),
    const KabbalahAngelInfo(number: 62, name: 'Iah-hel', sign: 'Kova', startDegree: 5, endDegree: 10, choir: 'Kerubim', virtue: 'Aydınlanma', meaning: 'Aydınlanma, inziva dinginliği ve yüksek manevi bilgelik.'),
    const KabbalahAngelInfo(number: 63, name: 'Anauel', sign: 'Kova', startDegree: 10, endDegree: 15, choir: 'Kerubim', virtue: 'Ticaret Başarısı', meaning: 'Sağlık, ticaret başarısı ve manevi koruma kalkanı.'),
    const KabbalahAngelInfo(number: 64, name: 'Mehiel', sign: 'Kova', startDegree: 15, endDegree: 20, choir: 'Kerubim', virtue: 'Sözün Gücü', meaning: 'Yaratıcı yazarlık, entelektüel ilham ve sözün büyüleyici gücü.'),
    const KabbalahAngelInfo(number: 65, name: 'Damabiah', sign: 'Kova', startDegree: 20, endDegree: 25, choir: 'Tahtlar', virtue: 'Kozmik Koruma', meaning: 'Kozmik koruma, denizlerin bereketi ve kem gözden muhafaza.'),
    const KabbalahAngelInfo(number: 66, name: 'Manakel', sign: 'Kova', startDegree: 25, endDegree: 30, choir: 'Tahtlar', virtue: 'Rüya Tabiri', meaning: 'İçsel huzur, rüya tabiri ve ruhsal dinginlik.'),

    // 0° - 30° Balık
    const KabbalahAngelInfo(number: 67, name: 'Eyael', sign: 'Balık', startDegree: 0, endDegree: 5, choir: 'Tahtlar', virtue: 'Dönüşüm Simyası', meaning: 'Dönüşüm simyası, uzun ömür ve yüksek felsefe bilinci.'),
    const KabbalahAngelInfo(number: 68, name: 'Habuhiah', sign: 'Balık', startDegree: 5, endDegree: 10, choir: 'Tahtlar', virtue: 'Canlıları İyileştirme', meaning: 'Toprak bereketi, tarım, şifa ve canlıları iyileştirme gücü.'),
    const KabbalahAngelInfo(number: 69, name: 'Rochel', sign: 'Balık', startDegree: 10, endDegree: 15, choir: 'Hakimiyetler', virtue: 'Hakkaniyet', meaning: 'Adil miras, kayıp eşyaları bulma ve mutlak hakkaniyet.'),
    const KabbalahAngelInfo(number: 70, name: 'Jabamiah', sign: 'Balık', startDegree: 15, endDegree: 20, choir: 'Hakimiyetler', virtue: 'Yenilenme Simyası', meaning: 'Simyasal dönüşüm, yenilenme ve ruhsal arınma.'),
    const KabbalahAngelInfo(number: 71, name: 'Haiaiel', sign: 'Balık', startDegree: 20, endDegree: 25, choir: 'Hakimiyetler', virtue: 'Cesaret Kalkanı', meaning: 'Cesaret kalkanı, karanlığı defetme ve mutlak zafer.'),
    const KabbalahAngelInfo(number: 72, name: 'Mumiah', sign: 'Balık', startDegree: 25, endDegree: 30, choir: 'Hakimiyetler', virtue: 'Döngüleri Tamamlama', meaning: 'Döngüleri tamamlama, nihai şifa, simya ve yeniden diriliş kapısı.'),
  ];

  // Gezegenin burç ve derecesine göre Dekan bul
  static DecanInfo getDecanForPosition(String sign, double degreeInSign) {
    int decanIdx = (degreeInSign / 10.0).floor().clamp(0, 2);
    final signDecans = _allDecans.where((d) => d.sign == sign).toList();
    if (signDecans.isNotEmpty && decanIdx < signDecans.length) {
      return signDecans[decanIdx];
    }
    return _allDecans.first;
  }

  // Gezegenin burç ve derecesine göre Mısır Terimi (Bound) bul
  static EgyptianTermInfo getEgyptianTermForPosition(String sign, double degreeInSign) {
    final terms = _egyptianTerms[sign];
    if (terms != null) {
      for (final t in terms) {
        if (degreeInSign >= t.startDegree && degreeInSign < t.endDegree) {
          return t;
        }
      }
      return terms.last;
    }
    return _egyptianTerms.values.first.first;
  }

  // Gezegenin burç ve derecesine göre 72 Kabala Meleği bul
  static KabbalahAngelInfo getAngelForPosition(String sign, double degreeInSign) {
    int signIdx = zodiacSigns.indexOf(sign);
    if (signIdx < 0) signIdx = 0;
    double totalDegree = (signIdx * 30.0) + degreeInSign;
    int angelIdx = (totalDegree / 5.0).floor().clamp(0, 71);
    return _allAngels[angelIdx];
  }

  static List<DecanInfo> getAllDecans() => _allDecans;
  static Map<String, List<EgyptianTermInfo>> getAllEgyptianTerms() => _egyptianTerms;
  static List<KabbalahAngelInfo> getAllAngels() => _allAngels;
}
