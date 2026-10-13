class SephiraModel {
  final int number;
  final String hebrewName;
  final String turkishName;
  final String englishName;
  final String divineName;
  final String archangel;
  final String angelicOrder;
  final String planetaryCorrespondence;
  final String pillar; // Merhamet (Sağ), Şiddet/Form (Sol), Denge/Bilinç (Orta)
  final String spiritualMeaning;
  final String psychologicalArchetype;
  final String bodyPart;
  final String spiritualLesson;
  final int colorValue;
  final double xRatio; // 0.0 (left) to 1.0 (right) for Tree diagram
  final double yRatio; // 0.0 (top) to 1.0 (bottom) for Tree diagram

  const SephiraModel({
    required this.number,
    required this.hebrewName,
    required this.turkishName,
    required this.englishName,
    required this.divineName,
    required this.archangel,
    required this.angelicOrder,
    required this.planetaryCorrespondence,
    required this.pillar,
    required this.spiritualMeaning,
    required this.psychologicalArchetype,
    required this.bodyPart,
    required this.spiritualLesson,
    required this.colorValue,
    required this.xRatio,
    required this.yRatio,
  });
}

class KabbalahPathModel {
  final int number; // 11 to 32
  final String hebrewLetter;
  final String pathName;
  final int fromSephira;
  final int toSephira;
  final String astrologicalCorrespondence;
  final String meaning;

  const KabbalahPathModel({
    required this.number,
    required this.hebrewLetter,
    required this.pathName,
    required this.fromSephira,
    required this.toSephira,
    required this.astrologicalCorrespondence,
    required this.meaning,
  });
}

