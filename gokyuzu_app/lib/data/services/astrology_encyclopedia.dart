class PlanetEncyclopediaEntry {
  final String key;
  final String name;
  final String symbol;
  final String represents;
  final String classical;
  final String karmic;
  final String mundane;
  final String medical;
  final String metal;
  final String day;
  final String archangel;
  final String positiveLight;
  final String shadowNegative;

  const PlanetEncyclopediaEntry({
    required this.key,
    required this.name,
    required this.symbol,
    required this.represents,
    required this.classical,
    required this.karmic,
    required this.mundane,
    required this.medical,
    required this.metal,
    required this.day,
    required this.archangel,
    required this.positiveLight,
    required this.shadowNegative,
  });
}

class AstrologyEncyclopedia {
  static const Map<String, PlanetEncyclopediaEntry> data = {
    'sun': PlanetEncyclopediaEntry(
      key: 'sun',
      name: 'Güneş',
      symbol: '☉',
      represents:
          'Yaşam enerjisi, bilinçli benlik, karakterin özü, irade gücü, canlılık ve bireyin kendini dünyada var etme biçimi.',
      classical:
          'Krallar, liderler, unvanlar, asalet, onur ve otorite figürleri. Aslan burcunun ve 5. evin doğal yöneticisidir.',
      karmic:
          'Ruhun bu enkarnasyondaki bilinçli kahramanlık yolculuğu; parlatılması gereken öz ışık ve kimlik inşası.',
      mundane:
          'Devlet başkanları, hükümet liderleri, ulusal prestij, milli kimlik ve egemenlik sembolleri.',
      medical:
          'Kalp, dolaşım sistemi, omurga, sırt, timüs bezi, canlılık ve gözler (erkekte sağ, kadında sol göz).',
      metal: 'Altın',
      day: 'Pazar',
      archangel: 'Başmelek Mikail (Michael)',
      positiveLight:
          'Cömertlik, asalet, yaratıcılık, adil liderlik, sarsılmaz özgüven ve ilham verici sıcaklık.',
      shadowNegative:
          'Kibir, benmerkezcilik, despotluk, küstahlık, ilgi bağımlılığı ve başkalarını gölgede bırakma arzusu.',
    ),
    'moon': PlanetEncyclopediaEntry(
      key: 'moon',
      name: 'Ay',
      symbol: '☽',
      represents:
          'Bilinçaltı, duygusal ihtiyaçlar, hafıza, içgüdüler, anne arketipi, beslenme ve aidiyet duygusu.',
      classical:
          'Kadınlar, halk, denizler, değişken durumlar, annelik ve doğurganlık. Yengeç burcunun ve 4. evin yöneticisidir.',
      karmic:
          'Geçmiş yaşamlardan getirilen duygusal hafıza, alışkanlıklar, kök karmalar ve içsel güvenlik ihtiyacı.',
      mundane:
          'Halkın psikolojisi, kamuoyu duyarlılığı, kadın nüfus, tarım, temel gıda maddeleri ve denizcilik.',
      medical:
          'Mide, sindirim sistemi, rahim, göğüsler, vücut sıvıları ve lenfatik sistem (erkekte sol, kadında sağ göz).',
      metal: 'Gümüş',
      day: 'Pazartesi',
      archangel: 'Başmelek Cebrail (Gabriel)',
      positiveLight:
          'Derin şefkat, sezgisellik, koruyuculuk, empati, duygusal zeka ve koşulsuz kabul.',
      shadowNegative:
          'Alınganlık, aşırı bağımlılık, pasif agresiflik, mağdur rolü benimseme ve geçmişe takılıp kalma.',
    ),
    'mercury': PlanetEncyclopediaEntry(
      key: 'mercury',
      name: 'Merkür',
      symbol: '☿',
      represents:
          'Zihin, mantık, analitik düşünce, iletişim, konuşma, yazı, öğrenme hızı, ticaret ve kardeşler.',
      classical:
          'Tüccarlar, hatipler, katipler, haberciler ve seyahat edenler. İkizler ve Başak burçlarının yöneticisidir.',
      karmic:
          'Zihinsel algı filtreleri, hakikati tarafsızlıkla aktarma ve karmik iletişim düğümlerini çözme görevi.',
      mundane:
          'Medya, gazetecilik, ulaşım ağları, iç ticaret, posta/kargo, eğitim sistemi ve diplomatik müzakereler.',
      medical:
          'Sinir sistemi, beyin fonksiyonları, akciğerler, kollar, eller ve konuşma/işitme organları.',
      metal: 'Cıva',
      day: 'Çarşamba',
      archangel: 'Başmelek Rafael (Raphael)',
      positiveLight:
          'Kıvrak zeka, objektiflik, merak, pratik çözüm üretme, güçlü ifade ve adaptasyon yeteneği.',
      shadowNegative:
          'Dedikodu, kurnazlık, tutarsızlık, aşırı eleştirellik, zihinsel kaygı ve huzursuzluk.',
    ),
    'venus': PlanetEncyclopediaEntry(
      key: 'venus',
      name: 'Venüs',
      symbol: '♀',
      represents:
          'Sevgi, ilişkiler, estetik, uyum, çekim gücü, değer algısı, sanat, konfor ve dünyevi hazlar.',
      classical:
          'Güzellik, evlilik, ortaklıklar, müzik, lüks ve zarafet. Boğa ve Terazi burçlarının yöneticisidir.',
      karmic:
          'İlişkilerde alma-verme dengesini kurma, öz sevgiyi keşfetme ve hak edilmiş değer karması.',
      mundane:
          'Sanat ve kültür dünyası, finans ve para piyasaları, diplomatik barış anlaşmaları ve kadın hakları.',
      medical:
          'Böbrekler, boğaz, tiroid, ses telleri, venöz kan dolaşımı, cilt ve tat alma duyusu.',
      metal: 'Bakır',
      day: 'Cuma',
      archangel: 'Başmelek Anael (Haniel)',
      positiveLight:
          'Zarafet, nezaket, uzlaşmacılık, estetik zevk, sevgi dolu yaklaşım ve barışçıl duruş.',
      shadowNegative:
          'Tembellik, yüzeysellik, aşırı konfor düşkünlüğü, bağımlı ilişkiler ve çatışmadan kaçma korkusu.',
    ),
    'mars': PlanetEncyclopediaEntry(
      key: 'mars',
      name: 'Mars',
      symbol: '♂',
      represents:
          'Arzu, eylem, mücadele gücü, tutku, cesaret, fiziksel dayanıklılık ve sınır koyma yeteneği.',
      classical:
          'Savaşçılar, liderler, cerrahlar, demirciler ve fetihler. Koç burcunun ve klasik Akrep\'in yöneticisidir.',
      karmic:
          'İrade gücünün doğru kullanımı; yıkıcı öfkeyi yapıcı cesarete dönüştürme sınavı.',
      mundane:
          'Ordu, polis teşkilatı, savunma sanayii, yangınlar, spor müsabakaları ve toplumsal gerilimler.',
      medical:
          'Baş ve yüz bölgesi, kas sistemi, kırmızı kan hücreleri, adrenal bezler ve iltihabi süreçler.',
      metal: 'Demir',
      day: 'Salı',
      archangel: 'Başmelek Kamael (Camael)',
      positiveLight:
          'Cesaret, girişimcilik, kararlılık, dürüstlük, koruyucu güç ve zorluklar karşısında pes etmeme.',
      shadowNegative:
          'Şiddet, sabırsızlık, kabalık, yakıp yıkma dürtüsü, öfke patlamaları ve körü körüne hırs.',
    ),
    'jupiter': PlanetEncyclopediaEntry(
      key: 'jupiter',
      name: 'Jüpiter',
      symbol: '♃',
      represents:
          'Bolluk, şans, bilgelik, inanç, felsefe, yüksek öğrenim, etik, adalet ve vizyoner bakış açısı.',
      classical:
          'Yargıçlar, hocalar, din bilginleri, zenginler ve koruyucu hekimler. Yay ve klasik Balık yöneticisidir.',
      karmic:
          'Geçmiş yaşamlardan gelen liyakat ödülleri; hayatın anlamına ve ilahi adalete teslimiyet.',
      mundane:
          'Hukuk sistemi, yargı organları, uluslararası ilişkiler, üniversiteler ve dış ticaret.',
      medical:
          'Karaciğer, kalça ve uyluklar, hücresel büyüme mekanizmaları ve yağ metabolizması.',
      metal: 'Kalay',
      day: 'Perşembe',
      archangel: 'Başmelek Zadkiel (Sachiel)',
      positiveLight:
          'İyimserlik, cömertlik, hoşgörü, adalet, derin vizyon ve manevi zenginlik.',
      shadowNegative:
          'Fanatizm, savurganlık, tembellik, kibirli büyüklük hezeyanı ve gerçek dışı beklentiler.',
    ),
    'saturn': PlanetEncyclopediaEntry(
      key: 'saturn',
      name: 'Satürn',
      symbol: '♄',
      represents:
          'Disiplin, zaman, sınırlar, sorumluluk, olgunluk, otorite, karma, sabır ve sağlam yapılar kurma.',
      classical:
          'Yaşlılar, çiftçiler, madenciler, engeller ve kurallar. Oğlak ve klasik Kova burcunun yöneticisidir.',
      karmic:
          'Karmanın Baş Mimarı; ruhun eksikliklerini zorunlu hayat sınavlarıyla tamamlama mekanizması.',
      mundane:
          'Devlet bürokrasisi, yasalar, yaşlı nüfus, ağır sanayi, inşaat sektörü ve daralma dönemleri.',
      medical:
          'İskelet sistemi, kemikler, dişler, eklemler, dizler, deri ve kalsiyum dengesi.',
      metal: 'Kurşun',
      day: 'Cumartesi',
      archangel: 'Başmelek Cassiel (Tzaphkiel)',
      positiveLight:
          'Sarsılmaz güvenilirlik, ustalık, sabır, adanmışlık, dayanıklılık ve somut başarılar.',
      shadowNegative:
          'Katılık, soğukluk, kötümserlik, korku odaklı yaşam, cimrilik ve değişime aşırı direnç.',
    ),
    'uranus': PlanetEncyclopediaEntry(
      key: 'uranus',
      name: 'Uranüs',
      symbol: '♅',
      represents:
          'Özgürlük, devrim, özgünlük, ani farkındalıklar, teknoloji, gelecek vizyonu ve bağımsızlık.',
      classical:
          'Mucitler, asiler, astrologlar ve kaşifler. Kova burcunun modern yöneticisidir.',
      karmic:
          'Kolektif şartlanmalardan ve kalıplardan ruhun ani bir şimşekle özgürleşmesi.',
      mundane:
          'Halk hareketleri, teknolojik icatlar, uzay araştırmaları, yapay zeka ve havacılık.',
      medical:
          'Sinir iletimi, biyoenerji akışları, kaval kemikleri, ayak bilekleri ve ani kramplar.',
      metal: 'Uranyum / Çinko',
      day: 'Çarşamba (Yüksek Oktav)',
      archangel: 'Başmelek Uriel',
      positiveLight:
          'Dahiyane sezgiler, hümanizm, yenilikçilik, özgürlük aşkı ve tabuları yıkma cesareti.',
      shadowNegative:
          'İsyankarlık, istikrarsızlık, duygusal kopukluk, anarşizm ve tahmin edilemez tepkiler.',
    ),
    'neptune': PlanetEncyclopediaEntry(
      key: 'neptune',
      name: 'Neptün',
      symbol: '♆',
      represents:
          'İlahi sevgi, sezgi, hayal gücü, sanatsal ilham, mistisizm, şifa ve sınırlar ötesi birlik.',
      classical:
          'Sanatçılar, mistikler, vizyonerler ve denizciler. Balık burcunun modern yöneticisidir.',
      karmic:
          'Ruhun ego illüzyonundan çözülüp saf sevgi kaynağına dönüşü ve manevi teslimiyet.',
      mundane:
          'Sinema, müzik, ilaç sanayii, denizler, petrol, yanılsamalar ve toplumsal idealler.',
      medical:
          'Ayaklar, epifiz bezi, bağışıklık sistemi, lenf sıvıları, alerjiler ve psikosomatik süreçler.',
      metal: 'Platin / Lityum',
      day: 'Cuma (Yüksek Oktav)',
      archangel: 'Başmelek Asariel',
      positiveLight:
          'Koşulsuz sevgi, ilham, derin empati, sezgisel şifacılık ve manevi derinlik.',
      shadowNegative:
          'İllüzyon, gerçeklerden kaçış, bağımlılıklar, kurban rolü ve sınır çizememe.',
    ),
    'pluto': PlanetEncyclopediaEntry(
      key: 'pluto',
      name: 'Plüton',
      symbol: '♇',
      represents:
          'Dönüşüm, küllerinden doğma, içsel güç, bilinçaltı derinlikleri ve köklü yenilenme.',
      classical:
          'Yeraltı zenginlikleri, dedektifler, gizli güçler. Akrep burcunun modern yöneticisidir.',
      karmic:
          'Ruhun en karanlık gölgesiyle yüzleşip onu en yüksek ışığa dönüştürme simyası.',
      mundane:
          'Yeraltı kaynakları, nükleer güç, derin devlet, finansal tekeller ve küresel krizler.',
      medical:
          'Üreme organları, boşaltım sistemi, hücresel yenilenme, DNA tamiri ve derin rejenerasyon.',
      metal: 'Plütonyum / Demir Oksit',
      day: 'Salı (Yüksek Oktav)',
      archangel: 'Başmelek Azrail (Dönüşüm Meleği)',
      positiveLight:
          'Sarsılmaz irade, karizmatik etki, derin psikolojik içgörü ve köklü şifa.',
      shadowNegative:
          'Manipülasyon, güç zehirlenmesi, takıntı, intikam duygusu ve aşırı şüphecilik.',
    ),
    'chiron': PlanetEncyclopediaEntry(
      key: 'chiron',
      name: 'Chiron (Kiron)',
      symbol: '⚷',
      represents:
          'Yaralı şifacı arketipi; kişinin en derin hassasiyetinden doğan en büyük bilgelik ve rehberlik.',
      classical:
          'Astrologlar, şifacılar, mentörler ve bilge hekimler.',
      karmic:
          'Bu hayatta kabul edilmesi gereken derin içsel kırılganlık ve başkalarına sunulacak şifa.',
      mundane:
          'Alternatif tıp, psikoterapi, holistik sağlık ve toplumsal travmaların iyileşmesi.',
      medical:
          'Kronik hassasiyetler, bağışıklık dengesi ve psikosomatik iyileşme kanalları.',
      metal: 'Titanyum / Gümüş Alaşım',
      day: 'Cumartesi / Perşembe',
      archangel: 'Başmelek Rafael (Şifa Hattı)',
      positiveLight:
          'Empatik bilgelik, derin şefkat, rehberlik yeteneği ve yaraları ışığa dönüştürme gücü.',
      shadowNegative:
          'Kendini ebediyen yaralı ve yetersiz hissetme, kurban tuzağına düşme.',
    ),
    'north_node': PlanetEncyclopediaEntry(
      key: 'north_node',
      name: 'Kuzey Ay Düğümü (KAD)',
      symbol: '☊',
      represents:
          'Ruhun bu yaşamdaki tekâmül yönü, büyüme rotası, öğrenilmesi gereken yeni hayat becerileri.',
      classical:
          'Gelişim kapısı, geleceğe açılan fırsatlar, kadersel sıçrama noktası.',
      karmic:
          'Geçmiş yaşam konfor alanından çıkıp cesaretle yürünmesi gereken asıl ruhsal hedef.',
      mundane:
          'Kolektif bilinçte geleceğe doğru atılan adımlar, yeni toplumsal normlar.',
      medical:
          'Ruhsal büyümenin bedensel canlılığa ve sağlığa yansıyan pozitif etkisi.',
      metal: 'Manyetit',
      day: 'Güneş / Ay Ekseni',
      archangel: 'Kadersel Rehberler',
      positiveLight:
          'Cesur gelişim, olgunlaşma, hayatta anlam bulma ve potansiyeli gerçekleştirmek.',
      shadowNegative:
          'Bilinmeyenden korkup eski alışkanlıklara (Güney Ay Düğümü) geri kaçmak.',
    ),
    'south_node': PlanetEncyclopediaEntry(
      key: 'south_node',
      name: 'Güney Ay Düğümü (GAD)',
      symbol: '☋',
      represents:
          'Geçmişten getirilen tanıdık yetenekler, konfor alanı ve aşırı tekrarlandığında tıkayan kalıplar.',
      classical:
          'Terk edilmesi gereken bağımlılıklar, geçmişin birikimi.',
      karmic:
          'Ruhun ustalaştığı ancak artık aşması gereken eski refleksler ve borçlar.',
      mundane:
          'Terk edilmesi gereken miadını doldurmuş toplumsal yapılar ve eski tabular.',
      medical:
          'Bedenin doğuştan taşıdığı zayıf noktalar ve enerji sızıntıları.',
      metal: 'Krom',
      day: 'Ay Ekseni',
      archangel: 'Geçmişi Arındıran Rehberler',
      positiveLight:
          'Doğuştan gelen güçlü yetenekler, içsel bilgelik ve tanıdık beceriler.',
      shadowNegative:
          'Gelişime direnmek, eski döngüleri tekrarlamak ve konfor alanında uyuşmak.',
    ),
    'ascendant': PlanetEncyclopediaEntry(
      key: 'ascendant',
      name: 'Yükselen (ASC)',
      symbol: 'Asc',
      represents:
          'Dış dünyaya yansıyan ilk izlenim, fiziksel beden, yaşam motivasyonu ve sosyal vitrin.',
      classical:
          '1. Evin başlangıç çizgisi; bireyin dünyaya merhaba dediği ufuk çizgisi.',
      karmic:
          'Ruhun dünyada bedenlenirken seçtiği avatar ve ilk algılama filtresi.',
      mundane:
          'Bir ülkenin veya kuruluşun dışarıdan nasıl göründüğü, vitrini.',
      medical:
          'Genel anayapı, baş bölgesi, canlılık ve fiziksel görünüş.',
      metal: 'Safir / Kristal',
      day: 'Doğum Günü',
      archangel: 'Beden Muhafızı',
      positiveLight:
          'Özgün duruş, güçlü ilk intiba, hayata hevesle başlama enerjisi.',
      shadowNegative:
          'Sadece maskeden ibaret kalmak, öz benliği dış görünüşe feda etmek.',
    ),
    'mc': PlanetEncyclopediaEntry(
      key: 'mc',
      name: 'Tepe Noktası (MC)',
      symbol: 'MC',
      represents:
          'Kariyer zirvesi, toplum önündeki itibar, hayatın nihai hedefi ve mesleki çağrı.',
      classical:
          '10. Evin zirvesi; kişinin gökyüzünde en tepeye ulaştığı parlak nokta.',
      karmic:
          'Dünyaya bırakılacak miras, topluma sunulacak olgunlaşmış hizmet.',
      mundane:
          'Devletin zirvesi, ulusal hedefler, lider kadrolar ve saygınlık.',
      medical:
          'Dizler, kemik taşıyıcı sistem ve toplumsal stresin bedendeki yükü.',
      metal: 'Elmas',
      day: 'Cumartesi / Güneş Hattı',
      archangel: 'Yüksek Amaç Rehberi',
      positiveLight:
          'Başarı, itibar, liderlik, toplumsal fayda ve yüksek ahlaki duruş.',
      shadowNegative:
          'Statü hırsı, soğuk kariyerizm ve sadece unvanlarla kendini değerli sayma.',
    ),
    'ic': PlanetEncyclopediaEntry(
      key: 'ic',
      name: 'Dip Noktası (IC)',
      symbol: 'IC',
      represents:
          'Kökler, aile, çocukluk temelleri, evin içi ve en mahrem içsel sığınak.',
      classical:
          '4. Evin başlangıcı; yer altı hazineleri ve köklerin toprağa bağlandığı yer.',
      karmic:
          'Ruhun atalarından getirdiği genetik ve spiritüel miras.',
      mundane:
          'Vatan toprağı, gayrimenkul, tarım, halkın en derin temelleri.',
      medical:
          'Mide, sindirim kökleri ve içsel huzurun fizyolojisi.',
      metal: 'Kalsit / Zümrüt',
      day: 'Pazartesi Hattı',
      archangel: 'Kök ve Yuva Muhafızı',
      positiveLight:
          'Derin huzur, sağlam aidiyet, atalarla barış ve sıcak bir yuva.',
      shadowNegative:
          'Geçmişe hapsolmak, aile yaralarını aşamamak ve dış dünyadan korkup içe kapanmak.',
    ),
    'descendant': PlanetEncyclopediaEntry(
      key: 'descendant',
      name: 'Alçalan (DSC)',
      symbol: 'Dsc',
      represents:
          'İkili ilişkiler, evlilik, ortaklıklar ve karşımıza ayna olarak çektiğimiz insanlar.',
      classical:
          '7. Evin başlangıcı; batı ufku ve başkalarıyla kurulan eşit bağlar.',
      karmic:
          'Kendimizde reddettiğimiz yönleri partnerimizde görüp tamamlama dersi.',
      mundane:
          'Açık düşmanlar, müttefikler, uluslararası anlaşmalar ve hukuki davalar.',
      medical:
          'Böbrekler, alt karın ve ilişkisel stresin organlara yansıması.',
      metal: 'Yeşim / Gül Kuvars',
      day: 'Cuma Hattı',
      archangel: 'Ayna ve Uyum Rehberi',
      positiveLight:
          'Sağlıklı ortaklık, derin sevgi bağı, adil diplomasi ve empati.',
      shadowNegative:
          'Kendi gücünü partnerine devretmek, bağımlı ilişkiler ve sürekli yanlış kişileri çekmek.',
    ),
  };

