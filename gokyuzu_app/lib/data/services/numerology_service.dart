import 'dart:convert';

/// Kadim Pisagor ve Keldani Ekolü Kozmik Numeroloji Servisi
class NumerologyResult {
  final int lifePathNumber; // Yaşam Yolu (Doğum Tarihi)
  final String lifePathTitle;
  final String lifePathArchetype;
  final String lifePathDescription;
  final String lifePathStrengths;
  final String lifePathChallenges;
  final String cosmicColor;
  final String rulingPlanet;

  final int destinyNumber; // Kader / İsim Sayısı (Tüm Harfler)
  final String destinyTitle;
  final String destinyMeaning;

  final int soulUrgeNumber; // Ruh Güdüsü / Kalp Arzusu (Ünlü Harfler)
  final String soulUrgeTitle;
  final String soulUrgeMeaning;

  final int personalityNumber; // Kişilik / Sosyal Maske (Ünsüz Harfler)
  final String personalityTitle;
  final String personalityMeaning;

  final int personalYearNumber; // Kişisel Yıl Döngüsü (2026/Mevcut Yıl)
  final String personalYearTitle;
  final String personalYearForecast;

  final bool isMasterNumber;

  const NumerologyResult({
    required this.lifePathNumber,
    required this.lifePathTitle,
    required this.lifePathArchetype,
    required this.lifePathDescription,
    required this.lifePathStrengths,
    required this.lifePathChallenges,
    required this.cosmicColor,
    required this.rulingPlanet,
    required this.destinyNumber,
    required this.destinyTitle,
    required this.destinyMeaning,
    required this.soulUrgeNumber,
    required this.soulUrgeTitle,
    required this.soulUrgeMeaning,
    required this.personalityNumber,
    required this.personalityTitle,
    required this.personalityMeaning,
    required this.personalYearNumber,
    required this.personalYearTitle,
    required this.personalYearForecast,
    required this.isMasterNumber,
  });
}

class NumerologyService {
  // Pisagor Alfabe Sayısal Matrisi (Türkçe Karakter Uyumlu)
  static final Map<String, int> _pythagoreanMap = {
    'A': 1, 'J': 1, 'S': 1, 'Ş': 1,
    'B': 2, 'K': 2, 'T': 2,
    'C': 3, 'Ç': 3, 'L': 3, 'U': 3, 'Ü': 3,
    'D': 4, 'M': 4, 'V': 4,
    'E': 5, 'N': 5, 'W': 5,
    'F': 6, 'O': 6, 'Ö': 6, 'X': 6,
    'G': 7, 'Ğ': 7, 'P': 7, 'Y': 7,
    'H': 8, 'Q': 8, 'Z': 8,
    'I': 9, 'İ': 9, 'R': 9,
  };

  static final Set<String> _vowels = {
    'A', 'E', 'I', 'İ', 'O', 'Ö', 'U', 'Ü',
  };

  /// Doğum Tarihi ve Tam İsimden Kozmik Numeroloji Matrisini Hesaplar
  static NumerologyResult calculate({
    required String fullName,
    required String birthDate, // Format: YYYY-MM-DD veya DD.MM.YYYY
  }) {
    final cleanName = fullName.toUpperCase().replaceAll(RegExp(r'[^A-ZÇĞİÖŞÜ]'), '');
    final birthDateDigits = birthDate.replaceAll(RegExp(r'[^0-9]'), '');

    // 1. Yaşam Yolu Sayısı (Life Path)
    final lifePath = _calculateLifePath(birthDateDigits);

    // 2. Kader / İsim Sayısı (Destiny)
    final destiny = _calculateDestiny(cleanName);

    // 3. Ruh Güdüsü (Soul Urge) - Sesli Harfler
    final soulUrge = _calculateSoulUrge(cleanName);

    // 4. Kişilik Sayısı (Personality) - Sessiz Harfler
    final personality = _calculatePersonality(cleanName);

    // 5. Kişisel Yıl Döngüsü (Personal Year)
    final personalYear = _calculatePersonalYear(birthDateDigits);

    final lifePathInfo = _getLifePathDetails(lifePath);
    final destinyInfo = _getDestinyDetails(destiny);
    final soulUrgeInfo = _getSoulUrgeDetails(soulUrge);
    final personalityInfo = _getPersonalityDetails(personality);
    final personalYearInfo = _getPersonalYearDetails(personalYear);

    return NumerologyResult(
      lifePathNumber: lifePath,
      lifePathTitle: lifePathInfo['title']!,
      lifePathArchetype: lifePathInfo['archetype']!,
      lifePathDescription: lifePathInfo['description']!,
      lifePathStrengths: lifePathInfo['strengths']!,
      lifePathChallenges: lifePathInfo['challenges']!,
      cosmicColor: lifePathInfo['color']!,
      rulingPlanet: lifePathInfo['planet']!,
      destinyNumber: destiny,
      destinyTitle: destinyInfo['title']!,
      destinyMeaning: destinyInfo['meaning']!,
      soulUrgeNumber: soulUrge,
      soulUrgeTitle: soulUrgeInfo['title']!,
      soulUrgeMeaning: soulUrgeInfo['meaning']!,
      personalityNumber: personality,
      personalityTitle: personalityInfo['title']!,
      personalityMeaning: personalityInfo['meaning']!,
      personalYearNumber: personalYear,
      personalYearTitle: personalYearInfo['title']!,
      personalYearForecast: personalYearInfo['forecast']!,
      isMasterNumber: lifePath == 11 || lifePath == 22 || lifePath == 33,
    );
  }