class KabbalahTreeService {
  static const List<SephiraModel> sephirot = [
    SephiraModel(
      number: 1,
      hebrewName: 'כתר (Keter)',
      turkishName: 'Taç (İlk Kıvılcım)',
      englishName: 'Crown',
      divineName: 'Ehyeh Asher Ehyeh (Ben Olan Ben\'im)',
      archangel: 'Metatron (Yüzlerin Prensi)',
      angelicOrder: 'Chayot HaKodesh (Kutsal Yaşayan Varlıklar)',
      planetaryCorrespondence: 'Neptün / Primum Mobile (İlk Hareket)',
      pillar: 'Orta Sütun (Denge)',
      spiritualMeaning:
          'Yaradan\'ın tezahür etmemiş saf nuru; tüm yaratılışın tohumu ve sonsuz potansiyeli. Henüz ayrışmamış saf birlik bilinci.',
      psychologicalArchetype: 'Aşkın Benlik (Transpersonal Self), Öz Bilinç',
      bodyPart: 'Başın tepesi, auranın en üst taç noktası',
      spiritualLesson:
          'Kişisel egoyu evrensel ilahi akışa teslim etme ve saf teslimiyet.',
      colorValue: 0xFFFFFFFF,
      xRatio: 0.5,
      yRatio: 0.08,
    ),
    SephiraModel(
      number: 2,
      hebrewName: 'חכמה (Chokhmah)',
      turkishName: 'Bilgelik (Kozmik Baba)',
      englishName: 'Wisdom',
      divineName: 'Yah (Tanrısal İsim)',
      archangel: 'Raziel (Tanrı\'nın Sırları Meleği)',
      angelicOrder: 'Ophanim (Gözlü Çarklar)',
      planetaryCorrespondence: 'Uranüs / Zodyak (Kozmik Yıldız Kümesi)',
      pillar: 'Sağ Sütun (Merhamet & Genişleme)',
      spiritualMeaning:
          'İlk dinamik enerji patlaması; saf yaratıcı ilham, sınırsız ışık akışı ve erkek prensip (Aba).',
      psychologicalArchetype: 'Saf Sezgi, Deha, Spontane Yaratıcılık',
      bodyPart: 'Beynin sağ yarımküresi',
      spiritualLesson:
          'Kalıpları kırıp kozmik ilhama kanallık etmek; ilahi kıvılcımı başlatma cesareti.',
      colorValue: 0xFF90CAF9,
      xRatio: 0.8,
      yRatio: 0.20,
    ),
    SephiraModel(
      number: 3,
      hebrewName: 'בינה (Binah)',
      turkishName: 'Anlayış (Kozmik Anne)',
      englishName: 'Understanding',
      divineName: 'YHVH Elohim',
      archangel: 'Tzaphkiel (Tanrı\'nın Gözcüsü)',
      angelicOrder: 'Aralim (Kudretli Tahtlar)',
      planetaryCorrespondence: 'Satürn (Zaman, Yapı & Sınır)',
      pillar: 'Sol Sütun (Şiddet & Form)',
      spiritualMeaning:
          'Işığa kap (form) veren dişil rahim prensibi (Ima); zaman, uzay, sabır ve disiplin ile düşünceyi somutlaştırma.',
      psychologicalArchetype: 'Derin İdrak, Yapılandırma, Stratejik Zeka',
      bodyPart: 'Beynin sol yarımküresi',
      spiritualLesson:
          'Sınırların ve zamanın bilgeliğini kabul etmek; sabırla olgunlaşmak.',
      colorValue: 0xFF78909C,
      xRatio: 0.2,
      yRatio: 0.20,
    ),
    SephiraModel(
      number: 4,
      hebrewName: 'חסד (Chesed)',
      turkishName: 'Merhamet (Lütuf & Genişleme)',
      englishName: 'Mercy / Loving-kindness',
      divineName: 'El (Kudretli Olan)',
      archangel: 'Tzadkiel (Tanrı\'nın Adaleti & Şefkati)',
      angelicOrder: 'Chashmalim (Parlayan Melekler)',
      planetaryCorrespondence: 'Jüpiter (Bolluk, Fırsat & Büyüme)',
      pillar: 'Sağ Sütun (Merhamet)',
      spiritualMeaning:
          'Karşılıksız cömertlik, koşulsuz sevgi ve yaratılışı besleyen sınırsız bolluk akışı.',
      psychologicalArchetype: 'Cömert Lider, İyimserlik, Koruyucu Ruh',
      bodyPart: 'Sağ kol ve sağ omuz',
      spiritualLesson:
          'Affetmenin sınırsız gücü; yargılamadan kucaklamak ve paylaşmak.',
      colorValue: 0xFF42A5F5,
      xRatio: 0.8,
      yRatio: 0.38,
    ),
    SephiraModel(
      number: 5,
      hebrewName: 'גבורה (Gevurah)',
      turkishName: 'Kuvvet & Yargı (Kozmik Disiplin)',
      englishName: 'Severity / Strength',
      divineName: 'Elohim Gibor (Kudretli Tanrı)',
      archangel: 'Kamael (Tanrı\'yı Arayan Savaşçı)',
      angelicOrder: 'Seraphim (Ateşli Yılanlar)',
      planetaryCorrespondence: 'Mars (Cesaret, Arınma & Güç)',
      pillar: 'Sol Sütun (Şiddet / Sınır)',
      spiritualMeaning:
          'Gereksiz olanı kesip atan cerrah bıçağı; adalet, sınır çizme, kutsal öfke ve arındırıcı disiplin.',
      psychologicalArchetype: 'İçsel Savaşçı, Adalet Savaşçısı, Sınır Koyucu',
      bodyPart: 'Sol kol ve sol omuz',
      spiritualLesson:
          'Zararlı olan her şeye "hayır" diyebilmek; öz-disiplin ve cesur ayrışma.',
      colorValue: 0xFFE53935,
      xRatio: 0.2,
      yRatio: 0.38,
    ),
    SephiraModel(
      number: 6,
      hebrewName: 'תפארת (Tiferet)',
      turkishName: 'Güzellik (Kalp & Güneş Merkezi)',
      englishName: 'Beauty / Harmony',
      divineName: 'YHVH Eloah VaDaat',
      archangel: 'Raphael (Tanrı\'nın Şifası)',
      angelicOrder: 'Malakhim (Krallar / Şifa Melekleri)',
      planetaryCorrespondence: 'Güneş (Merkez, Bilinç & Hayat)',
      pillar: 'Orta Sütun (Denge)',
      spiritualMeaning:
          'Yaşam Ağacı\'nın kalbi; Merhamet (Chesed) ile Adaletin (Gevurah) mükemmel altın dengesi; Mesih bilinci ve koşulsuz sevgi güneşi.',
      psychologicalArchetype: 'Kahraman, Entegre Benlik, Şifacı Kalp',
      bodyPart: 'Göğüs kafesi, kalp ve solar pleksus merkezi',
      spiritualLesson:
          'Kendi içsel ışığıyla parlamak ve zıtlıkları sevgide uzlaştırmak.',
      colorValue: 0xFFFFD700,
      xRatio: 0.5,
      yRatio: 0.48,
    ),
    SephiraModel(
      number: 7,
      hebrewName: 'נצח (Netzach)',
      turkishName: 'Zafer & Sonsuzluk (Duygusal Tutku)',
      englishName: 'Victory / Eternity',
      divineName: 'YHVH Tzabaoth (Orduların Rabbi)',
      archangel: 'Haniel (Tanrı\'nın Zarafeti & Sevgisi)',
      angelicOrder: 'Elohim (Tanrısal Varlıklar)',
      planetaryCorrespondence: 'Venüs (Aşk, Sanat & Estetik)',
      pillar: 'Sağ Sütun (Merhamet)',
      spiritualMeaning:
          'Sanatsal ilham, doğanın üretkenliği, tutkulu duygular ve zorluklara rağmen devam eden yaşama azmi.',
      psychologicalArchetype: 'Sanatçı, Aşık, Doğa Ruhu',
      bodyPart: 'Sağ bacak ve sağ kalça',
      spiritualLesson:
          'Duyguları bastırmadan onları sanata ve aşka dönüştürme ustalığı.',
      colorValue: 0xFF66BB6A,
      xRatio: 0.8,
      yRatio: 0.65,
    ),
    SephiraModel(
      number: 8,
      hebrewName: 'הוד (Hod)',
      turkishName: 'Görkem & İhtişam (Zihinsel Berraklık)',
      englishName: 'Splendor / Glory',
      divineName: 'Elohim Tzabaoth',
      archangel: 'Michael (Tanrı Gibi Kim Var?)',
      angelicOrder: 'Beni Elohim (Işık Çocukları)',
      planetaryCorrespondence: 'Merkür (İletişim, Mantık & Büyü)',
      pillar: 'Sol Sütun (Form / Zihin)',
      spiritualMeaning:
          'Zihinsel mantık, iletişim, semboller, okült ilimler ve hakikatin kelimelere dökülmesi.',
      psychologicalArchetype: 'Filozof, Bilim İnsanı, Hermes',
      bodyPart: 'Sol bacak ve sol kalça',
      spiritualLesson:
          'Düşünceleri arındırmak; yalan ve dedikodudan uzak durup hakikati konuşmak.',
      colorValue: 0xFFFFB74D,
      xRatio: 0.2,
      yRatio: 0.65,
    ),
    SephiraModel(
      number: 9,
      hebrewName: 'יסוד (Yesod)',
      turkishName: 'Temel (Astral Matriks & Bilinçaltı)',
      englishName: 'Foundation',
      divineName: 'Shaddai El Chai (Yaşayan Yüce Tanrı)',
      archangel: 'Gabriel (Tanrı\'nın Gücü & Müjdecisi)',
      angelicOrder: 'Kerubim (Güçlü Muhafızlar)',
      planetaryCorrespondence: 'Ay (Bilinçaltı, Rüyalar & Eterik Enerji)',
      pillar: 'Orta Sütun (Denge)',
      spiritualMeaning:
          'Fiziksel dünyaya inmeden önceki astral plan; rüyalar, cinsel enerji, kolektif bilinçdışı ve anıların deposu.',
      psychologicalArchetype: 'Rüya Gören, Psişik Benlik, Anima/Animus',
      bodyPart: 'Üreme organları ve sakral merkez',
      spiritualLesson:
          'Bilinçaltı gölgeleriyle yüzleşmek ve cinsel/yaratıcı enerjiyi yüceltmek.',
      colorValue: 0xFFAB47BC,
      xRatio: 0.5,
      yRatio: 0.78,
    ),
    SephiraModel(
      number: 10,
      hebrewName: 'מלכות (Malkhut)',
      turkishName: 'Krallık (Fiziksel Realite & Beden)',
      englishName: 'Kingdom',
      divineName: 'Adonai Ha-Aretz (Yeryüzünün Rabbi)',
      archangel: 'Sandalphon (Metatron\'un İkizi & Yeryüzü Koruyucusu)',
      angelicOrder: 'Ashim (Ateş Kıvılcımları / İnsan Ruhları)',
      planetaryCorrespondence: 'Dünya / Dört Element (Toprak, Su, Hava, Ateş)',
      pillar: 'Orta Sütun (Denge)',
      spiritualMeaning:
          'Tüm yukarıdaki 9 Sefira\'nın ışığının somutlaştığı son durak; fiziksel beden, madde dünyası ve eylem sahası.',
      psychologicalArchetype: 'Somutlaştıran İnsan, Pratik Usta, Doğa Ana',
      bodyPart: 'Ayaklar ve tüm fiziksel beden kabı',
      spiritualLesson:
          'Ruhu maddede tezahür ettirmek; dünyevi hayatı kutsal bir ibadet ve tapınak gibi yaşamak.',
      colorValue: 0xFF8D6E63,
      xRatio: 0.5,
      yRatio: 0.95,
    ),
  ];