  static PlanetEncyclopediaEntry? getEntry(String key) {
    final clean = key.toLowerCase().replaceAll(' ', '_');
    return data[clean] ?? data[key];
  }
}

class ElementEncyclopediaEntry {
  final String element;
  final String symbol;
  final String generalNature;
  final String positiveBalanced;
  final String shadowNegative;
  final String excessCondition;
  final String deficiencyCondition;
  final String healingTips;

  const ElementEncyclopediaEntry({
    required this.element,
    required this.symbol,
    required this.generalNature,
    required this.positiveBalanced,
    required this.shadowNegative,
    required this.excessCondition,
    required this.deficiencyCondition,
    required this.healingTips,
  });
}

class ElementEncyclopedia {
  static const Map<String, ElementEncyclopediaEntry> data = {
    'Ateş': ElementEncyclopediaEntry(
      element: 'Ateş',
      symbol: '🔥',
      generalNature:
          'Ruhun itici gücü, yaşam arzusu, coşku, yaratıcılık, cesaret ve inisiyatif alma enerjisi. Benliği var eden ve harekete geçiren ilahi kıvılcım.',
      positiveBalanced:
          'Yüksek özgüven, ilham verici liderlik, cömertlik, samimiyet, tükenmeyen canlılık ve engeller karşısında korkusuzca adım atabilme.',
      shadowNegative:
          'Bencil sabırsızlık, dinlemeyi reddetme, kaba fevrilik, kibir, aşırı rekabetçilik ve her durumu güç savaşına çevirme eğilimi.',
      excessCondition:
          'Haritada Ateş Fazlalığında: Sürekli bir yangın yeri hali! Çabuk öfkelenme, tahammülsüzlük, bir işe hızla başlayıp hemen bıkma, kalp çarpıntıları, tansiyon dalgalanmaları ve enerjiyi bir anda tüketip tükenmişlik (burnout) sendromuna girme.',
      deficiencyCondition:
          'Haritada Ateş Eksikliğinde: Sabahları yataktan kalkacak motivasyonu bulmakta zorlanma, özgüven eksikliği, hayata karşı heyecan duyamama, karar alırken korkup geri çekilme ve edilgenlik.',
      healingTips:
          'Güneş ışığı almak, düzenli kardiyo/spor yapmak, acı ve ısıtıcı baharatlar tüketmek, kırmızı ve turuncu tonlar kullanmak, cesaret gerektiren küçük adımları ertelemeden atmak.',
    ),
    'Toprak': ElementEncyclopediaEntry(
      element: 'Toprak',
      symbol: '🌱',
      generalNature:
          'Maddileştirme, somutlaştırma, sabır, pratik zeka, beden farkındalığı ve dünyevi gerçeklikle kurulan sağlam kökler.',
      positiveBalanced:
          'Sarsılmaz güvenilirlik, üretkenlik, sadakat, gerçekçilik, finansal zeka, ayakları yere basma ve başladığı projeyi sabırla bitirebilme.',
      shadowNegative:
          'Kalıplaşmış inatçılık, yenilik düşmanlığı, cimrilik, aşırı maddecilik, duygusal katılıktan dolayı sevgiyi ifade edememe.',
      excessCondition:
          'Haritada Toprak Fazlalığında: Hayatı sadece görev ve paradan ibaret sanma, aşırı durağanlık, değişimden ölümüne korkma, tembellik veya aşırı işkoliklik, bedende kireçlenme ve eklem sertlikleri.',
      deficiencyCondition:
          'Haritada Toprak Eksikliğinde (0 Puan Durumu): Parayı elde tutamama, hayal ve planları bir türlü somutlaştıramama, bedensel ihtiyaçları (uyku, su, beslenme) unutma, dağınıklık ve dünyada bir türlü "köklenememe" hissi.',
      healingTips:
          'Toprağa çıplak ayakla basmak, saksı/bahçe bitkileriyle uğraşmak, düzenli bütçe tablosu tutmak, kök sebzeler tüketmek, masaj ve beden egzersizleri yapmak.',
    ),
    'Hava': ElementEncyclopediaEntry(
      element: 'Hava',
      symbol: '💨',
      generalNature:
          'Zihin, bağlantı kurma, iletişim, objektiflik, sosyallik, entelektüel merak ve kavramlar arası köprü oluşturma gücü.',
      positiveBalanced:
          'Kıvrak zeka, tarafsız bakış açısı, diplomasi, güçlü ifade yeteneği, yüksek öğrenme hızı ve insanları bir araya getirme dehası.',
      shadowNegative:
          'Duygusuzluk, yüzeysellik, dedikodu, aşırı gevezelik, verdiği sözleri unutma, zihinsel hiperaktivite ve içsel huzursuzluk.',
      excessCondition:
          'Haritada Hava Fazlalığında: Zihinde 24 saat susmayan radyo yayını! Uyku bozuklukları, aşırı analizden felç olma (analysis paralysis), duyguları hissetmek yerine zihinde mantığa büründürme ve sinir sistemi gerginliği.',
      deficiencyCondition:
          'Haritada Hava Eksikliğinde: Olaylara objektif bakamama, her şeyi kişisel algılama, kendini kelimelerle ifade etmekte zorlanma, yeni fikirlere kapalılık ve dar görüşlülük.',
      healingTips:
          'Derin nefes (pranayama) çalışmaları, günlük tutarak zihni boşaltmak, açık hava yürüyüşleri, meditasyon, nane/lavanta kokuları ve dijital detoks.',
    ),
    'Su': ElementEncyclopediaEntry(
      element: 'Su',
      symbol: '🌊',
      generalNature:
          'Ruhun derinlikleri, duygular, sezgisellik, empati, bilinçaltı hafızası, şifa ve evrensel bütünleşme ihtiyacı.',
      positiveBalanced:
          'Sonsuz şefkat, psişik radar gibi çalışan altıncı his, derin bağ kurabilme, sanatsal ilham, koşulsuz sevgi ve ruhsal dinginlik.',
      shadowNegative:
          'Aşırı alınganlık, kurban psikolojisi, duygusal manipülasyon, bağımlılıklar, gerçeklerden kaçıp kendi dram dünyasında boğulma.',
      excessCondition:
          'Haritada Su Fazlalığında: Başkalarının acısını sünger gibi emip hastalanma, mantığı tamamen devre dışı bırakıp sadece duygusal fırtınalarla karar verme, geçmişe saplanıp kalma ve melankoli.',
      deficiencyCondition:
          'Haritada Su Eksikliğinde: Empati kuramama, kendi duygularından korkup onları bastırma, başkalarının üzüntüsünü anlayamama, sertlik ve içsel kuruluk.',
      healingTips:
          'Bol su içmek, deniz/göl kenarında vakit geçirmek, ılık tuz banyoları yapmak, sanatsal/müzikal üretimle duyguları akıtmak ve net duygusal sınırlar çizmeyi öğrenmek.',
    ),
  };

  static ElementEncyclopediaEntry? getEntry(String element) {
    return data[element];
  }
}
