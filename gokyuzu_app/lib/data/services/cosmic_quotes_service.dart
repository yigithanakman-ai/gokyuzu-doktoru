class CosmicQuoteModel {
  final int id;
  final String author;
  final String title;
  final String category; // Felsefe, Analitik Psikoloji, Tasavvuf, Bilim & Kozmoloji, Stoacılık
  final String quote;
  final String transitTheme;
  final String practicalReflection;

  const CosmicQuoteModel({
    required this.id,
    required this.author,
    required this.title,
    required this.category,
    required this.quote,
    required this.transitTheme,
    required this.practicalReflection,
  });
}

class CosmicQuotesService {
  static const List<CosmicQuoteModel> quotes = [
    CosmicQuoteModel(
      id: 1,
      author: 'Marcus Aurelius',
      title: 'Roma İmparatoru & Stoa Filozofu',
      category: 'Stoacılık',
      quote:
          'Yıldızların hareketlerini, onlarla birlikte dönüyormuş gibi izle. Elementlerin birbiri içine sürekli dönüşümünü aklında tut; bu düşünceler yeryüzü hayatının kirliliğini yıkar.',
      transitTheme: 'Kozmik Uyum & Zihinsel Dinginlik',
      practicalReflection:
          'Bugün kontrolünüz dışındaki gelişmelere öfkelenmek yerine, gökyüzünün büyük resmine odaklanın. Zorluklar geçici bir buluttur; bilinciniz ise gökyüzünün kendisidir.',
    ),
    CosmicQuoteModel(
      id: 2,
      author: 'Carl Gustav Jung',
      title: 'Analitik Psikolojinin Kurucusu',
      category: 'Psikoloji & Derin Bilinç',
      quote:
          'Bilinçdışını bilince dönüştürene kadar o senin hayatını yönlendirecek ve sen ona kader diyeceksin.',
      transitTheme: 'Gölge Yüzleşmesi & Pluto / Ay Transitleri',
      practicalReflection:
          'Bugün içinizde uyanan ani tepkileri suçlamak yerine merakla inceleyin. Korkularınızın üzerine cesaretle gittiğinizde, kader zannettiğiniz döngüleri dönüştürebilirsiniz.',
    ),
    CosmicQuoteModel(
      id: 3,
      author: 'Mevlana Celaleddin-i Rumi',
      title: 'Büyük Mutasavvıf & Şair',
      category: 'Tasavvuf & Evrensel Aşk',
      quote:
          'Dün akıllıydım, dünyayı değiştirmek istedim. Bugün bilgeyim, kendimi değiştiriyorum.',
      transitTheme: 'İçsel Simya & Merkür-Güneş Hizalanması',
      practicalReflection:
          'Başkalarını ikna etmeye veya dış koşulları zorlamaya harcadığınız enerjiyi kendi iç huzurunuza yatırın. Kendinizdeki en ufak bir farkındalık tüm dünyanızı aydınlatır.',
    ),
    CosmicQuoteModel(
      id: 4,
      author: 'Albert Einstein',
      title: 'Teorik Fizikçi & Nobel Ödülü Sahibi',
      category: 'Bilim & Kozmoloji',
      quote:
          'Hayat bisiklete binmek gibidir. Dengenizi korumak için hareket etmeye devam etmelisiniz.',
      transitTheme: 'Dinamik Denge & Mars-Satürn İlerlemesi',
      practicalReflection:
          'Bugün ertelediğiniz veya gözünüzde büyüttüğünüz adımı atın. Küçük de olsa atılan somut bir adım, zihinsel durağanlığı ve anksiyeteyi anında dağıtır.',
    ),
    CosmicQuoteModel(
      id: 5,
      author: 'Baruch Spinoza',
      title: 'Rasyonalist Düşünür',
      category: 'Felsefe',
      quote:
          'İnsanlar kendilerini özgür sanırlar; çünkü arzularının bilincindedirler ama o arzuları belirleyen nedenleri bilmezler.',
      transitTheme: 'Öz-Farkındalık & Ay Düğümleri Rehberliği',
      practicalReflection:
          'Bugün sizi tetikleyen dürtülerin kökenini araştırın. Neden istediğinizi anladığınızda, gerçek içsel özgürlüğe kavuşacaksınız.',
    ),
    CosmicQuoteModel(
      id: 6,
      author: 'Nikola Tesla',
      title: 'Mucit & Elektrik Dehası',
      category: 'Kozmik Enerji & Bilim',
      quote:
          'Evrenin gizemlerini anlamak istiyorsanız enerji, frekans ve titreşim cinsinden düşünün.',
      transitTheme: 'Uranüs & Yüksek Titreşim',
      practicalReflection:
          'Bugün tükettiğiniz gıdalara, dinlediğiniz müziklere ve konuştuğunuz insanların enerjisine dikkat edin. Kendi titreşiminizi yükseltmek günün en büyük koruyucu kalkanıdır.',
    ),
    CosmicQuoteModel(
      id: 7,
      author: 'Hermes Trismegistus',
      title: 'Kadim Hermetizmin Atası',
      category: 'Ezoterik Bilgelik',
      quote:
          'Yukarıda ne varsa aşağıda da o vardır; içeride ne varsa dışarıda da o vardır.',
      transitTheme: 'Makrokozmos - Mikrokozmos Aynası',
      practicalReflection:
          'Dış dünyada gördüğünüz karmaşa, içeride çözülmeyi bekleyen bir düğümün yansımasıdır. Kendi içinizi düzenlediğinizde dış koşullar kendiliğinden hizalanacaktır.',
    ),
    CosmicQuoteModel(
      id: 8,
      author: 'Seneca',
      title: 'Roma Filozofu & Devlet Adamı',
      category: 'Stoacılık',
      quote:
          'Kader, istekli olana rehberlik eder; direneni ise sürükler.',
      transitTheme: 'Teslimiyet & Satürn-Jüpiter Dengesi',
      practicalReflection:
          'Değiştiremeyeceğiniz gerçeklerle savaşmayı bırakın. Akışın getirdiği yeni yöne zarafetle uyum sağladığınızda kapıların ardına kadar açıldığını göreceksiniz.',
    ),
    CosmicQuoteModel(
      id: 9,
      author: 'Carl Sagan',
      title: 'Astronom & Astrofizikçi',
      category: 'Astronomi & Bilim',
      quote:
          'Bizler yıldız tozuyuz. Evren, kendisini bizim gözlerimizle tanıma fırsatı bulmuştur.',
      transitTheme: 'Kozmik Aidiyet & Güneş Bilinci',
      practicalReflection:
          'Siz bu evrene yabancı değilsiniz; yıldızların doğup battığı aynı elementlerden dokundunuz. Kendi değerinizi kozmik boyutta hatırlayın.',
    ),
    CosmicQuoteModel(
      id: 10,
      author: 'Halil Cibran',
      title: 'Lübnanlı Filozof & Şair',
      category: 'Edebiyat & Tasavvuf',
      quote:
          'Keder varlığınızda ne kadar derin bir oyuk açarsa, içine sığdırabileceğiniz sevinç o kadar çok olur.',
      transitTheme: 'Duygusal İyileşme & Chiron Şifası',
      practicalReflection:
          'Bugün geçmişte yaşadığınız acıların size kattığı empati ve bilgeliği kutsayın. Yaralarınız, ışığın içeri girdiği yerdir.',
    ),
    CosmicQuoteModel(
      id: 11,
      author: 'Alan Watts',
      title: 'Doğu Felsefesi Yorumcusu',
      category: 'Zen & Farkındalık',
      quote:
          'Bulanık bir suyu berraklaştırmanın tek yolu, onu kendi haline bırakmaktır.',
      transitTheme: 'Ay Boşlukta & Zihinsel Dinginlik',
      practicalReflection:
          'Cevapları bulmak için zihninizi aşırı zorlamayın. Sessizlikte kalın; aradığınız hakikat siz durduğunuzda yüzeye çıkacaktır.',
    ),
    CosmicQuoteModel(
      id: 12,
      author: 'Friedrich Nietzsche',
      title: 'Filozof & Düşünür',
      category: 'Felsefe',
      quote:
          'Yaşamak için bir nedeni olan insan, neredeyse her türlü nasıla katlanabilir.',
      transitTheme: 'İrade & Yaşam Amacı (Kuzey Ay Düğümü)',
      practicalReflection:
          'Nereye gittiğinizi ve ne için mücadele ettiğinizi unutmayın. Net bir vizyon, günlük yorgunlukları hafif bir rüzgara çevirir.',
    ),
  ];

  static CosmicQuoteModel getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }
}