  static const List<KabbalahPathModel> paths = [
    KabbalahPathModel(
      number: 11,
      hebrewLetter: 'א (Aleph)',
      pathName: '11. Yol: Keter ➔ Chokhmah',
      fromSephira: 1,
      toSephira: 2,
      astrologicalCorrespondence: 'Hava Elementi (Kozmik Nefes)',
      meaning: 'Sonsuz potansiyelden ilk saf düşünceye geçiş; saf ilahi nefes.',
    ),
    KabbalahPathModel(
      number: 12,
      hebrewLetter: 'ב (Beth)',
      pathName: '12. Yol: Keter ➔ Binah',
      fromSephira: 1,
      toSephira: 3,
      astrologicalCorrespondence: 'Merkür (İlk Mimari Plan)',
      meaning: 'Işığa ilk yuvanın ve kabın örülmesi; düşüncenin şekillenmesi.',
    ),
    KabbalahPathModel(
      number: 13,
      hebrewLetter: 'ג (Gimel)',
      pathName: '13. Yol: Keter ➔ Tiferet',
      fromSephira: 1,
      toSephira: 6,
      astrologicalCorrespondence: 'Ay (Yüksek Rahibe Yolu)',
      meaning: 'Uçurumu (Abyss) aşan doğrudan ilahi ışık köprüsü.',
    ),
    KabbalahPathModel(
      number: 14,
      hebrewLetter: 'ד (Daleth)',
      pathName: '14. Yol: Chokhmah ➔ Binah',
      fromSephira: 2,
      toSephira: 3,
      astrologicalCorrespondence: 'Venüs (Kozmik Kapı)',
      meaning: 'Baba (Aba) ile Anne (Ima) arasındaki kutsal sevgi ve yaratılış köprüsü.',
    ),
    KabbalahPathModel(
      number: 15,
      hebrewLetter: 'ה (Heh)',
      pathName: '15. Yol: Chokhmah ➔ Tiferet',
      fromSephira: 2,
      toSephira: 6,
      astrologicalCorrespondence: 'Koç Burcu (İmparator)',
      meaning: 'Bilgeliğin doğrudan kalp merkezine akması; liderlik ateşi.',
    ),
    KabbalahPathModel(
      number: 16,
      hebrewLetter: 'ו (Vav)',
      pathName: '16. Yol: Chokhmah ➔ Chesed',
      fromSephira: 2,
      toSephira: 4,
      astrologicalCorrespondence: 'Boğa Burcu (Hierophant)',
      meaning: 'İlahi ilhamın sınırsız lütuf ve cömertliğe dönüştürülmesi.',
    ),
    KabbalahPathModel(
      number: 17,
      hebrewLetter: 'ז (Zayin)',
      pathName: '17. Yol: Binah ➔ Tiferet',
      fromSephira: 3,
      toSephira: 6,
      astrologicalCorrespondence: 'İkizler Burcu (Aşıklar)',
      meaning: 'Anlayışın sezgisel seçimlerle kalbe inmesi; zihinsel ayrım.',
    ),
    KabbalahPathModel(
      number: 18,
      hebrewLetter: 'ח (Chet)',
      pathName: '18. Yol: Binah ➔ Gevurah',
      fromSephira: 3,
      toSephira: 5,
      astrologicalCorrespondence: 'Yengeç Burcu (Savaş Arabası)',
      meaning: 'Yapının arındırıcı adalete ve kutsal sınırlara aktarılması.',
    ),
    KabbalahPathModel(
      number: 19,
      hebrewLetter: 'ט (Tet)',
      pathName: '19. Yol: Chesed ➔ Gevurah',
      fromSephira: 4,
      toSephira: 5,
      astrologicalCorrespondence: 'Aslan Burcu (Güç)',
      meaning: 'Merhamet ile Şiddetin yatay dengesi; içsel tutkuları evcilleştirme.',
    ),
    KabbalahPathModel(
      number: 20,
      hebrewLetter: 'י (Yod)',
      pathName: '20. Yol: Chesed ➔ Tiferet',
      fromSephira: 4,
      toSephira: 6,
      astrologicalCorrespondence: 'Başak Burcu (Ermiş)',
      meaning: 'Lütuf ve cömertliğin kalpte şifaya ve tevazuya dönüşmesi.',
    ),
    KabbalahPathModel(
      number: 21,
      hebrewLetter: 'כ (Kaph)',
      pathName: '21. Yol: Chesed ➔ Netzach',
      fromSephira: 4,
      toSephira: 7,
      astrologicalCorrespondence: 'Jüpiter (Kader Çarkı)',
      meaning: 'Bolluğun doğada ve duygularda sürekli bir akışa dönüşmesi.',
    ),
    KabbalahPathModel(
      number: 22,
      hebrewLetter: 'ל (Lamed)',
      pathName: '22. Yol: Gevurah ➔ Tiferet',
      fromSephira: 5,
      toSephira: 6,
      astrologicalCorrespondence: 'Terazi Burcu (Adalet)',
      meaning: 'Kuvvetin ve yargının kalpte adil bir dengeye ulaşması.',
    ),
    KabbalahPathModel(
      number: 23,
      hebrewLetter: 'מ (Mem)',
      pathName: '23. Yol: Gevurah ➔ Hod',
      fromSephira: 5,
      toSephira: 8,
      astrologicalCorrespondence: 'Su Elementi (Asılan Adam)',
      meaning: 'Kutsal disiplinin zihinde derin teslimiyete ve esnekliğe dönüşmesi.',
    ),
    KabbalahPathModel(
      number: 24,
      hebrewLetter: 'נ (Nun)',
      pathName: '24. Yol: Tiferet ➔ Netzach',
      fromSephira: 6,
      toSephira: 7,
      astrologicalCorrespondence: 'Akrep Burcu (Ölüm & Yeniden Doğuş)',
      meaning: 'Güneşin zafer ve tutkuyla buluşması; küllerinden doğuş.',
    ),
    KabbalahPathModel(
      number: 25,
      hebrewLetter: 'ס (Samekh)',
      pathName: '25. Yol: Tiferet ➔ Yesod',
      fromSephira: 6,
      toSephira: 9,
      astrologicalCorrespondence: 'Yay Burcu (Denge / Sanat)',
      meaning: 'Orta sütunda kalbin astral düzlem ve rüyalarla doğrudan köprüsü.',
    ),
    KabbalahPathModel(
      number: 26,
      hebrewLetter: 'ע (Ayin)',
      pathName: '26. Yol: Tiferet ➔ Hod',
      fromSephira: 6,
      toSephira: 8,
      astrologicalCorrespondence: 'Oğlak Burcu (Şeytan / Madde İllüzyonu)',
      meaning: 'Kalp ışığının zihindeki yanılsamaları ve korkuları aydınlatması.',
    ),
    KabbalahPathModel(
      number: 27,
      hebrewLetter: 'פ (Peh)',
      pathName: '27. Yol: Netzach ➔ Hod',
      fromSephira: 7,
      toSephira: 8,
      astrologicalCorrespondence: 'Mars (Yıkılan Kule)',
      meaning: 'Duygu ile Mantığın yatay çarpışması; egonun yanılsamalı kulesinin yıkılışı.',
    ),
    KabbalahPathModel(
      number: 28,
      hebrewLetter: 'צ (Tzaddi)',
      pathName: '28. Yol: Netzach ➔ Yesod',
      fromSephira: 7,
      toSephira: 9,
      astrologicalCorrespondence: 'Kova Burcu (Yıldız)',
      meaning: 'Doğal tutkuların ve ilhamın astral matriksle birleşmesi; umut ışığı.',
    ),
    KabbalahPathModel(
      number: 29,
      hebrewLetter: 'ק (Qoph)',
      pathName: '29. Yol: Netzach ➔ Malkhut',
      fromSephira: 7,
      toSephira: 10,
      astrologicalCorrespondence: 'Balık Burcu (Ay İllüzyonu)',
      meaning: 'Duygusal arzuların fiziksel bedende doğrudan deneyimlenmesi.',
    ),
    KabbalahPathModel(
      number: 30,
      hebrewLetter: 'ר (Resh)',
      pathName: '30. Yol: Hod ➔ Yesod',
      fromSephira: 8,
      toSephira: 9,
      astrologicalCorrespondence: 'Güneş (Güneş Kartı)',
      meaning: 'Zihinsel berraklığın bilinçaltı rüya deposunu aydınlatması.',
    ),
    KabbalahPathModel(
      number: 31,
      hebrewLetter: 'ש (Shin)',
      pathName: '31. Yol: Hod ➔ Malkhut',
      fromSephira: 8,
      toSephira: 10,
      astrologicalCorrespondence: 'Ateş Elementi (Mahkeme / Uyanış)',
      meaning: 'Zihinsel düşüncenin fiziksel dünyada somut eyleme ve uyanışa dönüşmesi.',
    ),
    KabbalahPathModel(
      number: 32,
      hebrewLetter: 'ת (Tav)',
      pathName: '32. Yol: Yesod ➔ Malkhut',
      fromSephira: 9,
      toSephira: 10,
      astrologicalCorrespondence: 'Satürn / Toprak (Dünya Kartı)',
      meaning: 'Astral şablonun madde alemine inişi; 32 yolun nihai tamamlanışı.',
    ),
  ];

  static SephiraModel getByNumber(int num) {
    return sephirot.firstWhere((s) => s.number == num, orElse: () => sephirot.first);
  }

  static SephiraModel? getByPlanet(String planet) {
    final clean = planet.trim().split(' ').first;
    for (final s in sephirot) {
      if (s.planetaryCorrespondence.contains(clean)) return s;
    }
    return null;
  }
}
