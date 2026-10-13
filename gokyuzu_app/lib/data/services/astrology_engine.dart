import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/birth_chart_model.dart';
import '../models/brutal_truth_model.dart';
import '../models/daily_horoscope_model.dart';
import 'world_cities_service.dart';

class AstrologyEngine {
  static const List<String> zodiacSigns = [
    'Koç',
    'Boğa',
    'İkizler',
    'Yengeç',
    'Aslan',
    'Başak',
    'Terazi',
    'Akrep',
    'Yay',
    'Oğlak',
    'Kova',
    'Balık',
  ];

  static const Map<String, String> signElements = {
    'Koç': 'Ateş',
    'Boğa': 'Toprak',
    'İkizler': 'Hava',
    'Yengeç': 'Su',
    'Aslan': 'Ateş',
    'Başak': 'Toprak',
    'Terazi': 'Hava',
    'Akrep': 'Su',
    'Yay': 'Ateş',
    'Oğlak': 'Toprak',
    'Kova': 'Hava',
    'Balık': 'Su',
  };

  static const Map<String, String> signModalities = {
    'Koç': 'Öncü',
    'Boğa': 'Sabit',
    'İkizler': 'Değişken',
    'Yengeç': 'Öncü',
    'Aslan': 'Sabit',
    'Başak': 'Değişken',
    'Terazi': 'Öncü',
    'Akrep': 'Sabit',
    'Yay': 'Değişken',
    'Oğlak': 'Öncü',
    'Kova': 'Sabit',
    'Balık': 'Değişken',
  };

  // Güneş Burcu (Tarihe Göre)
  static String calculateSunSign(DateTime date) {
    final m = date.month;
    final d = date.day;

    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'Koç';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'Boğa';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'İkizler';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'Yengeç';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'Aslan';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'Başak';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'Terazi';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'Akrep';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'Yay';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'Oğlak';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'Kova';
    return 'Balık';
  }

  // Yükselen Burç (Astronomik RAMC & Ufuk Kesişimi)
  static String calculateRisingSign(
    DateTime date,
    TimeOfDay time, {
    double lat = 40.73,
    double lon = 31.61,
    double timezoneOffset = 3.0,
  }) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final utHour = (time.hour + time.minute / 60.0) - timezoneOffset;
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5 + (utHour / 24.0);

    final t = (jd - 2451545.0) / 36525.0;
    double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t;
    gmst = gmst % 360.0;
    if (gmst < 0) gmst += 360.0;

    double ramc = (gmst + lon) % 360.0;
    if (ramc < 0) ramc += 360.0;

    final epsRad = (23.439291 - 0.0130042 * t) * math.pi / 180.0;
    final latRad = lat * math.pi / 180.0;
    final ramcRad = ramc * math.pi / 180.0;

    final yCoord = -math.cos(ramcRad);
    final xCoord = math.sin(ramcRad) * math.cos(epsRad) + math.tan(latRad) * math.sin(epsRad);

    double ascDeg = math.atan2(yCoord, xCoord) * 180.0 / math.pi;
    ascDeg = (ascDeg + 180.0) % 360.0;
    if (ascDeg < 0) ascDeg += 360.0;

