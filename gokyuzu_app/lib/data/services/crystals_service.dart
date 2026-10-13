class CrystalModel {
  final String id;
  final String name;
  final String turkishName;
  final String symbol;
  final List<String> planets;
  final List<String> zodiacSigns;
  final List<String> chakras;
  final String element;
  final String physicalBenefits;
  final String emotionalBenefits;
  final String spiritualBenefits;
  final String cleansingMethod;
  final String howToUse;
  final String affirmation;
  final int colorValue;

  const CrystalModel({
    required this.id,
    required this.name,
    required this.turkishName,
    required this.symbol,
    required this.planets,
    required this.zodiacSigns,
    required this.chakras,
    required this.element,
    required this.physicalBenefits,
    required this.emotionalBenefits,
    required this.spiritualBenefits,
    required this.cleansingMethod,
    required this.howToUse,
    required this.affirmation,
    required this.colorValue,
  });
}

class CrystalsService {
  static const List<CrystalModel> allCrystals = [
    CrystalModel(
      id: 'amethyst',
      name: 'Amethyst',
      turkishName: 'Ametist (Mor Kuvars)',
      symbol: '🔮',
      planets: ['Jüpiter', 'Neptün'],
      zodiacSigns: ['Balık', 'Kova', 'Yay'],
      chakras: ['Üçüncü Göz (Ajna)', 'Taç Çakra (Sahasrara)'],
      element: 'Hava & Su',
      physicalBenefits:
          'Migren ve baş ağrılarını hafifletir, uyku kalitesini artırır, bağışıklık ve sinir sistemini yatıştırır.',
      emotionalBenefits:
          'Zihinsel karmaşayı, öfkeyi ve anksiyeteyi dindirir. Bağımlılıklardan özgürleşmeye yardımcı olur.',
      spiritualBenefits:
          'Aura alanını negatif enerjilerden korur, sezgileri ve meditatif derinliği katlar, rüya farkındalığını artırır.',
      cleansingMethod:
          'Dolunay ışığında bekletme, adaçayı/tütsü ile dumanlama veya selenit üzerinde dinlendirme (Güneş ışığı rengini soldurabilir).',
      howToUse:
          'Gece yastık altına koyarak rüyaları hatırlamak için kullanın; meditasyon sırasında alnınıza temas ettirin.',
      affirmation: 'Zihnim berrak, sezgilerim güçlü ve ruhum derin bir huzur içinde.',
      colorValue: 0xFF9C27B0,
    ),
    CrystalModel(
      id: 'rose_quartz',
      name: 'Rose Quartz',
      turkishName: 'Pembe Kuvars (Aşk & Kalp Taşı)',
      symbol: '🌸',
      planets: ['Venüs'],
      zodiacSigns: ['Boğa', 'Terazi', 'Yengeç'],
      chakras: ['Kalp Çakra (Anahata)'],
      element: 'Toprak & Su',
      physicalBenefits:
          'Dolaşım sistemini ve kalbi destekler, ciltteki gerginliği azaltır, hücresel yenilenmeyi teşvik eder.',
      emotionalBenefits:
          'Koşulsuz sevgi, öz-şefkat ve affetme frekansını yayar. Kalp kırıklıklarını ve terk edilme korkularını onarır.',
      spiritualBenefits:
          'Kozmik sevgi frekansıyla rezonans kurar. Ruh eşi ve sağlıklı ilişki enerjilerini manyetik olarak çeker.',
      cleansingMethod:
          'Akan ılık suda 2 dakika tutma, ay ışığı veya gül tütsüsü ile arındırma.',
      howToUse:
          'Kalp hizasında kolye olarak taşıyın; yatak odasında ilişki köşesine yerleştirin.',
      affirmation: 'Kendimi ve hayatı tüm kalbimle seviyorum; sevgiyi hak ediyor ve kabul ediyorum.',
      colorValue: 0xFFF48FB1,
    ),
    CrystalModel(
      id: 'citrine',
      name: 'Citrine',
      turkishName: 'Sitrin (Tüccar & Bereket Taşı)',
      symbol: '☀️',
      planets: ['Güneş', 'Jüpiter'],
      zodiacSigns: ['Aslan', 'İkizler', 'Başak', 'Koç'],
      chakras: ['Solar Pleksus (Manipura)', 'Sakral Çakra (Svadhishthana)'],
      element: 'Ateş',
      physicalBenefits:
          'Sindirim sistemini düzenler, metabolizmayı hızlandırır, kronik yorgunluğu giderir ve canlılık verir.',
      emotionalBenefits:
          'Özgüveni ve yaşama sevincini tazeler. Fakirlik bilincini ve başarısızlık korkusunu yok eder.',
      spiritualBenefits:
          'Güneşin altın frekansını bedene indirir. Tezahür (manifestation) ve bolluk çekim gücünü maksimuma ulaştırır.',
      cleansingMethod:
          'Sitrin kendi kendini temizleyen nadir taşlardandır; sabah güneşi ışığında 1 saat şarj edilebilir.',
      howToUse:
          'Cüzdanda veya para kasasında taşıyın; çalışma masasının güneydoğu (bolluk) köşesine koyun.',
      affirmation: 'Bolluk, bereket ve neşe hayatıma her an sınırsızca akıyor.',
      colorValue: 0xFFFFB300,
    ),
    CrystalModel(
      id: 'clear_quartz',
      name: 'Clear Quartz',
      turkishName: 'Kristal Kuvars (Usta Şifacı)',
      symbol: '✨',
      planets: ['Güneş', 'Ay'],
      zodiacSigns: ['Tüm Burçlar (Özellikle Aslan & Koç)'],
      chakras: ['Tüm Çakralar (Özellikle Taç Çakra)'],
      element: 'Tüm Elementler (Eter/Ruh)',
      physicalBenefits:
          'Tüm beden enerji frekansını dengeler, bağışıklık sistemini aktive eder, fiziksel zindelik sağlar.',
      emotionalBenefits:
          'Zihinsel sisi ve dağınıklığı dağıtır, odaklanmayı artırır, duygusal netlik sağlar.',
      spiritualBenefits:
          'Programlanabilir en güçlü taştır. Niyeti bin kat büyütür, diğer taşların titreşimini yükseltir.',
      cleansingMethod:
          'Akan kaynak suyu, toprağa gömme veya dolunay ışığıyla temizlenir.',
      howToUse:
          'Niyet yükleyerek meditasyon yapın; evinizin merkezine koyarak ortam enerjisini arındırın.',
      affirmation: 'Zihnim kristal gibi berrak; evrensel rehberliğe ve saf ışığa açığım.',
      colorValue: 0xFFE0E0E0,
    ),
    CrystalModel(
      id: 'lapis_lazuli',
      name: 'Lapis Lazuli',
      turkishName: 'Lapis Lazuli (Hakikat & Bilgelik Taşı)',
      symbol: '🌌',
      planets: ['Jüpiter', 'Satürn', 'Neptün'],
      zodiacSigns: ['Yay', 'Kova', 'Boğa'],
      chakras: ['Boğaz Çakra (Vishuddha)', 'Üçüncü Göz (Ajna)'],
      element: 'Hava & Su',
      physicalBenefits:
          'Boğaz, ses telleri ve tiroid bezini dengeler. Kan basıncını düzenlemeye yardımcı olur.',
      emotionalBenefits:
          'Kişinin kendi öz hakikatini cesaretle ifade etmesini sağlar. Bastırılmış duyguları özgürleştirir.',
      spiritualBenefits:
          'Antik Mısır firavunlarının kutsal taşıdır. Astral vizyonları, basiret ve kozmik hafızayı açar.',
      cleansingMethod:
          'Suya sokulmamalıdır (kalsit içerir). Tütsü dumanı veya hematit üzerinde arındırılmalıdır.',
      howToUse:
          'Topluluk önünde konuşma yaparken veya yazarlık yaparken üzerinizde taşıyın.',
      affirmation: 'Kendi hakikatimi sevgiyle, bilgelikle ve netlikle ifade ediyorum.',
      colorValue: 0xFF1E88E5,
    ),
    CrystalModel(
      id: 'black_tourmaline',
      name: 'Black Tourmaline',
      turkishName: 'Siyah Turmalin (Aura Kalkanı)',
      symbol: '🛡️',
      planets: ['Satürn', 'Plüton'],
      zodiacSigns: ['Oğlak', 'Akrep'],
      chakras: ['Kök Çakra (Muladhara)'],
      element: 'Toprak',
      physicalBenefits:
          'Elektromanyetik radyasyonu (EMF - telefon, bilgisayar) absorbe eder, kas ağrılarını hafifletir.',
      emotionalBenefits:
          'Korku, panik ve kurban psikolojisini yok eder. Kişiye sarsılmaz bir içsel güvenlik kazandırır.',
      spiritualBenefits:
          'Nazar, psişik saldırı ve negatif varlık enerjilerine karşı aşılmaz bir koruma kalkanı oluşturur.',
      cleansingMethod:
          'Toprağa gömerek 24 saat bekletme veya kalın deniz tuzu üzerinde tutma.',
      howToUse:
          'Evin dış kapı girişine ve çalışma bilgisayarınızın yanına koyun; ceplerde taşıyın.',
      affirmation: 'Tamamen güvendeyim; tüm negatif tesirler toprağa akarak nötrleniyor.',
      colorValue: 0xFF424242,
    ),
    CrystalModel(
      id: 'labradorite',
      name: 'Labradorite',
      turkishName: 'Labradorit (Sihir & Şaman Taşı)',
      symbol: '🦚',
      planets: ['Uranüs', 'Ay', 'Neptün'],
      zodiacSigns: ['Yay', 'Akrep', 'Balık'],
      chakras: ['Üçüncü Göz', 'Taç Çakra', 'Boğaz'],
      element: 'Su & Hava',
      physicalBenefits:
          'Göz ve beyin sağlığını destekler, metabolik stresi düşürür, hormonal dengeyi kurar.',
      emotionalBenefits:
          'Bilinçaltı illüzyonlarını dağıtır. Değişim ve dönüşüm süreçlerinde cesaret ve güven verir.',
      spiritualBenefits:
          'Aura sızıntılarını mühürler. Psişik yetenekleri, eşzamanlılıkları (senkronisite) ve durugörüyü uyandırır.',
      cleansingMethod:
          'Dolunay ışığında gece boyu bekletme veya sedir ağacı tütsüsü.',
      howToUse:
          'Tarot veya astroloji analizi yaparken elinizde tutun; auranızı korumak için boynunuzda taşıyın.',
      affirmation: 'İçimdeki sonsuz potansiyele ve evrenin sihirli rehberliğine güveniyorum.',
      colorValue: 0xFF00897B,
    ),
    CrystalModel(
      id: 'carnelian',
      name: 'Carnelian',
      turkishName: 'Akik / Karnelyan (Cesaret & Tutku Taşı)',
      symbol: '🔥',
      planets: ['Mars', 'Güneş'],
      zodiacSigns: ['Koç', 'Aslan', 'Boğa'],
      chakras: ['Sakral Çakra', 'Kök Çakra'],
      element: 'Ateş',
      physicalBenefits:
          'Üreme organlarını güçlendirir, kan dolaşımını canlandırır, bel ve sırt ağrılarına iyi gelir.',
      emotionalBenefits:
          'Eylemsizliği, tembelliği ve erteleme alışkanlığını kırar. Motivasyon, tutku ve cesaret aşılar.',
      spiritualBenefits:
          'Yaşam gücü enerjisini (Kundalini/Prana) kökten yukarı doğru harekete geçirir.',
      cleansingMethod:
          'Akan su altında yıkama ve 15 dakika güneş ışığında enerji yükleme.',
      howToUse:
          'Yeni bir projeye başlarken veya spor/üretim yaparken cebinizde taşıyın.',
      affirmation: 'Tutkuyla, cesaretle ve sarsılmaz bir motivasyonla eyleme geçiyorum.',
      colorValue: 0xFFE64A19,
    ),
    CrystalModel(
      id: 'selenite',
      name: 'Selenite',
      turkishName: 'Selenit (Ay Tanrıçası Taşı)',
      symbol: '🌙',
      planets: ['Ay'],
      zodiacSigns: ['Yengeç', 'Balık', 'Boğa'],
      chakras: ['Taç Çakra', 'Ruh Yıldızı (Soul Star)'],
      element: 'Su & Hava',
      physicalBenefits:
          'Omurga hizalanmasını destekler, hücresel yapıyı yeniler, derin bir fiziksel rahatlama verir.',
      emotionalBenefits:
          'Ağır keder, geçmiş yükler ve duygusal blokajları ışık hızında çözer ve hafifletir.',
      spiritualBenefits:
          'Meleksi alemlerle bağlantı kurar. Yüksek frekanslı saf beyaz ışık kanalize eder. Diğer taşları arındırır.',
      cleansingMethod:
          'KESİNLİKLE SUYA DEĞDİRMEYİN (erir!). Sadece ay ışığı veya niyet ile arındırılır.',
      howToUse:
          'Diğer doğal taşlarınızı geceleri selenit plakanın üzerine koyarak temizleyin.',
      affirmation: 'Saf ışığın ve ilahi rehberliğin kusursuz bir kanalıyım.',
      colorValue: 0xFFECEFF1,
    ),
    CrystalModel(
      id: 'tiger_eye',
      name: 'Tiger Eye',
      turkishName: 'Kaplan Gözü (Strateji & Özgüven Taşı)',
      symbol: '🐅',
      planets: ['Güneş', 'Mars'],
      zodiacSigns: ['İkizler', 'Aslan', 'Oğlak'],
      chakras: ['Solar Pleksus', 'Kök Çakra'],
      element: 'Ateş & Toprak',
      physicalBenefits:
          'Gözleri kuvvetlendirir, kemik kırıklarının onarımını hızlandırır, sindirimi canlandırır.',
      emotionalBenefits:
          'Korkuları kararlılığa dönüştürür. Mantık ile sezgi arasında altın bir denge kurar.',
      spiritualBenefits:
          'Kişinin aurasını topraklarken aynı zamanda hedefe kilitlenmiş bir odak kalkanı örer.',
      cleansingMethod:
          'Toprakta 12 saat bekletme veya tuzlu su ile temizleme.',
      howToUse:
          'İş görüşmelerinde, müzakerelerde veya sınav anlarında sağ bilekte bileklik olarak takın.',
      affirmation: 'Güçlüyüm, odaklıyım; hedeflerime kararlılıkla ve cesaretle yürüyorum.',
      colorValue: 0xFF8D6E63,
    ),
    CrystalModel(
      id: 'malachite',
      name: 'Malachite',
      turkishName: 'Malakit (Dönüşüm & Derin Kalp Taşı)',
      symbol: '🌿',
      planets: ['Venüs'],
      zodiacSigns: ['Boğa', 'Terazi', 'Akrep', 'Oğlak'],
      chakras: ['Kalp Çakra', 'Solar Pleksus'],
      element: 'Toprak',
      physicalBenefits:
          'Kas kramplarını çözer, adet döngüsünü dengeler, toksinlerin karaciğerden atılmasına destek olur.',
      emotionalBenefits:
          'Duygusal yaraları yüzeye çıkarıp şifalandırır. Kalp etrafındaki donmuş duvarları eritir.',
      spiritualBenefits:
          'Karmik borçları ve geçmiş yaşam izlerini temizleyen en yoğun frekanslı dönüşüm taşıdır.',
      cleansingMethod:
          'Suya veya tuza değdirilmemelidir. Selenit üzerinde veya tütsü ile temizlenmelidir.',
      howToUse:
          'Duygusal bir eşikteyken göğüs kafesinin üzerine koyup derin nefes meditasyonu yapın.',
      affirmation: 'Dönüşüme teslim oluyorum; kalbimin tüm kilitleri sevgiyle açılıyor.',
      colorValue: 0xFF2E7D32,
    ),
    CrystalModel(
      id: 'aquamarine',
      name: 'Aquamarine',
      turkishName: 'Akuamarin (Deniz Suyu & İletişim Taşı)',
      symbol: '🌊',
      planets: ['Neptün', 'Ay', 'Venüs'],
      zodiacSigns: ['Balık', 'Koç', 'İkizler', 'Kova'],
      chakras: ['Boğaz Çakra'],
      element: 'Su',
      physicalBenefits:
          'Solunum yollarını, alerjileri ve boğaz enfeksiyonlarını yatıştırır. Tiroit dengesini korur.',
      emotionalBenefits:
          'Stresi, panik hissini ve gerilimi bir deniz dalgası gibi yıkar geçer. Huzur ve sükunet aşılar.',
      spiritualBenefits:
          'Eski denizcilerin koruyucu tılsımıdır. Sezgisel akışı durulaştırır ve durugörüyü berraklaştırır.',
      cleansingMethod:
          'Deniz suyunda veya kaya tuzlu suda bekletilebilir; ay ışığında şarj edilir.',
      howToUse:
          'Seyahatlerde koruma için yanınızda taşıyın; net ve etkileyici konuşmalar için boğazda kolye yapın.',
      affirmation: 'Sözlerim sevgi ve berraklıkla akıyor; hayatın akışıyla tam bir uyum içindeyim.',
      colorValue: 0xFF4DD0E1,
    ),
    CrystalModel(
      id: 'garnet',
      name: 'Garnet',
      turkishName: 'Granat / Lal Taşı (Köklenme & Hayat Kıvılcımı)',
      symbol: '🍷',
      planets: ['Mars', 'Plüton'],
      zodiacSigns: ['Akrep', 'Koç', 'Oğlak'],
      chakras: ['Kök Çakra'],
      element: 'Ateş',
      physicalBenefits:
          'Kan dolaşımını canlandırır, hemoglobin dengesini korur, cinsel enerjiyi ve libidoyu yükseltir.',
      emotionalBenefits:
          'Umutsuzluk ve çaresizlik anlarında içsel savaşçıyı uyandırır. Sadakat ve bağlılığı güçlendirir.',
      spiritualBenefits:
          'Kişiyi yeryüzünün çekirdeğine bağlar. Köklenmeyi maksimuma ulaştırarak ruhu bedene demirler.',
      cleansingMethod:
          'Toprağa gömme veya akan suda 3 dakika yıkama.',
      howToUse:
          'Yorgun ve tükenmiş hissettiğinizde sol cepte veya kök çakrada taşıyın.',
      affirmation: 'Toprağa köklüyüm; içimdeki yaşam ateşi güçlü ve sönmez bir ışıkla parlıyor.',
      colorValue: 0xFF880E4F,
    ),
    CrystalModel(
      id: 'fluorite',
      name: 'Fluorite',
      turkishName: 'Florit (Zihinsel Düzen & Deha Taşı)',
      symbol: '🔷',
      planets: ['Merkür', 'Uranüs'],
      zodiacSigns: ['İkizler', 'Başak', 'Balık'],
      chakras: ['Üçüncü Göz', 'Taç Çakra'],
      element: 'Hava',
      physicalBenefits:
          'Elektromanyetik kirliliği temizler, diş ve kemik yapısını destekler, sinirsel gerginliği azaltır.',
      emotionalBenefits:
          'Zihinsel dağınıklığı, unutkanlığı ve ders/çalışma isteksizliğini ortadan kaldırır.',
      spiritualBenefits:
          'Auranın geometrik kalıplarını yeniden hizalar. Ruhsal kanallığı yüksek zihinle entegre eder.',
      cleansingMethod:
          'Haftada bir tütsü ile temizlenmeli; doğrudan güneş ışığından korunmalıdır.',
      howToUse:
          'Çalışma masasında kitapların veya monitörün yanına koyarak yüksek konsantrasyon sağlayın.',
      affirmation: 'Zihnim mükemmel bir düzen ve berraklık içinde; kolayca odaklanıyor ve öğreniyorum.',
      colorValue: 0xFF00ACC1,
    ),
    CrystalModel(
      id: 'pyrite',
      name: 'Pyrite',
      turkishName: 'Pirit (Altın Aynası & Zenginlik Taşı)',
      symbol: '🪙',
      planets: ['Güneş', 'Mars'],
      zodiacSigns: ['Aslan'],
      chakras: ['Solar Pleksus'],
      element: 'Toprak & Ateş',
      physicalBenefits:
          'Akciğerleri güçlendirir, oksijen dolaşımını artırır, bağışıklığı çevresel toksinlerden korur.',
      emotionalBenefits:
          'Manipülasyonlara ve enerji vampirlerine karşı direnç kazandırır. Liderlik vizyonunu keskinleştirir.',
      spiritualBenefits:
          'Maddi dünyada somut başarı, finansal zenginlik ve bolluk kapılarını aralayan altın frekans taşır.',
      cleansingMethod:
          'KESİNLİKLE SUYA DEĞDİRMEYİN (paslanır). Adaçayı tütsüsü veya pirinç taneleri içinde bekletin.',
      howToUse:
          'İş yerinizde kasa veya finans defterlerinin üzerine yerleştirin.',
      affirmation: 'Başarıyı ve maddi bereketi kendime zahmetsizce çekiyorum.',
      colorValue: 0xFFFFD54F,
    ),
    CrystalModel(
      id: 'moonstone',
      name: 'Moonstone',
      turkishName: 'Ay Taşı (Dişil Enerji & Sezgi Taşı)',
      symbol: '🌕',
      planets: ['Ay'],
      zodiacSigns: ['Yengeç', 'Terazi', 'Akrep', 'Balık'],
      chakras: ['Sakral Çakra', 'Taç Çakra'],
      element: 'Su',
      physicalBenefits:
          'Hormonal döngüleri, doğurganlığı ve lenfatik sistemi dengeler. Sıvı tutulumunu azaltır.',
      emotionalBenefits:
          'Duygusal dalgalanmaları sakinleştirir, empatiyi artırır, aşırı tepkiselliği yumuşatır.',
      spiritualBenefits:
          'Kutsal dişil bilgeliği ve üçüncü göz vizyonlarını aktive eder. Yeni ay ve dolunay ritüellerinin tacıdır.',
      cleansingMethod:
          'Dolunay gecesinde açık havada ay ışığında bekletilerek şarj edilmelidir.',
      howToUse:
          'Yatarken yastık altına koyun; yeni ayda yeni niyetlerinizi taşa fısıldayın.',
      affirmation: 'İçimdeki kutsal dişil gücü kucaklıyor ve döngülerimin bilgeliğine güveniyorum.',
      colorValue: 0xFFCFD8DC,
    ),
  ];

  static List<CrystalModel> getBySign(String sign) {
    final clean = sign.replaceAll('(r)', '').trim().split(' ').last;
    return allCrystals.where((c) {
      return c.zodiacSigns.any((s) => s.contains(clean) || s.contains('Tüm Burçlar'));
    }).toList();
  }

  static List<CrystalModel> getByPlanet(String planet) {
    final clean = planet.trim().split(' ').first;
    return allCrystals.where((c) => c.planets.contains(clean)).toList();
  }

  static List<CrystalModel> getBirthStones({
    required String sunSign,
    required String ascendantSign,
    required String moonSign,
  }) {
    final Set<String> ids = {};
    final List<CrystalModel> result = [];

    void addMatching(String sign) {
      final list = getBySign(sign);
      for (final c in list) {
        if (!ids.contains(c.id)) {
          ids.add(c.id);
          result.add(c);
        }
      }
    }

    addMatching(sunSign);
    addMatching(ascendantSign);
    addMatching(moonSign);

    return result.isEmpty ? allCrystals.take(5).toList() : result;
  }
}