  static int _reduceNumber(int num, {bool preserveMaster = true}) {
    while (num > 9) {
      if (preserveMaster && (num == 11 || num == 22 || num == 33)) {
        return num;
      }
      int sum = 0;
      for (final digit in num.toString().split('')) {
        sum += int.tryParse(digit) ?? 0;
      }
      num = sum;
    }
    return num;
  }

  static int _calculateLifePath(String digits) {
    if (digits.length < 8) return 1;
    int sum = 0;
    for (final char in digits.split('')) {
      sum += int.tryParse(char) ?? 0;
    }
    return _reduceNumber(sum, preserveMaster: true);
  }

  static int _calculateDestiny(String name) {
    if (name.isEmpty) return 1;
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      sum += _pythagoreanMap[char] ?? 0;
    }
    return _reduceNumber(sum, preserveMaster: true);
  }

  static int _calculateSoulUrge(String name) {
    if (name.isEmpty) return 1;
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (_vowels.contains(char)) {
        sum += _pythagoreanMap[char] ?? 0;
      }
    }
    return _reduceNumber(sum == 0 ? 1 : sum, preserveMaster: true);
  }

  static int _calculatePersonality(String name) {
    if (name.isEmpty) return 1;
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (!_vowels.contains(char)) {
        sum += _pythagoreanMap[char] ?? 0;
      }
    }
    return _reduceNumber(sum == 0 ? 1 : sum, preserveMaster: false);
  }

  static int _calculatePersonalYear(String digits) {
    // Doğum Günü + Doğum Ayı + Mevcut Yıl
    final currentYear = DateTime.now().year; // 2026
    int day = 1;
    int month = 1;

    if (digits.length >= 8) {
      // YYYYMMDD veya DDMMYYYY kontrolü
      if (int.tryParse(digits.substring(0, 4)) != null && int.parse(digits.substring(0, 4)) > 1900) {
        month = int.tryParse(digits.substring(4, 6)) ?? 1;
        day = int.tryParse(digits.substring(6, 8)) ?? 1;
      } else {
        day = int.tryParse(digits.substring(0, 2)) ?? 1;
        month = int.tryParse(digits.substring(2, 4)) ?? 1;
      }
    }

    int sum = day + month + currentYear;
    return _reduceNumber(sum, preserveMaster: false);
  }

  static Map<String, String> _getLifePathDetails(int num) {
    switch (num) {
      case 1:
        return {
          'title': '1 • ÖNCÜ & DOĞUŞTAN LİDER',
          'archetype': 'Güneş Ateşi • Başlatıcı Güç',
          'description': 'Kendi yolunu çizen, bağımsızlığına düşkün, kararlı ve vizyoner bir ruha sahipsiniz. Başkalarının arkasından gitmek değil, patikayı ilk açan olmak için buradasınız.',
          'strengths': 'Yüksek özgüven, cesaret, yaratıcı inisiyatif, bağımsızlık ve kriz anında karar alma yetisi.',
          'challenges': 'Bencillik, aşırı baskınlık, sabırsızlık ve başkalarına güvenmekte zorlanma.',
          'color': 'Kraliyet Altını & Yakut Kırmızısı',
          'planet': 'Güneş (Sol)',
        };
      case 2:
        return {
          'title': '2 • BARIŞ ELÇİSİ & SEZGİSEL REHBER',
          'archetype': 'Ay Suyu • Uyum & Diplomasi',
          'description': 'İnsan ruhunun derinliklerini hisseden, sezgileri inanılmaz güçlü, empati ustası bir ruhsunuz. Zıtlıkları birleştirmek ve kaosu dengelemek temel kozmik görevinizdir.',
          'strengths': 'Derin duygusal zeka, diplomasi, sabır, işbirliği ve gizli niyetleri sezme gücü.',
          'challenges': 'Aşırı alınganlık, kararsızlık, kendi ihtiyaçlarını hiçe sayıp başkalarına feda olma.',
          'color': 'Gümüş Beyazı & Pastel Deniz Mavisi',
          'planet': 'Ay (Luna)',
        };
      case 3:
        return {
          'title': '3 • SANATÇI & KOZMİK İLETİŞİMCİ',
          'archetype': 'Jüpiter Işığı • Neşe & İfade',
          'description': 'Kelimeler, sanat ve yaratıcılık sizin yaşam yakıtınız. Çevrenize ilham saçan, karanlık odaları neşesiyle aydınlatan kozmik bir çocuk arketipine sahipsiniz.',
          'strengths': 'Retorik yeteneği, karizma, sanatsal ilham, iyimserlik ve insanları canlandırma gücü.',
          'challenges': 'Odaklanma eksikliği, enerjiyi dağıtma, yüzeysellik ve eleştiriye aşırı hassasiyet.',
          'color': 'Güneş Sarısı & Zümrüt Yeşili',
          'planet': 'Jüpiter (Guru)',
        };
      case 4:
        return {
          'title': '4 • İNŞA EDİCİ & SARSILMAZ MİMAR',
          'archetype': 'Satürn Toprağı • Düzen & Güven',
          'description': 'Hayatın sağlam temellerini atan, azimli, sadık ve gerçekçi bir zihne sahipsiniz. Fırtınalarda herkes savrulurken dimdik ayakta kalan kale sizsiniz.',
          'strengths': 'Sonsuz dayanıklılık, pratik zeka, organizasyon kabiliyeti, dürüstlük ve sadakat.',
          'challenges': 'Aşırı katılık, yeniliklere direnç, kuruntuculuk ve duyguları bastırma eğilimi.',
          'color': 'Toprak Kahvesi & Zümrüt Nehir Yeşili',
          'planet': 'Uranüs & Satürn',
        };
      case 5:
        return {
          'title': '5 • ÖZGÜR RUH & KOZMİK GEZGİN',
          'archetype': 'Merkür Havası • Değişim & Macera',
          'description': 'Sıradanlığa tahammülü olmayan, yenilik ve bilgi peşinde koşan dinamik bir ruha sahipsiniz. Değişimin rüzgarı nereden eserse siz oraya yelken açarsınız.',
          'strengths': 'Uyum kabiliyeti, çok yönlülük, merak, çekicilik ve risk alma cesareti.',
          'challenges': 'Maymun iştahlılık, huzursuzluk, bağımlılık tuzakları ve tutarsızlık.',
          'color': 'Turkuaz Mavisi & Parlak Portakal',
          'planet': 'Merkür (Hermes)',
        };
      case 6:
        return {
          'title': '6 • KORUYUCU & KOZMİK ŞİFACI',
          'archetype': 'Venüs Sevgisi • Koşulsuz Sevgi & Aile',
          'description': 'Ailenin, toplumun ve ezilenlerin sığınağısınız. Adalet, güzellik, estetik ve şifa enerjinizle girdiğiniz her ortama huzur getirirsiniz.',
          'strengths': 'Fedakarlık, estetik zevk, şefkat, sorumluluk bilinci ve danışmanlık yeteneği.',
          'challenges': 'Kurtarıcı kompleksi, başkalarının hayatına aşırı müdahale, mükemmeliyetçilik.',
          'color': 'Gül Kurusu & İndigo Mavisi',
          'planet': 'Venüs (Afrodit)',
        };
      case 7:
        return {
          'title': '7 • MİSTİK & BİLGE FİLOZOF',
          'archetype': 'Neptün Sisi • Gizem & Hakikat',
          'description': 'Görünenin ardındaki görünmeyeni arayan, okült ve metafizik derinliği olan bir zihinsiniz. Yalnızlık sizin için bir ceza değil, kutsal bir mabet alanıdır.',
          'strengths': 'Keskin analitik sezgi, manevi derinlik, bilgelik, araştırma ve hakikati bulma.',
          'challenges': 'İnsanlardan kopukluk, soğukluk, şüphecilik, melankoli ve kibir.',
          'color': 'Gece Mavisi & Ametist Moru',
          'planet': 'Neptün & Kethu',
        };
      case 8:
        return {
          'title': '8 • GÜÇ VE BOLLUK MASTERI',
          'archetype': 'Satürn Zirvesi • Maddi & Manevi Otorite',
          'description': 'Karmik döngülerin, finansal ve manevi gücün yöneticisisiniz. Büyük vizyonları gerçeğe dönüştürme ve adaleti tesis etme potansiyeliyle dünyaya geldiniz.',
          'strengths': 'Liderlik, stratejik deha, finansal vizyon, kararlılık ve kriz yönetimi.',
          'challenges': 'Güç sarhoşluğu, materyalizm, merhametsizlik ve kontrol takıntısı.',
          'color': 'Koyu Bordo & Gece Siyahı',
          'planet': 'Satürn & Mars',
        };
      case 9:
        return {
          'title': '9 • EVRENSEL İNSAN & RUHSAL BİTİRİCİ',
          'archetype': 'Mars Ateşi & Jüpiter Ruhu • Bilgelik',
          'description': 'Eski bir ruhsunuz; döngülerin tamamlayıcısı ve insanlığın hizmetkarısınız. Kişisel çıkarların ötesine geçip kolektife ışık tutmak için buradasınız.',
          'strengths': 'Geniş vizyon, hümanizm, affedicilik, sezgisel bilgelik ve sanatsal derinlik.',
          'challenges': 'Geçmişe takılı kalma, aşırı dramatik tepkiler, tükenmişlik hissi.',
          'color': 'Saf Beyaz & Altın Sarısı',
          'planet': 'Mars & Jüpiter',
        };
      case 11:
        return {
          'title': '11 • ÜSTAT AYDINLATICI (MASTER NUMBER)',
          'archetype': 'Kozmik Anten • Yüksek Sezgi & Vizyoner',
          'description': 'Evrenin frekanslarını doğrudan alan mistik bir köprü görevi görürsünüz. 1\'in liderliği ile 2\'nin sezgisinin katlanmış gücüne sahip yüksek titreşimli bir ruhsunuz.',
          'strengths': 'Duru sezgi, ilahi kanallık, karizmatik rehberlik, yüksek ruhsal farkındalık.',
          'challenges': 'Aşırı sinirsel gerginlik, anksiyete, gerçeklikten kopma ve sorumluluk ağırlığı.',
          'color': 'Gümüş Işıltısı & Lavanta Moru',
          'planet': 'Uranüs & Ay',
        };
      case 22:
        return {
          'title': '22 • ÜSTAT MİMAR (MASTER BUILDER)',
          'archetype': 'Dünya İnşaatçısı • İmkansızı Somutlaştıran',
          'description': 'En güçlü numerolojik sayılardan biridir. Gökyüzündeki ilahi projeleri yeryüzünde binalara, kurumlara ve sistemlere dönüştüren muazzam bir güç potansiyelidir.',
          'strengths': 'Pratik deha, devasa organizasyon yeteneği, küresel vizyon ve yılmaz irade.',
          'challenges': 'Aşırı baskı hissi, manipülasyon tuzağı ve başarısızlık korkusu.',
          'color': 'Mercan Kırmızısı & Platin Gri',
          'planet': 'Plüton & Satürn',
        };
      case 33:
        return {
          'title': '33 • ÜSTAT ŞİFACI & KOZMİK ÖĞRETMEN',
          'archetype': 'Mesih Bilinci • Saf Şefkat & Rehberlik',
          'description': 'Kutsal sevginin ve ilahi fedakarlığın sayısıdır. İnsanlığı koşulsuz şefkatle kucaklayan, ruhsal boyutta rehberlik eden ender bir kozmik görevlidir.',
          'strengths': 'Sonsuz merhamet, ruhsal şifa gücü, ilham verici öğretmenlik ve yüksek aura.',
          'challenges': 'Kendi canını feda etme, dünyanın acısı altında ezilme, kurban rolü.',
          'color': 'Gök Mavisi & Altın Işığı',
          'planet': 'Güneş & Neptün',
        };
      default:
        return {
          'title': '$num • KOZMİK FREKANS',
          'archetype': 'Bilinmeyen Gizem',
          'description': 'Kozmik haritanızda özel bir titreşim taşımaktasınız.',
          'strengths': 'Özgünlük ve sezgi.',
          'challenges': 'Denge arayışı.',
          'color': 'Gökkuşağı',
          'planet': 'Yıldızlar',
        };
    }
  }

  static Map<String, String> _getDestinyDetails(int num) {
    return {
      'title': 'Kader Sayısı: $num',
      'meaning': 'İsminizin ses frekansı dünyada somutlaştırmanız gereken misyonu temsil eder. Bu sayı enerjisiyle kariyerinizde ve dünyevi hedeflerinizde doğal bir çekim gücü kazanırsınız.',
    };
  }

  static Map<String, String> _getSoulUrgeDetails(int num) {
    return {
      'title': 'Ruh Güdüsü Sayısı: $num',
      'meaning': 'Kimsenin görmediği en derin arzunuzu, kapalı kapılar ardında ruhunuzun neyle tatmin olduğunu fısıldar. Kalbinizin gerçek pusulasıdır.',
    };
  }

  static Map<String, String> _getPersonalityDetails(int num) {
    return {
      'title': 'Kişilik Sayısı: $num',
      'meaning': 'Dış dünyanın sizi ilk gördüğünde hissettiği auradır. Sosyal maskeniz ve insanları kendinize çeken ilk enerjiniz bu sayıyla şekillenir.',
    };
  }

  static Map<String, String> _getPersonalYearDetails(int num) {
    switch (num) {
      case 1:
        return {
          'title': '1. Yıl: Yeni Başlangıçlar & Tohum Ekme Yılı',
          'forecast': '9 yıllık yeni bir döngünün ilk yılındasınız! Geçmişi bırakıp yeni projelere, yeni ilişkilere ve cesur adımlara başlama zamanı.',
        };
      case 2:
        return {
          'title': '2. Yıl: Sabır, İşbirliği & Köklenme Yılı',
          'forecast': 'Ektiğiniz tohumlar yeraltında büyüyor. Acele etmeyin; sabır, diplomasi ve ortaklıklar yılındasınız.',
        };
      case 3:
        return {
          'title': '3. Yıl: Yaratıcılık, Sosyalleşme & Neşe Yılı',
          'forecast': 'İfade gücünüz zirvede! Sosyal çevreniz genişliyor, sanatsal projeler ve neşeli fırsatlar kapınızda.',
        };
      case 4:
        return {
          'title': '4. Yıl: Çok Çalışma, Temel Atma & Düzen Yılı',
          'forecast': 'Disiplin ve inşa yılı. Geleceğinizi garantiye alacak maddi ve fiziksel temelleri sağlamlaştırın.',
        };
      case 5:
        return {
          'title': '5. Yıl: Büyük Değişim, Seyahat & Özgürlük Yılı',
          'forecast': 'Döngünün dönüm noktası! Beklenmedik sürprizler, seyahatler, yer ve meslek değişiklikleri gündeme gelebilir.',
        };
      case 6:
        return {
          'title': '6. Yıl: Aile, Aşk, Sorumluluk & Yuva Yılı',
          'forecast': 'Evlilik, ailevi meseleler, ev kurma ve ilişkileri şifalandırma yılı. Kalbinizin yuvasına odaklanın.',
        };
      case 7:
        return {
          'title': '7. Yıl: İçsel Keşif, Dinlenme & Ruhsal Derinleşme Yılı',
          'forecast': 'Dünyevi koşturmacayı yavaşlatıp ruhunuzu dinleme zamanı. Meditasyon, araştırma ve inziva size büyük şifa getirecek.',
        };
      case 8:
        return {
          'title': '8. Yıl: Maddi Hasat, Güç & Kariyer Zirvesi Yılı',
          'forecast': 'Karmik ödül yılı! Son 7 yılda verdiğiniz emeklerin maddi karşılığını, terfilerini ve zaferlerini toplama dönemi.',
        };
      case 9:
        return {
          'title': '9. Yıl: Tamamlanma, Arınma & Helalleşme Yılı',
          'forecast': '9 yıllık döngünün sonu. Artık size hizmet etmeyen eşyaları, insanları ve alışkanlıkları geride bırakıp yeni döngüye yer açın.',
        };
      default:
        return {
          'title': 'Döngü Yılı: $num',
          'forecast': 'Kozmik yıl enerjinizle hayatınızdaki dönüşümleri karşılayın.',
        };
    }
  }
}