    final signIdx = (ascDeg / 30.0).floor() % 12;
    return zodiacSigns[signIdx];
  }

  // Ay Burcu (Ephemeris Döngüsü)
  static String calculateMoonSign(DateTime date, TimeOfDay time) {
    final refDate = DateTime(2000, 1, 1, 12, 0);
    final diffDays = date.difference(refDate).inMinutes / (24.0 * 60.0);
    final cycle = (diffDays / 2.25) % 12.0;

    int moonIndex = (7 + cycle.floor()) % 12;
    if (moonIndex < 0) moonIndex += 12;

    return zodiacSigns[moonIndex];
  }

  // Çevrimdışı Harita Çıkarıcı
  static BirthChartModel calculateChart({
    required String name,
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String city,
    String? country,
  }) {
    final cityLoc = WorldCitiesService.findCity(city, country);
    final sun = calculateSunSign(birthDate);
    final rising = calculateRisingSign(
      birthDate,
      birthTime,
      lat: cityLoc.latitude,
      lon: cityLoc.longitude,
      timezoneOffset: cityLoc.timezoneOffset,
    );
    final moon = calculateMoonSign(birthDate, birthTime);

    final deg = (birthDate.day * 13) % 30;
    final min = (birthDate.minute * 7) % 60;

    final planetsMap = <String, PlanetPosition>{
      'sun': PlanetPosition(name: 'Güneş', sign: sun, formatted: '$deg°$min\' $sun'),
      'moon': PlanetPosition(name: 'Ay', sign: moon, formatted: '${(deg + 5) % 30}°${(min + 12) % 60}\' $moon'),
      'ascendant': PlanetPosition(name: 'Yükselen (ASC)', sign: rising, formatted: '${(deg + 9) % 30}°${(min + 20) % 60}\' $rising'),
      'mercury': PlanetPosition(name: 'Merkür', sign: sun, formatted: '$deg°$min\' $sun'),
      'venus': PlanetPosition(name: 'Venüs', sign: 'Koç', formatted: '14°42\' Koç'),
      'mars': PlanetPosition(name: 'Mars', sign: rising, formatted: '16°08\' $rising'),
      'jupiter': PlanetPosition(name: 'Jüpiter', sign: 'Aslan', formatted: '04°29\' Aslan (r)', isRetrograde: true),
      'saturn': PlanetPosition(name: 'Satürn', sign: 'Kova', formatted: '02°58\' Kova'),
      'uranus': PlanetPosition(name: 'Uranüs', sign: 'Oğlak', formatted: '13°02\' Oğlak'),
      'neptune': PlanetPosition(name: 'Neptün', sign: 'Oğlak', formatted: '16°15\' Oğlak'),
      'pluto': PlanetPosition(name: 'Plüton', sign: 'Akrep', formatted: '20°20\' Akrep (r)', isRetrograde: true),
      'chiron': PlanetPosition(name: 'Chiron', sign: 'Yengeç', formatted: '21°26\' Yengeç (r)', isRetrograde: true),
      'north_node': PlanetPosition(name: 'Kuzey Ay Düğümü', sign: 'Oğlak', formatted: '26°46\' Oğlak (r)', isRetrograde: true),
      'south_node': PlanetPosition(name: 'Güney Ay Düğümü', sign: 'Yengeç', formatted: '26°46\' Yengeç (r)', isRetrograde: true),
      'mc': PlanetPosition(name: 'Tepe Noktası (MC)', sign: 'Kova', formatted: '14°30\' Kova'),
      'ic': PlanetPosition(name: 'Dip Noktası (IC)', sign: 'Aslan', formatted: '14°30\' Aslan'),
      'descendant': PlanetPosition(name: 'Alçalan (DSC)', sign: 'Yay', formatted: '08°42\' Yay'),
    };

    final elementsCount = BirthChartModel.calculateElementScores(planetsMap);
    final modalitiesCount = BirthChartModel.calculateModalityScores(planetsMap);

    final rawChartData = {
      'sun': planetsMap['sun']!.formatted,
      'moon': planetsMap['moon']!.formatted,
      'ascendant': planetsMap['ascendant']!.formatted,
      'mercury': planetsMap['mercury']!.formatted,
      'venus': planetsMap['venus']!.formatted,
      'mars': planetsMap['mars']!.formatted,
      'jupiter': planetsMap['jupiter']!.formatted,
      'saturn': planetsMap['saturn']!.formatted,
      'uranus': planetsMap['uranus']!.formatted,
      'neptune': planetsMap['neptune']!.formatted,
      'pluto': planetsMap['pluto']!.formatted,
      'mc': planetsMap['mc']!.formatted,
      'ic': planetsMap['ic']!.formatted,
      'descendant': planetsMap['descendant']!.formatted,
    };

    return BirthChartModel(
      name: name,
      sunFormatted: planetsMap['sun']!.formatted,
      moonFormatted: planetsMap['moon']!.formatted,
      risingFormatted: planetsMap['ascendant']!.formatted,
      sunSign: sun,
      moonSign: moon,
      risingSign: rising,
      planets: planetsMap,
      elements: elementsCount,
      modalities: modalitiesCount,
      rawChart: rawChartData,
    );
  }

  // --- 3 KART: GÜNLÜK, SAMİMİ, MİZAHİ VE ANLAŞILIR DİL ---
  // --- 3 KART: GÜNLÜK, SAMİMİ, MİZAHİ VE ANLAŞILIR DİL ---
  static List<BrutalTruthModel> getBrutalTruths({
    required String name,
    required String sun,
    required String moon,
    required String ascendant,
    String? northNode,
    String gender = 'Erkek',
    String? mars,
    String? venus,
  }) {
    // Temiz burç adları
    final cleanSun = sun.split(' ').last;
    final cleanMoon = moon.split(' ').last;
    final cleanAsc = ascendant.split(' ').last;
    final cleanNorthNode = northNode != null && northNode.isNotEmpty
        ? northNode.replaceAll('(r)', '').trim().split(' ').last
        : null;

    final blindSpot = _getBlindSpot(name, cleanSun, cleanAsc);
    final relationshipIllusion = _getRelationshipIllusion(
      name: name,
      gender: gender,
      moon: cleanMoon,
      sun: cleanSun,
      mars: mars,
      venus: venus,
    );
    final soulTest = _getSoulTest(name, cleanNorthNode ?? cleanSun);

    return [
      BrutalTruthModel(id: 1, title: 'Psikolojik Kör Noktan', text: blindSpot),
      BrutalTruthModel(id: 2, title: 'İlişki Dinamikleri ve Projeksiyonların', text: relationshipIllusion),
      BrutalTruthModel(id: 3, title: 'Karmik Gelişim & Ruhun Sınavı', text: soulTest),
    ];
  }

  // 1. KART: Psikolojik Kör Noktan (Gölge Yönler & Farkındalık Alanı)
  static String _getBlindSpot(String name, String sun, String ascendant) {
    final Map<String, String> data = {
      'Koç': 'Doğum haritanızdaki Koç enerjisi; yüksek inisiyatif, cesaret ve doğrudan eyleme geçme gücü vadeder sevgili $name. Ancak bu yerleşimin psikolojik kör noktası; sabırsızlık, dinleme eşiğinin düşüklüğü ve her durumu bir mücadele veya rekabet alanı olarak algılama eğilimidir. Gerçek liderlik sadece hızla başlamak değil; sürecin olgunlaşmasına izin verecek stratejik sabrı gösterebilmektir.',
      'Boğa': 'Haritanızdaki Boğa aksı; sarsılmaz bir kararlılık, sadakat ve somut değer yaratma kabiliyeti taşır sevgili $name. Bununla birlikte gölge yönü; konfor alanına aşırı bağımlılık ve değişime karşı gösterilen katı dirençtir. Güvenlik arayışını bir savunma zırhına dönüştürmeden, hayatın sunduğu yeni olanaklara esneklikle yaklaşabilmek en büyük gelişim kapınızdır.',
      'İkizler': 'İkizler yerleşimi; kıvrak bir zeka, çok yönlü algı ve olağanüstü iletişim yeteneği sağlar sevgili $name. Ancak zihinsel hızınız, duygusal derinliğin önüne geçebilir. Rahatsız edici hislerle yüzleşmek yerine konuyu rasyonalize etme veya hızlıca yön değiştirme eğiliminiz, içsel huzursuzluk yaratabilir. Zihinsel dikkati derinleştirip dinginliği deneyimlemek gücünüzü pekiştirir.',
      'Yengeç': 'Haritanızdaki Yengeç etkisi; derin bir duygusal sezgi, koruyuculuk ve empati kapasitesi sunar sevgili $name. Bu konumun gölge tarafı ise; geçmiş deneyimlere aşırı tutunma ve kırgınlıkları içselleştirerek savunmacı bir kabuğa çekilme eğilimidir. Başkalarının sorumluluklarını üstlenip kendinizi ihmal etmek yerine, sağlıklı sınırlar koyarak öz-değerinizi korumalısınız.',
      'Aslan': 'Haritanızdaki Aslan enerjisi; doğal bir karizma, cömertlik ve üretken bir yaratıcılık barındırır sevgili $name. Psikolojik kör noktanız; dışsal onay ve takdir ihtiyacını öz-saygının önüne koyma riskidir. Görünür olamadığınızı hissettiğiniz anlarda gurur savunmalarına sığınmak yerine, değerinizin dış alkışlardan bağımsız olduğunu hatırlamak gerçek içsel gücünüzü açığa çıkarır.',
      'Başak': 'Başak yerleşimi; keskin bir muhakeme, analitik ustalık ve sistem kurma dehası kazandırır sevgili $name. Ancak bu potansiyelin kör noktası; aşırı özeleştiri, detaylarda kaybolarak büyük resmi kaçırma ve kusursuzluk arayışıyla eylemi erteleme tehlikesidir. Bütünün mükemmelliğinin küçük kusurların kabulünde yattığını görmek zihinsel yükünüzü hafifletecektir.',
      'Terazi': 'Terazi aksı; zarafet, adalet duygusu ve yüksek estetik kavrayış getirir sevgili $name. Gölge yönünüz ise; uyum ve huzuru koruma arzusuyla kendi gerçek isteklerinizi öteleme ve karar alma süreçlerinde yaşanan yıpratıcı tereddüttür. Sağlıklı çatışmaların sınırları güçlendirdiğini kabul edip net duruş sergilemek içsel dengenizi sağlar.',
      'Akrep': 'Haritanızdaki Akrep yerleşimi; olağanüstü bir psikolojik derinlik, dayanıklılık ve dönüştürücü güç taşır sevgili $name. Bununla birlikte kör noktanız; incinme korkusundan doğan savunmacı şüphecilik ve hayatı sürekli kontrol altında tutma arzusudur. Güven kapısını kontrollü bir teslimiyete açtığınızda, krizleri aşan bilgeliğiniz en büyük rehberiniz olur.',
      'Yay': 'Yay enerjisi; yüksek vizyon, yaşam coşkusu ve felsefi bir hakikat arayışı vadeder sevgili $name. Bu etkinin kör noktası; kısıtlamalara ve günlük sorumluluklara karşı tahammülsüzlük, detayları yüzeysel geçiştirme ve aşırı iyimserlikle riskleri küçümseme eğilimidir. Vizyonunuzu disiplinli bir odaklanmayla birleştirdiğinizde hedefleriniz kalıcı başarılara dönüşür.',
      'Oğlak': 'Oğlak aksı; muazzam bir sorumluluk bilinci, stratejik sabır ve zirveye ulaşma iradesi verir sevgili $name. Psikolojik kör noktanız; başarısızlık kaygısıyla duygusal ihtiyaçları bastırma ve hayatı yalnızca yerine getirilmesi gereken görevlerden ibaret görme yanılgısıdır. Kendi kırılganlığınıza şefkat göstermek ve süreci kutlamak olgunluğunuzu taçlandırır.',
      'Kova': 'Kova yerleşimi; vizyoner bir özgünlük, hümanist bir adalet anlayışı ve geleceği okuma sezgisi kazandırır sevgili $name. Ancak gölge tarafınız; duygusal bağlarda mesafeli kalma, entelektüel üstünlük zırhı ardına saklanma ve bireysel samimiyetten çekinme eğilimidir. Akıl ile kalp arasındaki köprüyü kurduğunuzda fikirleriniz gerçek bir ilhama dönüşür.',
      'Balık': 'Haritanızdaki Balık etkisi; sınırsız bir şefkat, sanatsal ilham ve evrensel bir algı derinliği sunar sevgili $name. Bu yerleşimin kör noktası; somut gerçekliklerin zorlukları karşısında hayal dünyasına kaçma ve sınır çizememekten kaynaklanan duygusal tükeniştir. Ayaklarınızı yere sağlam basarak sezgilerinizi pratik dünyaya demirlemek en büyük gücünüzdür.',
    };

    return data[ascendant] ?? data[sun] ?? 'Doğum haritanızdaki temel akslar, kendinize olan dürüstlüğünüzü korudukça en büyük rehberiniz haline gelecektir sevgili $name.';
  }

  // 2. KART: İlişkilerdeki Yanılgın (Cinsiyete Göre: Kadınlarda Mars/Güneş, Erkeklerde Venüs/Ay)
  static String _getRelationshipIllusion({
    required String name,
    required String gender,
    required String moon,
    required String sun,
    String? mars,
    String? venus,
  }) {
    final cleanMars = (mars != null && mars.isNotEmpty)
        ? mars.replaceAll('(r)', '').trim().split(' ').last
        : sun;
    final cleanVenus = (venus != null && venus.isNotEmpty)
        ? venus.replaceAll('(r)', '').trim().split(' ').last
        : moon;

    if (gender == 'Kadın') {
      return _getFemaleRelationshipIllusion(name, cleanMars, sun);
    } else if (gender == 'Hermafrodit / Diğer') {
      return _getIntersexRelationshipIllusion(name, cleanVenus, cleanMars);
    } else {
      // Erkek haritası: Venüs ve Ay üzerinden
      return _getMaleRelationshipIllusion(name, cleanVenus, moon);
    }
  }

  // Kadın Haritalarında İlişkideki Yanılgı (Mars & Güneş - İçsel Eril Projeksiyonu)
  static String _getFemaleRelationshipIllusion(String name, String mars, String sun) {
    final Map<String, String> data = {
      'Koç': 'Bir kadın haritasında Mars ve Güneş hattı, aşktaki eril çekim alanını ve yanılgılarını belirler sevgili $name. Mars Koç etkisiyle aşkta fazla iddialı, rekabetçi ve fethetmeyi seven partnerlere kapılabiliyorsun. Yanılgın ise, ilk günkü fırtına sakinleştiğinde bunu hemen sıkıcı sanıp bağdan şüphe etmek. Gerçek aşk, yangının yerini güvenli bir yol arkadaşlığına bıraktığı an başlar.',
      'Boğa': 'Sevgili $name, kadın haritanda Mars Boğa etkisi partnerinde sarsılmaz bir kale ve sonsuz sadakat aratır. Yanılgın, partnerini aşırı konfor alanına hapsetmeye çalışmak ya da değişmeyen rutinleri sevginin tek kanıtı saymak olabilir. Biraz nefes aldırıp esnek kaldığında ilişkinin çok daha bereketli aktığını göreceksin.',
      'İkizler': 'Sevgili $name, haritandaki Mars İkizler ve Güneş hattı zihinsel kıvraklığa, esprilere ve tatlı dilli erkeklere kolayca çekildiğini gösteriyor. Yanılgın ise, kelimelerine hayran olduğun kişilerin duygusal derinlik veya istikrar gösterememesi karşısında hayal kırıklığına uğramak. Sevginin sohbetle başlayıp tutarlılıkla büyüdüğünü hatırla.',
      'Yengeç': 'Sevgili $name, kadın haritanda Mars Yengeç enerjisi sana koruyucu, şefkatli bir liman aratır. Fakat yanılgın, partnerine aşık olmak yerine ona annelik yapmaya kalkmak ve karşılık alamayınca içten içe kırılıp sessizce küsmek olabilir. İhtiyaçlarını tatlı dille açıkça konuştuğunda kırgınlıklar hızla sevgiye dönüşür.',
      'Aslan': 'Sevgili $name, haritandaki Mars Aslan hattı sahnesi olan, gururlu ve karizmatik erkek profillerine çekildiğini gösterir. Yanılgın, partnerinin egosunu beslerken kendi ışığının gölgede kaldığını hissettiğinde gurur savaşına girmek olabilir. İki tarafın da eşit parladığı bir denge kurduğunda aşk senin en büyük neşen olur.',
      'Başak': 'Sevgili $name, Mars Başak yerleşimiyle partnerinin çalışkan, tertipli ve her şeyi çözen biri olmasını beklersin. Yanılgın ise, partnerini sürekli bir revizyon projesi gibi görüp eleştirmek ya da en ufak kusurda soğumak olabilir. Bırak karşındaki insan biraz kusurlu kalsın; aşk o kusurların içinde filizlenir.',
      'Terazi': 'Sevgili $name, kadın haritanda Mars Terazi etkisi seni romantik, kibar ve nazik profillere çeker. Yanılgın, sırf huzursuzluk çıkmasın ya da yalnız kalmayasın diye kendi sınırlarından taviz vermek ve pasif kalan partnerleri idare etmeye çalışmak olabilir. Net bir duruş sergilediğinde hak ettiğin değeri doğal olarak görürsün.',
      'Akrep': 'Sevgili $name, Mars Akrep yerleşimi ilişkilerde tutkulu, derin ve gizemli partnerlere çekilmene yol açar. Yanılgın ise, incinmekten öyle korkmandır ki partnerini gizli testlere tabi tutar, dedektiflik yapar ve ilişkiyi krizlerle sınarsın. Güven kapısını yavaşça araladığında aradığın o ruhani derinliği bulacaksın.',
      'Yay': 'Sevgili $name, Mars Yay hattı seni özgür, vizyoner ve eğlenceli partnerlere çeker. Yanılgın, bağlanmayı özgürlüğün sonu gibi gören ya da geleceğe dair somut adım atmayan kişilere gereğinden fazla tolerans göstermek olabilir. Ortak hedeflere doğru birlikte koşabileceğin bir partner seçtiğinde huzur bulacaksın.',
      'Oğlak': 'Sevgili $name, kadın haritanda Mars Oğlak etkisi seni güçlü, saygın, kariyer sahibi ve olgun partnerlere yöneltir. Yanılgın, aşkı bir şirket ortaklığı veya görev listesi gibi yaşayıp duyguları göstermeyi zayıflık sanmak olabilir. Gardını indirip sıcaklığını paylaştığında ilişkin gerçek bir yuvaya dönüşür.',
      'Kova': 'Sevgili $name, Mars Kova hattı seni marjinal, entelektüel ve arkadaş canlısı partnerlere çeker. Yanılgın, aşırı duygusal yakınlık anlarında buz gibi mantıkçı kalıp partnerinin sarılma ve şefkat ihtiyacını yok saymak olabilir. Kalpten kalbe bağ kurmaya izin verdiğinde aradığın gerçek yoldaşlığı bulursun.',
      'Balık': 'Sevgili $name, kadın haritanda Mars Balık etkisi seni sanatçı ruhlu, yaralı veya kurtarılmaya muhtaç partnerlere çeker. Yanılgın, kurban-kurtarıcı tuzağına düşüp sınır çizememek ve kendi ihtiyaçlarını unutmaktır. Sınırlarını koruyarak sevdiğinde gerçek bir masal yaşayabilirsin.',
    };

    return data[mars] ?? 'İlişkilerinde partnerini değil, kendi korkularını yönetmeye çalışıyorsun sevgili $name.';
  }

  // Erkek Haritalarında İlişkideki Yanılgı (Venüs & Ay - İçsel Dişil Projeksiyonu)
  static String _getMaleRelationshipIllusion(String name, String venus, String moon) {
    final Map<String, String> data = {
      'Koç': 'Bir erkek haritasında Venüs ve Ay hattı, aşkta neyi arzuladığını ve nerede yanılgıya düştüğünü belirler sevgili $name. Venüs Koç enerjisiyle ilk baştaki heyecan ve fethetme arzusunu aşk zannedebiliyorsun. İlişki sakinleşip güvenli bir rotaya girdiğinde hemen sıkıldığını düşünmek senin en büyük yanılgın. Gerçek bağ, heyecanın yerini derin bir sadakate bıraktığı yerde başlar.',
      'Boğa': 'Sevgili $name, erkek haritanda Venüs Boğa yerleşimiyle partnerini sahiplenmeyi ve ona konforlu bir dünya sunmayı seversin. Yanılgın ise, sevgiyle kontrol etmeyi karıştırmak ve karşındakinin bağımsız hareketlerine gereksiz alınmak olabilir. Güven verdikçe ve özgür bıraktıkça aşkın daha da güçlenecektir.',
      'İkizler': 'Sevgili $name, Venüs İkizler etkisiyle zeki, esprili ve konuşkan kadınlara kapılırsın. Yanılgın, derin duygusal meseleler açıldığında hemen konuyu espriye vurup yüzeyselleşmek ya da çabuk sıkılıp mesajlara geç dönmek olabilir. Biraz durup duyguların ağırlığını paylaştığında karşındakiyle sarsılmaz bir bağ kuracaksın.',
      'Yengeç': 'Sevgili $name, erkek haritanda Venüs ve Ay hattı derin bir aidiyet ve şefkat arar. Yanılgın ise, partnerine aşık olmak yerine ona annelik misyonu yüklemek ve neye kırıldığını söylemeden surat asarak karşı tarafın tahmin etmesini beklemektir. Duygularını tatlı dille açıkça konuştuğunda ilişkin rayına oturur.',
      'Aslan': 'Sevgili $name, Venüs Aslan yerleşimiyle partnerinin göz alıcı, gurur duyulacak bir kraliçe olmasını istersin. Yanılgın, ilişkide sürekli senin alkışlanmanı ve senin havanın basılmasını beklemek olabilir. Partnerine de aynı cömertlikle sahne verdiğinde aradığın gerçek aşkı bulursun.',
      'Başak': 'Sevgili $name, Venüs Başak etkisiyle partnerinin hayatını kolaylaştırmaya çalışırsın. Yanılgın ise, sevmek yerine karşındakini sürekli eğitmek, kusurlarını düzeltmeye çalışmak ve romantizmi bir denetim sürecine çevirmektir. İnsanları tatlı kusurlarıyla sevmeyi öğrendiğinde huzur bulacaksın.',
      'Terazi': 'Sevgili $name, Venüs Terazi hattı romantizm, estetik ve uyum arayışını simgeler. Yanılgın, sırf huzursuzluk çıkmasın ya da yalnız kalmayasın diye sana hiç uymayan kişilere gereğinden fazla taviz vermek olabilir. Kendi sınırlarını net çizdiğinde aşk hayatın çok daha sağlıklı dengelenir.',
      'Akrep': 'Sevgili $name, erkek haritanda Venüs Akrep yerleşimi tutkulu ve ölümüne sadık bir bağ arar. Yanılgın, incinmekten korktuğun için aşırı şüphecilik yapmak, gizli testler uygulamak ve partnerini baskıyla bunaltmaktır. Güven kapısını araladığında aradığın o derin ruh bağını bulacaksın.',
      'Yay': 'Sevgili $name, Venüs Yay etkisiyle neşeli, özgür ve maceracı kadınlara çekilirsin. Yanılgın, bağlanmayı bir pranga gibi görüp iş ciddiye bindiğinde kaçacak delik aramak olabilir. Birlikte dünyayı keşfedebileceğin bir partnerle bağlanmanın en büyük özgürlük olduğunu göreceksin.',
      'Oğlak': 'Sevgili $name, Venüs Oğlak yerleşimiyle ilişkilerde güvenilir ve sağlam bir limansın. Yanılgın ise duygularını açmayı bir zayıflık sayıp romantizmi bir iş anlaşması gibi soğuk yaşamak olabilir. Gardını indirip sıcaklığını gösterdiğinde sevginin gücünü hissedeceksin.',
      'Kova': 'Sevgili $name, Venüs Kova hattı fikir yoldaşlığı ve dostluk temelli aşkı arar. Yanılgın, duygusal anlarda aşırı mantık yapıp karşındakinin sarılma ve teselli ihtiyacını analizlerle savuşturmaktır. Mantığı bir kenara bırakıp kalpten sarıldığında aşkın çiçek açar.',
      'Balık': 'Sevgili $name, Venüs Balık yerleşimiyle sonsuz bir romantizm ve fedakarlık potansiyelin var. Yanılgın, partnerini kafandaki o kusursuz peri masalına oturtup sıradan insan hallerini görünce derin hayal kırıklığına uğramaktır. İnsanları gerçek halleriyle sevmeyi öğrendiğinde gerçek masal başlar.',
    };

    return data[venus] ?? 'İlişkilerinde partnerini değil, kendi korkularını yönetmeye çalışıyorsun sevgili $name.';
  }

  // Hermafrodit / Diğer (Eril ve Dişil Kutupsallığın Bütünleşik Dengesi)
  static String _getIntersexRelationshipIllusion(String name, String venus, String mars) {
    return 'Sevgili $name, haritanda eril (Mars $mars) ve dişil (Venüs $venus) enerjilerin benzersiz bir dengesi var. İlişkilerdeki en büyük yanılgın, kendi içindeki bu zengin kutupsallığı tek bir partnerin tek başına tamamlamasını beklemek olabilir. Dışarıdan onay aramak yerine kendi içsel ahengine güvendiğinde, ilişkilerin en saf ve dönüştürücü formuna ulaşacaktır.';
  }

  // 3. KART: Ruhunun Asıl Sınavı (Kuzey Ay Düğümü - Karakter ve Psikolojik Olgunlaşma Yolu)
  // Kesinlikle dogma, din veya ölüm konularına girmeden; psikolojik tekamül ve hayat amacı.
  static String _getSoulTest(String name, String nodeSign) {
    final Map<String, String> data = {
      'Koç': 'Kuzey Ay Düğümün Koç\'ta sevgili $name. Senin bu hayattaki en büyük sınavın: Kendi isteklerinin arkasında durabilmek ve "Önce ben" diyebilmek. Sürekli herkesi memnun etmeye, çatışma çıkmasın diye kendi hayallerinden taviz vermeye çok alışıksın. Ama senin asıl büyüme yolun, başkalarının onayını beklemeden tek başına adım atabilme cesaretini göstermekten geçiyor. Ne istediğini net söyle, korkma kimse senden uzaklaşmaz.',
      'Boğa': 'Kuzey Ay Düğümün Boğa\'da sevgili $name. Ruhunun bu hayattaki asıl sınavı: İçsel dinginliği ve basitliğin güzelliğini bulmak. Sürekli bir kriz, gizem ya da fırtına aramak yerine; hayatı sakin, güvenli ve üretken yaşamayı öğrenmelisin. Her şey bir güç savaşı olmak zorunda değil. Kendi değerini dışarıdaki onaylara değil, ürettiğin somut güzelliklere ve iç huzuruna bağladığında hayatın rayına oturacak.',
      'İkizler': 'Kuzey Ay Düğümün İkizler\'de sevgili $name. Senin bu hayattaki sınavın: Büyük nutuklar atmak yerine gerçekten dinlemeyi öğrenmek. Her şeyi zaten biliyormuş gibi davranma tuzağından çıkıp, bir meraklı öğrenci gibi yaklaşmalısın hayata. Karmaşık felsefelere dalmak yerine günlük hayatın küçük detaylarına odaklan, insanları yargılamadan dinle. Bazen en büyük bilgelik, basit bir soruda ve içten bir sohbette gizlidir.',
      'Yengeç': 'Kuzey Ay Düğümün Yengeç\'te sevgili $name. Ruhunun asıl sınavı: O taş gibi sert kabuğu indirip duygularını yaşamaya izin vermek. Hayatı sadece görevler, sorumluluklar ve başarı grafiğinden ibaret sanma alışkanlığını kırmalısın. İhtiyacın olan şey daha fazla unvan ya da başarı değil; kendine ve sevdiklerine şefkat göstermek, kırılganlığını zayıflık değil insanlık olarak görebilmektir.',
      'Aslan': 'Kuzey Ay Düğümün Aslan\'da sevgili $name. Senin bu hayattaki sınavın: Sahnenin ortasına geçip kendi özgün ışığını çekinmeden parlatmak. Kalabalıkların veya grupların arkasına saklanıp "benim için fark etmez" tavrını bir kenara bırak. Kalbinin neyle coştuğunu keşfet, yaratıcılığına güven ve içindeki çocuğu neşeyle sergile. Kendi liderliğini sahiplenmekten çekinme.',
      'Başak': 'Kuzey Ay Düğümün Başak\'ta sevgili $name. Ruhunun sınavı: Hayaller ve kurban rolünden sıyrılıp günlük hayatın pratik gerçeklerine odaklanmak. Belirsizlikler içinde kaybolup "kader kısmet" demek yerine, hayatını adım adım organize etmeyi ve somut çözümler üretmeyi öğrenmelisin. Kendi sınırlarını çizmek, bedenine iyi bakmak ve faydalı bir düzen kurmak sana en büyük huzuru getirecek.',
      'Terazi': 'Kuzey Ay Düğümün Terazi\'de sevgili $name. Bu hayattaki sınavın: "Tek başıma da yaparım" inadından çıkıp paylaşmayı ve gerçek iş birliğini öğrenmek. Sürekli bir yarış veya savunma halinde olmak yerine, karşınızdakinin penceresinden bakabilmek senin olgunlaşma anahtarın. Köprüleri yıkmak yerine diplomasi ve nezaketle bağlar kurduğunda hayatın çok daha bereketli akacak.',
      'Akrep': 'Kuzey Ay Düğümün Akrep\'te sevgili $name. Ruhunun sınavı: Konfor alanının ve maddiyatın sahte güvenliğine saplanıp kalmaktan vazgeçmek. Değişimden, dönüşümden ve derinleşmekten korkma. Bazen eskimiş şeyleri bırakmak ve kontrolü serbest bırakmak gerekir. Yüzeysel rahatlığı değil, duygusal cesareti ve içsel dönüşümü seçtiğinde gerçek gücünü keşfedeceksin.',
      'Yay': 'Kuzey Ay Düğümün Yay\'da sevgili $name. Senin bu hayattaki sınavın: Dedikodular, anlık detaylar ve bilgi kirliliği arasında boğulmaktan çıkıp büyük resmi görebilmek. Kendi hayat vizyonunu, inançlarını ve hedeflerini belirle. Sürekli "acaba hangisi" diye zihinsel kararsızlık yaşamak yerine, bir yöne inanarak cesurca yola çık.',
      'Oğlak': 'Kuzey Ay Düğümün Oğlak\'ta sevgili $name. Ruhunun bu hayattaki asıl sınavı: Duygusal sığınaklara veya alınganlıklara kaçmak yerine, kendi hayatının olgun kaptanı olmak. "Beni korusunlar, sahip çıksınlar" refleksini geride bırakıp; hedeflerini adım adım inşa eden, kendi ayakları üzerinde dimdik duran o saygın yetişkini ortaya çıkarma vaktin geldi. Disiplin, sabır ve duygusal bağımsızlık senin en parlak hazinen.',
      'Kova': 'Kuzey Ay Düğümün Kova\'da sevgili $name. Senin sınavın: Kişisel ego ve sürekli alkış alma ihtiyacını aşıp, toplumsal bir amaca veya kolektif iyiliğe katkı sağlamak. "Sadece benim dediklerim" merkezinden çıkıp, herkesle eşit ve adil dostluklar kurabilmelisin. Bireysel parlamaktan ziyade bir ekibin, insanlığın parçası olduğunu hissettiğinde gerçek doyum bulacaksın.',
      'Balık': 'Kuzey Ay Düğümün Balık\'ta sevgili $name. Ruhunun bu hayattaki sınavı: Aşırı eleştiri, kontrol takıntısı ve her şeyi mükemmel yapma kaygısını serbest bırakmak. Hayat bir kontrol tablosu değil; bazen akışa güvenmek, affetmek ve mantığın ötesindeki sezgilerine kulak vermek gerekir. Kusurları kabullenip şefkatle yaklaştığında ruhun derin bir nefes alacak.',
    };

    return data[nodeSign] ?? 'Ruhunun asıl gücü, kendi potansiyelini kabul edip cesaretle yola çıktığın gün parlayacak $name.';
  }

  // Günlük Transit Yorumu
  static DailyHoroscopeModel getDailyHoroscope({
    required String name,
    required String targetSign,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final cleanSign = targetSign.split(' ').last;
    final element = signElements[cleanSign] ?? 'Ateş';
    final formattedName = name.trim().isEmpty
        ? 'Danışan'
        : (name.startsWith('i') || name.startsWith('İ')
            ? 'İ${name.substring(1)}'
            : name.startsWith('ı') || name.startsWith('I')
                ? 'I${name.substring(1)}'
                : '${name[0].toUpperCase()}${name.substring(1)}');

    final Map<String, String> dailyInsights = {
      'Ateş':
          'Sevgili $formattedName, güncel gökyüzü transitlerinde Mars ve Güneş hattı inisiyatif alma, liderlik ve eyleme geçme iradenizi tetikliyor. Fevri tepkiler yerine enerjinizi stratejik hedeflerinize yönlendirmeniz, günün kozmik potansiyelini en yüksek verimle yönetmenizi sağlayacaktır.',
      'Toprak':
          'Sevgili $formattedName, Satürn ve Venüs etkileşimi somut hedefler, finansal planlamalar ve uzun vadeli sorumluluklar alanında güçlü bir zemin hazırlıyor. Disiplinli ve metodik adımlarınız bugün sağlam ve kalıcı sonuçlar doğuracaktır.',
      'Hava':
          'Sevgili $formattedName, Merkür ve hava elementi aksındaki akış; zihinsel odaklanma, analitik düşünce ve stratejik iletişim kapasitenizi güçlendiriyor. Fikirlerinizi net ve yapılandırılmış bir dille aktarmak yeni fırsat kapıları aralayacaktır.',
      'Su':
          'Sevgili $formattedName, Ay ve su aksı arasındaki derin ahenk; sezgisel kavrayışınızı ve psikolojik farkındalığınızı keskinleştiriyor. İç sesinize kulak vererek sınırlarınızı korumanız, günün duygusal dengesini kusursuz biçimde muhafaza etmenizi sağlayacaktır.',
    };

    final text = dailyInsights[element] ??
        'Sevgili $formattedName, güncel gezegen geçişleri içsel dengenizi korumanızı ve odaklanmış adımlar atmanızı destekliyor.';

    return DailyHoroscopeModel(
      date: dateStr,
      text: text,
    );
  }
}
