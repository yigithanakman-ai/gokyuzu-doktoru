import 'sky_transits_service.dart';

class LunarMansionInfo {
  final int number; // 1 - 28
  final String name; // Türkçe / Yaygın isim
  final String arabicName; // Arapça / Kadim isim
  final String signRange; // Burç derecesi aralığı (örn: 04° 17' dk Balık – 17° 08' dk Balık)
  final double startAbsoluteDegree;
  final double endAbsoluteDegree;
  final String nature; // Uğurlu (Sa'd), Nötr, Dikkat/Zorlu (Nahs)
  final String element; // Ateş, Toprak, Hava, Su
  final String description; // Ay Menzili Genel Anlamı
  final String favorableFor; // Bu menzilde ne yapılmalı?
  final String avoidFor; // Bu menzilde nelerden sakınılmalı?
  final String hermeticTalisman; // Kadim Hermetik Tılsım/Sembol enerjisi
  final String hermeticStepTitle; // Ayrı Hermetik Adım Başlığı
  final String hermeticIncense; // Hermetik Buhur / Frekans Elementi
  final String hermeticPractice; // Hermetik Uygulama Adımı

  const LunarMansionInfo({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.signRange,
    required this.startAbsoluteDegree,
    required this.endAbsoluteDegree,
    required this.nature,
    required this.element,
    required this.description,
    required this.favorableFor,
    required this.avoidFor,
    required this.hermeticTalisman,
    this.hermeticStepTitle = 'Hermetik İrade & Rezonans Adımı',
    this.hermeticIncense = 'Günlük, Sandal Ağacı & Saf Su',
    this.hermeticPractice = 'Niyetinizi zihinsel berraklıkla odaklayın ve göksel akışla uyumlanın.',
  });
}

class MoonMansionTransitionEvent {
  final int oldMansionNumber;
  final String oldMansionName;
  final int newMansionNumber;
  final String newMansionName;
  final String arabicName;
  final String nature;
  final String signRange;
  final String favorableFor;
  final String avoidFor;
  final DateTime eventTime;
  final String title;
  final String body;

  const MoonMansionTransitionEvent({
    required this.oldMansionNumber,
    required this.oldMansionName,
    required this.newMansionNumber,
    required this.newMansionName,
    required this.arabicName,
    required this.nature,
    required this.signRange,
    required this.favorableFor,
    required this.avoidFor,
    required this.eventTime,
    required this.title,
    required this.body,
  });
}

class LunarMansionsService {
  static const double mansionSpan = 360.0 / 28.0; // 12° 51' 26" (Her burç 00° 00' dk ile 29° 59' dk arasındadır)

  /// Astronomik Presesyon Kalibrasyonlu 28 Ay Menzili (Menazilü'l-Kamer)
  /// Not: Burçlar 00° 00' dk ile 29° 59' dk arasında (30 tam derece) yer alır.
  /// 11° Balık burcu = 25. Menzil: Sa'd el-Ahbiye (Saadülahbiye) [04° 17' dk Balık – 17° 08' dk Balık].
  static const List<LunarMansionInfo> mansions = [
    LunarMansionInfo(
      number: 27,
      name: 'El-Ferğ el-Muahhar (Arka Kova)',
      arabicName: 'Al-Fargh al-Thani (الفرغ المؤخر)',
      signRange: '00° 00\' dk Koç – 12° 51\' dk Koç',
      startAbsoluteDegree: 0.0,
      endAbsoluteDegree: 12.857,
      nature: 'Orta / Manevi Akış',
      element: 'Su',
      description: 'Koç burcunun ilk derecelerinde ruhsal sezgiyi öncü eylemle birleştiren durak. Hayal gücünü somut başlangıçlara taşır.',
      favorableFor: 'Rüya analizi, manevi niyetler, sanatsal üretim ve yeni vizyon tohumları ekmek.',
      avoidFor: 'Aşırı borçlanma, fevri öfke ve gerçeklerden kopuk kararlar.',
      hermeticTalisman: 'Sanatsal deha, ilham kapısı ve yüksek sezgi bilinci.',
      hermeticStepTitle: '27. Hermetik Adım: İlhamın Mühürlenmesi',
      hermeticIncense: 'Mür, Lavanta & Deniz Tuzu',
      hermeticPractice: 'Sabah ilk saatlerde niyetinizi kağıda yazıp su elementiyle (sessiz tefekkürle) zihninizi berraklaştırın.',
    ),
    LunarMansionInfo(
      number: 28,
      name: 'El-Rişa (Balığın İpi / Göbek Bağı)',
      arabicName: 'Al-Risha (الرشاء)',
      signRange: '12° 51\' dk Koç – 25° 42\' dk Koç',
      startAbsoluteDegree: 12.857,
      endAbsoluteDegree: 25.714,
      nature: 'Uğurlu / Tamamlayıcı',
      element: 'Su',
      description: 'Alrisha yıldızının bulunduğu düğüm noktası. Döngülerin tamamlanması, barış, kavuşma ve yeniye hazırlık durağıdır.',
      favorableFor: 'Küslerin barışması, evlilik, ticaret anlaşmaları ve arınma ritüelleri.',
      avoidFor: 'Zararlı alışkanlıklara geri dönmek ve aceleci yıkımlar.',
      hermeticTalisman: 'Tamamlanma, içsel barış ve hayırlı netice.',
      hermeticStepTitle: '28. Hermetik Adım: Düğümün Çözülüşü & Birlik',
      hermeticIncense: 'Beyaz Adaçayı & Gül Reçinesi',
      hermeticPractice: 'Yarım kalan işleri tamamlayın, kırgınlıkları zihinsel olarak serbest bırakıp yeni döngüye alan açın.',
    ),
    LunarMansionInfo(
      number: 1,
      name: 'El-Şaratan (Boynuzlar)',
      arabicName: 'Al-Sharatain (الشرطان)',
      signRange: '25° 43\' dk Koç – 08° 34\' dk Boğa',
      startAbsoluteDegree: 25.714,
      endAbsoluteDegree: 38.571,
      nature: 'Zorlu / Ateşli',
      element: 'Ateş',
      description: 'Sheratan ve Mesarthim yıldızlarının durağı. Cesaret, hızlı hamleler ve ani başlangıçların enerjisini taşır.',
      favorableFor: 'Fiziksel güç gerektiren işler, cesaretle adım atma, mücadele ve sınır koruma.',
      avoidFor: 'Evlilik, uzun vadeli ortaklıklar ve fevri borçlanmalar.',
      hermeticTalisman: 'Cesaret, zafer ve engelleri aşma iradesi.',
      hermeticStepTitle: '1. Hermetik Adım: İlk Kıvılcım & İrade',
      hermeticIncense: 'Kırmızı Sandal, Tarçın & Karanfil',
      hermeticPractice: 'Ertelediğiniz en zorlu işe bugün ilk somut adımı atarak ataleti kırın.',
    ),
    LunarMansionInfo(
      number: 2,
      name: 'El-Butayn (Karın)',
      arabicName: 'Al-Butain (البطين)',
      signRange: '08° 34\' dk Boğa – 21° 25\' dk Boğa',
      startAbsoluteDegree: 38.571,
      endAbsoluteDegree: 51.428,
      nature: 'Uğurlu / Bereketli',
      element: 'Toprak',
      description: 'Boğa burcunun kalbinde gizli tohumların filizlendiği duraktır. Sabırla ekilen şeylerin kök salmasını sağlar.',
      favorableFor: 'Tohum ekme, gayrimenkul alımı, kaynak arayışı ve maddi birikim.',
      avoidFor: 'Aceleci spekülasyonlar ve gereksiz inatlaşmalar.',
      hermeticTalisman: 'Zenginleşme, bereket ve gizli kaynakların açığa çıkması.',
      hermeticStepTitle: '2. Hermetik Adım: Toprağa Kök Salma',
      hermeticIncense: 'Paçuli, Sedir Ağacı & Vetiver',
      hermeticPractice: 'Finansal ve bedensel kaynaklarınızı dengeleyin; toprağa temas ederek enerjinizi merkezleyin.',
    ),
    LunarMansionInfo(
      number: 3,
      name: 'El-Süreyya (Ülker / Pleiades)',
      arabicName: 'Al-Thurayya (الثريا)',
      signRange: '21° 26\' dk Boğa – 04° 17\' dk İkizler',
      startAbsoluteDegree: 51.428,
      endAbsoluteDegree: 64.285,
      nature: 'Çok Uğurlu / Işıltılı',
      element: 'Hava',
      description: 'Ülker (Pleiades) yıldız kümesinin (29° Boğa – 00° İkizler) mücevher durağı. Aşk, sanat, bilgelik ve derin çekim gücü verir.',
      favorableFor: 'Sanat, müzik, aşk, güzellik bakımları, ticaret ve simya/bilim çalışmaları.',
      avoidFor: 'Deniz yolculukları ve intikam içeren düşünceler.',
      hermeticTalisman: 'Sevgi celbi, şöhret, estetik cazibe ve bolluk.',
      hermeticStepTitle: '3. Hermetik Adım: Yedi Kız Kardeşin Işığı',
      hermeticIncense: 'Amber, Yasemin & Damla Sakızı',
      hermeticPractice: 'Sanatsal veya entelektüel bir esere odaklanın; kalp ve zihin uyumunu güçlendiren nefes egzersizi yapın.',
    ),
    LunarMansionInfo(
      number: 4,
      name: 'El-Deberan (Aldebaran)',
      arabicName: 'Al-Dabaran (الدبران)',
      signRange: '04° 17\' dk İkizler – 17° 08\' dk İkizler',
      startAbsoluteDegree: 64.285,
      endAbsoluteDegree: 77.142,
      nature: 'Sert / Hükmedici',
      element: 'Toprak',
      description: 'Doğu\'nun Kraliyet Yıldızı Aldebaran\'ın (09° 47\' dk İkizler) durağı. Güçlü irade, dürüstlük ve sarsılmaz kararlılık barındırır.',
      favorableFor: 'Liderlik kararları, stratejik planlama, inşaat temeli atma ve hakikati savunma.',
      avoidFor: 'Evlilik, duygusal uzlaşmalar ve doğruluktan sapmak.',
      hermeticTalisman: 'Kudret, dürüstlükle gelen zafer ve yüksek irade.',
      hermeticStepTitle: '4. Hermetik Adım: Kraliyet Yıldızı Dürüstlük Sınavı',
      hermeticIncense: 'Günlük (Frankincense) & Çam Reçinesi',
      hermeticPractice: 'Aldebaran dürüstlük şartıyla başarı verir; bugün tüm söz ve anlaşmalarınızda mutlak şeffaflık ilkesini uygulayın.',
    ),
    LunarMansionInfo(
      number: 5,
      name: 'El-Heka (Avcının Başı)',
      arabicName: 'Al-Haq\'ah (الهقعة)',
      signRange: '17° 09\' dk İkizler – 29° 59\' dk İkizler',
      startAbsoluteDegree: 77.142,
      endAbsoluteDegree: 90.0,
      nature: 'Uğurlu / Zihinsel',
      element: 'Hava',
      description: 'Orion takımyıldızının tacı (Meissa). Zihinsel uyanış, öğrenme ve ruhsal rehberlik durağıdır.',
      favorableFor: 'Eğitim, okuma, ezoterik ilimler, antlaşmalar ve usta-çırak çalışmaları.',
      avoidFor: 'Bedenen aşırı yorulma ve borç kefaleti.',
      hermeticTalisman: 'Zihin açıklığı, ilham ve sezgisel kavrayış.',
      hermeticStepTitle: '5. Hermetik Adım: Zihinsel Berraklık & Hikmet',
      hermeticIncense: 'Biberiye, Nane & Defne Yaprağı',
      hermeticPractice: 'Yeni bir ilim veya teknik konu üzerinde derin okuma yapın ve öğrendiklerinizi not alın.',
    ),
    LunarMansionInfo(
      number: 6,
      name: 'El-Hana (Damga / Çapraz)',
      arabicName: 'Al-Han\'ah (الهنعة)',
      signRange: '00° 00\' dk Yengeç – 12° 51\' dk Yengeç',
      startAbsoluteDegree: 90.0,
      endAbsoluteDegree: 102.857,
      nature: 'Uğurlu / Sosyal',
      element: 'Su',
      description: 'Alhena yıldızının durağı. İletişim, dostluk, ittifaklar ve sevgi bağlarını güçlendirir.',
      favorableFor: 'Ortaklık kurma, dostlukları pekiştirme, aile buluşmaları ve ticaret anlaşmaları.',
      avoidFor: 'Miras davaları ve hukuki restleşmeler.',
      hermeticTalisman: 'Uzlaşma, dostluk ve sevgide devamlılık.',
      hermeticStepTitle: '6. Hermetik Adım: Gönül Köprülerinin İnşası',
      hermeticIncense: 'Gül, Vanilya & Melisa',
      hermeticPractice: 'Değer verdiğiniz kişilerle samimi iletişim kurun; empati ve uzlaşı enerjisini aktive edin.',
    ),
    LunarMansionInfo(
      number: 7,
      name: 'El-Zira (Aslanın Pençesi)',
      arabicName: 'Al-Dhira (الذراع)',
      signRange: '12° 51\' dk Yengeç – 25° 42\' dk Yengeç',
      startAbsoluteDegree: 102.857,
      endAbsoluteDegree: 115.714,
      nature: 'Çok Uğurlu / Yüce',
      element: 'Ateş',
      description: 'Castor ve Pollux yıldızlarının durağı. Ticari başarı, itibar, otoriteyle iyi geçinme ve korunma durağıdır.',
      favorableFor: 'Resmi makamlarla görüşme, büyük ticaret, seyahat ve bolluk çalışmaları.',
      avoidFor: 'Düşmanlık besleme ve kibir gösterme.',
      hermeticTalisman: 'Kabul görme, itibar ve koruyucu zırh.',
      hermeticStepTitle: '7. Hermetik Adım: İtibar & Koruyucu Kalkan',
      hermeticIncense: 'Sandal Ağacı & Bergamot',
      hermeticPractice: 'Resmi başvurularınızı veya önemli görüşmelerinizi bugün net ve saygın bir dille gerçekleştirin.',
    ),
    LunarMansionInfo(
      number: 8,
      name: 'El-Nesra (Sis / Arı Kovanı)',
      arabicName: 'Al-Nathrah (النثرة)',
      signRange: '25° 43\' dk Yengeç – 08° 34\' dk Aslan',
      startAbsoluteDegree: 115.714,
      endAbsoluteDegree: 128.571,
      nature: 'Uğurlu / Şifalı',
      element: 'Su',
      description: 'Praesepe (Arı Kovanı) kümesi. Aile, ev sıcaklığı, derin duygular ve bedensel şifa durağıdır.',
      favorableFor: 'Evlilik, ev alma/taşınma, dost ziyareti ve doğal şifa tedavileri.',
      avoidFor: 'Gizli kalması gereken sırları paylaşmak.',
      hermeticTalisman: 'Aile huzuru, sağlık ve bereketli yuva.',
      hermeticStepTitle: '8. Hermetik Adım: Yuva Şifası & İçsel Sığınak',
      hermeticIncense: 'Papatya, Lavanta & Balmumu',
      hermeticPractice: 'Yaşam alanınızı havalandırıp düzenleyin; aileniz ve beden sağlığınız için şükran meditasyonu yapın.',
    ),
    LunarMansionInfo(
      number: 9,
      name: 'El-Tarf (Aslanın Bakışı)',
      arabicName: 'Al-Tarf (الطرف)',
      signRange: '08° 34\' dk Aslan – 21° 25\' dk Aslan',
      startAbsoluteDegree: 128.571,
      endAbsoluteDegree: 141.428,
      nature: 'Zorlu / Keskin',
      element: 'Ateş',
      description: 'Aslanın keskin bakışı (Alterf). Yanılsamaları yıkar, aldanmaları engeller fakat gerginlik yaratabilir.',
      favorableFor: 'Gizli planları fark etme, savunma stratejisi ve net sınır çizme.',
      avoidFor: 'Yeni ortaklık, düğün ve seyahat başlangıcı.',
      hermeticTalisman: 'Göz açıklığı, basiret ve nazardan korunma.',
      hermeticStepTitle: '9. Hermetik Adım: Basiret & Sınır Koruma',
      hermeticIncense: 'Üzerlik, Defne & Ardıç',
      hermeticPractice: 'İlişkilerde ve işlerde sınırlarınızı gözden geçirin; enerji emici ortamlardan uzak durun.',
    ),
    LunarMansionInfo(
      number: 10,
      name: 'El-Cebhe (Alın / Regulus)',
      arabicName: 'Al-Jabhah (الجبهة)',
      signRange: '21° 26\' dk Aslan – 04° 17\' dk Başak',
      startAbsoluteDegree: 141.428,
      endAbsoluteDegree: 154.285,
      nature: 'Kraliyet / Yüce',
      element: 'Ateş',
      description: 'Kuzey\'in Kraliyet Yıldızı Regulus\'un (00° 05\' dk Başak) hakimiyeti. Liderlik, asalet ve yüksek onur durağıdır.',
      favorableFor: 'Yönetici pozisyonuna geçme, terfi isteme, proje inşası ve halka hitap.',
      avoidFor: 'İntikam alma arzusu, kibir ve gizli/kaçak işler.',
      hermeticTalisman: 'Şan, şeref, iktidar ve soyluluk.',
      hermeticStepTitle: '10. Hermetik Adım: Regulus Asaleti & Bağışlama',
      hermeticIncense: 'Safran, Günlük & Altın Damla Sakızı',
      hermeticPractice: 'Regulus intikamdan uzak duranlara zirve verir; bugün liderliğinizi adalet ve alicenaplıkla sergileyin.',
    ),
    LunarMansionInfo(
      number: 11,
      name: 'El-Zübre (Aslanın Yelesi)',
      arabicName: 'Al-Zubrah (الزبرة)',
      signRange: '04° 17\' dk Başak – 17° 08\' dk Başak',
      startAbsoluteDegree: 154.285,
      endAbsoluteDegree: 167.142,
      nature: 'Uğurlu / Güçlü',
      element: 'Toprak',
      description: 'Zosma yıldızı (Aslanın yelesi). Maddi güç, saygınlık ve kurtuluş enerjisi barındırır.',
      favorableFor: 'Ticari kazanç, borçlardan kurtulma, seyahate çıkma ve terfi.',
      avoidFor: 'Riskli spekülasyonlar ve aşırı eleştirellik.',
      hermeticTalisman: 'Kazanç kapılarının açılması ve borçtan halas olma.',
      hermeticStepTitle: '11. Hermetik Adım: Maddi Düzen & Bereket',
      hermeticIncense: 'Tarçın, Muskat & Sedir',
      hermeticPractice: 'Bütçenizi ve iş planınızı yapılandırın; gelir artırıcı somut girişimlere odaklanın.',
    ),
    LunarMansionInfo(
      number: 12,
      name: 'El-Sarfe (Dönüşüm / Değişim)',
      arabicName: 'Al-Sarfah (الصرفة)',
      signRange: '17° 09\' dk Başak – 29° 59\' dk Başak',
      startAbsoluteDegree: 167.142,
      endAbsoluteDegree: 180.0,
      nature: 'Değişken / Nötr',
      element: 'Hava',
      description: 'Denebola (21° 38\' dk Başak) yıldızıyla bağlantılıdır. Mevsim dönüşümünü ve eskiyi geride bırakmayı simgeler.',
      favorableFor: 'Toprak işleri, tarım, eski alışkanlıkları terk etme ve sistem yenileme.',
      avoidFor: 'Evlilik ve uzun vadeli katı ortaklıklar.',
      hermeticTalisman: 'Zararlı bağları kesme ve radikal dönüşüm.',
      hermeticStepTitle: '12. Hermetik Adım: Arınma & Sadeleşme',
      hermeticIncense: 'Adaçayı, Okaliptüs & Limon Otu',
      hermeticPractice: 'Hayatınızda işlevini yitirmiş eşyaları, alışkanlıkları ve zihinsel yükleri bugün temizleyin.',
    ),
    LunarMansionInfo(
      number: 13,
      name: 'El-Avva (Uluyanlar / Başak Kanadı)',
      arabicName: 'Al-Awwa (العواء)',
      signRange: '00° 00\' dk Terazi – 12° 51\' dk Terazi',
      startAbsoluteDegree: 180.0,
      endAbsoluteDegree: 192.857,
      nature: 'Çok Uğurlu / Şifalı',
      element: 'Su',
      description: 'Porrima ve Vindemiatrix yıldızları. Zanaat, diplomasi, ticaret, sevgi ve şifa konularında etkilidir.',
      favorableFor: 'Evlilik, aşk, ticari anlaşma, tedaviye başlama ve estetik üretim.',
      avoidFor: 'Ani söz kesmeler ve kaba tartışmalar.',
      hermeticTalisman: 'Aşk, şifa, üretkenlik ve ticari bereket.',
      hermeticStepTitle: '13. Hermetik Adım: Zarafet & Uyum Rezonansı',
      hermeticIncense: 'Gül Ağacı, Ylang-Ylang & Misk',
      hermeticPractice: 'İlişkilerinizde ve işlerinizde diplomasi ve estetik uyumu ön plana çıkararak anlaşmalarınızı güçlendirin.',
    ),
    LunarMansionInfo(
      number: 14,
      name: 'El-Simak (Spica / Başak Başağı)',
      arabicName: 'Al-Simak (السماك الأعزل)',
      signRange: '12° 51\' dk Terazi – 25° 42\' dk Terazi',
      startAbsoluteDegree: 192.857,
      endAbsoluteDegree: 205.714,
      nature: 'Son Derece Uğurlu / Kutsal',
      element: 'Toprak',
      description: 'Gökyüzünün en uğurlu yıldızı Spica\'nın (23° 50\' dk Terazi) kutsal durağı. Sanat, bilgelik, ruhsal korunma ve refahın zirvesidir.',
      favorableFor: 'Her türlü hayırlı iş, evlilik, şifa, sanat, bilim ve manevi çalışmalar.',
      avoidFor: 'Olumsuz hiçbir tarafı yoktur, tam sa\'d (kutlu) durağıdır.',
      hermeticTalisman: 'İlahi koruma, şans, bereket ve ruhsal aydınlanma.',
      hermeticStepTitle: '14. Hermetik Adım: Spica\'nın Altın Başağı',
      hermeticIncense: 'Saf Günlük, Sandal Ağacı & Yasemin',
      hermeticPractice: 'En önemli projelerinizi, dualarınızı ve uzun vadeli niyetlerinizi Spica\'nın koruyucu frekansıyla başlatın.',
    ),
    LunarMansionInfo(
      number: 15,
      name: 'El-Gafir (Örtü / Koruyucu)',
      arabicName: 'Al-Ghafr (الغفر)',
      signRange: '25° 43\' dk Terazi – 08° 34\' dk Akrep',
      startAbsoluteDegree: 205.714,
      endAbsoluteDegree: 218.571,
      nature: 'Uğurlu / Gizleyici',
      element: 'Hava',
      description: 'Syrma yıldızı durağı. Gizlenme, korunma, derin araştırma ve sükunet için idealdir.',
      favorableFor: 'Sır tutma, barışma, stratejik hazırlık, anlaşma imzalama ve meditasyon.',
      avoidFor: 'Açık savaş ve gereksiz meydan okumalar.',
      hermeticTalisman: 'Korunma, mahremiyet ve sükunete erme.',
      hermeticStepTitle: '15. Hermetik Adım: Sessizliğin Gücü',
      hermeticIncense: 'Mür, Selvi & Lavanta',
      hermeticPractice: 'Projelerinizi olgunlaşana dek gizli tutun; içsel enerjinizi dış bakışlardan koruyarak derinleşin.',
    ),
    LunarMansionInfo(
      number: 16,
      name: 'El-Zübana (Terazinin Kefeleri)',
      arabicName: 'Al-Zubana (الزبانا)',
      signRange: '08° 34\' dk Akrep – 21° 25\' dk Akrep',
      startAbsoluteDegree: 218.571,
      endAbsoluteDegree: 231.428,
      nature: 'Karmaşık / Denge Sınavı',
      element: 'Ateş',
      description: 'Zubenelgenubi (15° Akrep) ve Zubeneschamali (19° Akrep) yıldızları. İlahi adalet, denge ve karmik hesaplaşma eşiğidir.',
      favorableFor: 'Alacak tahsilatı, ticari pazarlık, hak arama ve psikolojik yüzleşme.',
      avoidFor: 'Haksız kazanç, cerrahi operasyonlar ve aceleci ortaklıklar.',
      hermeticTalisman: 'Adalet, hak teslimi ve karmik denge.',
      hermeticStepTitle: '16. Hermetik Adım: Hakikat Kefesi',
      hermeticIncense: 'Karabiber, Sedir & Günlük',
      hermeticPractice: 'Hayatınızdaki alma-verme dengesini tartın; hakkınız olanı adaletle talep edin, borçlarınızı kapatın.',
    ),
    LunarMansionInfo(
      number: 17,
      name: 'El-İklil (Akrep Tacı / Al-Iklil)',
      arabicName: 'Al-Iklil (الإكليل)',
      signRange: '21° 26\' dk Akrep – 04° 17\' dk Yay',
      startAbsoluteDegree: 231.428,
      endAbsoluteDegree: 244.285,
      nature: 'Güçlü / Gizemli',
      element: 'Su',
      description: 'Acrab ve Dschubba yıldızları (Akrep burcunun tacı). Gizemli ilimler, derin sezgiler ve sabırla gelen zafer durağıdır.',
      favorableFor: 'Ruhsal arınma, gizli araştırmalar, strateji yapma ve koruyucu tefekkür.',
      avoidFor: 'Aceleci kararlar ve fevri borçlanma.',
      hermeticTalisman: 'Gizli güç, sezgisel uyanış ve sabır tacı.',
      hermeticStepTitle: '17. Hermetik Adım: Sezgi Tacının Uyanışı',
      hermeticIncense: 'Paçuli, Mür & Kara Kehribar',
      hermeticPractice: 'Yüzeyin altındaki gerçekleri görmek için sezgilerinizi dinleyin; sabır ve stratejiyle hareket edin.',
    ),
    LunarMansionInfo(
      number: 18,
      name: 'El-Kalb (Akrep Kalbi / Antares)',
      arabicName: 'Al-Qalb (القلب)',
      signRange: '04° 17\' dk Yay – 17° 08\' dk Yay',
      startAbsoluteDegree: 244.285,
      endAbsoluteDegree: 257.142,
      nature: 'Sert / Savaşçı',
      element: 'Ateş',
      description: 'Batı\'nın Kraliyet Yıldızı Antares\'in (09° 46\' dk Yay) durağı. Tutku, cesaret, stratejik güç ve küllerinden doğuş döngüsüdür.',
      favorableFor: 'Korkularla yüzleşme, büyük dönüşüm hamleleri ve kararlı savunma.',
      avoidFor: 'Aşırı hırs, takıntı, yıkıcı öfke ve fevri kavgalar.',
      hermeticTalisman: 'Yenilmezlik, korkusuzluk ve kriz yönetimi.',
      hermeticStepTitle: '18. Hermetik Adım: Antares Tutkusu & Öz-Kontrol',
      hermeticIncense: 'Ejderha Kanı Reçinesi, Tarçın & Günlük',
      hermeticPractice: 'Antares tutkuyu bilgeliğe dönüştürenleri yüceltir; bugün hırsınızı yıkıma değil, yüksek bir ideale kanalize edin.',
    ),
    LunarMansionInfo(
      number: 19,
      name: 'El-Şevle (Akrep İğnesi / Shaula)',
      arabicName: 'Al-Shaulah (الشولة)',
      signRange: '17° 09\' dk Yay – 29° 59\' dk Yay',
      startAbsoluteDegree: 257.142,
      endAbsoluteDegree: 270.0,
      nature: 'Keskin / Dönüştürücü',
      element: 'Su',
      description: 'Shaula (24° 35\' dk Yay) yıldızı durağı. Zehirden panzehir üretme, köklü temizlik, detoks ve hedefi tam on ikiden vurma.',
      favorableFor: 'Zararlı alışkanlıkları bırakma, detoks ve toksik bağları koparma.',
      avoidFor: 'Yeni ortaklık, düğün ve hazırlıksız seyahat.',
      hermeticTalisman: 'Şifa bulma, arınma ve zehri panzehire çevirme.',
      hermeticStepTitle: '19. Hermetik Adım: Simyasal Detoks & Panzehir',
      hermeticIncense: 'Okaliptüs, Adaçayı & Çay Ağacı',
      hermeticPractice: 'Bedeninizi ve zihninizi toksik unsurlardan arındırın; tek bir yüksek hedefe ok gibi odaklanın.',
    ),
    LunarMansionInfo(
      number: 20,
      name: 'El-Neayim (Deve Kuşları)',
      arabicName: 'Al-Na\'am (النعائم)',
      signRange: '00° 00\' dk Oğlak – 12° 51\' dk Oğlak',
      startAbsoluteDegree: 270.0,
      endAbsoluteDegree: 282.857,
      nature: 'Çok Uğurlu / Vizyoner',
      element: 'Ateş',
      description: 'Kaus Australis ve Nunki yıldızları. Felsefe, uzun yolculuklar, maneviyat ve kurumsal vizyon geliştirme durağıdır.',
      favorableFor: 'Uzak seyahatler, yüksek eğitim, kitap basımı, kariyer hedefleri ve inziva.',
      avoidFor: 'Dar görüşlü tartışmalar ve küçük hesaplar.',
      hermeticTalisman: 'Vizyon açıklığı, yüksek başarı ve seyahat selameti.',
      hermeticStepTitle: '20. Hermetik Adım: Ufukların Ötesi & Vizyon',
      hermeticIncense: 'Sedir Ağacı, Günlük & Defne',
      hermeticPractice: 'Uzun vadeli (1 ve 5 yıllık) hedeflerinizi yazılı olarak yapılandırın ve büyük resme odaklanın.',
    ),
    LunarMansionInfo(
      number: 21,
      name: 'El-Belde (Şehir / Kutsal Alan)',
      arabicName: 'Al-Baldah (البلدة)',
      signRange: '12° 51\' dk Oğlak – 25° 42\' dk Oğlak',
      startAbsoluteDegree: 282.857,
      endAbsoluteDegree: 295.714,
      nature: 'Uğurlu / Yapıcı',
      element: 'Toprak',
      description: 'Gökyüzünün sakin ve vakur alanı. Şehirleşme, temel atma, mülk edinme ve sağlam kurallar koyma durağıdır.',
      favorableFor: 'Gayrimenkul alımı, inşaat başlatma, kurumsal yapılandırma ve sözleşmeler.',
      avoidFor: 'Riskli kefalet altına girmek.',
      hermeticTalisman: 'Kalıcı mülk, güvenli sığınak ve istikrar.',
      hermeticStepTitle: '21. Hermetik Adım: Sarsılmaz Temel İnşası',
      hermeticIncense: 'Vetiver, Meşe Yosunu & Sandal',
      hermeticPractice: 'Kariyer ve maddi hayatınızda kalıcı olacak yapısal bir düzenleme veya yatırım planı oluşturun.',
    ),
    LunarMansionInfo(
      number: 22,
      name: 'Sa\'d el-Zabih (Adanmışın Uğuru)',
      arabicName: 'Sa\'d al-Dhabih (سعد الذابح)',
      signRange: '25° 43\' dk Oğlak – 08° 34\' dk Kova',
      startAbsoluteDegree: 295.714,
      endAbsoluteDegree: 308.571,
      nature: 'Disiplinli / Şifalı Özveri',
      element: 'Toprak',
      description: 'Dabih yıldızı durağı. Disiplin, adanmışlık, nefis terbiyesi ve şifa hazırlama enerjisidir.',
      favorableFor: 'Tıbbi tedavi, şifa çalışmaları, köklü disiplin ve borç ödeme.',
      avoidFor: 'Yüzeysel eğlenceler ve sorumsuz vaatler.',
      hermeticTalisman: 'Şifa, sadakat ve yüksek öz-disiplin.',
      hermeticStepTitle: '22. Hermetik Adım: Özveri & Disiplin Simyası',
      hermeticIncense: 'Mür, Biberiye & Çam',
      hermeticPractice: 'Büyük bir hedefe ulaşmak için sizi yavaşlatan küçük bir konfor alışkanlığından bugün bilinçli olarak vazgeçin.',
    ),
    LunarMansionInfo(
      number: 23,
      name: 'Sa\'d Bula (Yutanın Uğuru)',
      arabicName: 'Sa\'d Bula (سعد بلع)',
      signRange: '08° 34\' dk Kova – 21° 25\' dk Kova',
      startAbsoluteDegree: 308.571,
      endAbsoluteDegree: 321.428,
      nature: 'Değişken / Arındırıcı',
      element: 'Hava',
      description: 'Albali yıldızı durağı. Hastalıkları, kederleri ve negatif enerjileri yutup etkisizleştiren kadim duraktır.',
      favorableFor: 'Kısıtlamalardan kurtulma, borç tasfiyesi, şifa ve beden detoksu.',
      avoidFor: 'Yeni borçlanma ve spekülatif yatırımlar.',
      hermeticTalisman: 'Kederlerin dağılması, özgürleşme ve şifa.',
      hermeticStepTitle: '23. Hermetik Adım: Kederin Tasfiyesi & Özgürlük',
      hermeticIncense: 'Kافur, Beyaz Adaçayı & Lavanta',
      hermeticPractice: 'Zihninizi meşgul eden endişeleri yazıp imha edin; su tüketiminizi artırarak bedensel arınma sağlayın.',
    ),
    LunarMansionInfo(
      number: 24,
      name: 'Sa\'d el-Suud (Uğurların En Uğurlusu)',
      arabicName: 'Sa\'d al-Su\'ud (سعد السعود)',
      signRange: '21° 26\' dk Kova – 04° 17\' dk Balık',
      startAbsoluteDegree: 321.428,
      endAbsoluteDegree: 334.285,
      nature: 'En Yüce Uğurlu (Sa\'d-ı Ekber)',
      element: 'Hava',
      description: 'Sadalsuud (23° 46\' dk Kova) yıldızının durağı. Göklerin en bereketli menzili; talih, refah ve beklenmedik lütuflar.',
      favorableFor: 'Evlilik, yeni iş kurma, büyük yatırımlar, terfi ve hayırlı başlangıçlar.',
      avoidFor: 'Karamsarlık ve şükürsüzlük.',
      hermeticTalisman: 'Maksimum şans, ilahi lütuf ve büyük saadet.',
      hermeticStepTitle: '24. Hermetik Adım: Sa\'d-ı Ekber Bereket Kapısı',
      hermeticIncense: 'Saf Günlük, Amber & Gül',
      hermeticPractice: 'Hayatınızdaki tüm nimetler için derin şükran duyun ve en parlak projenizi bugün hayata geçirin.',
    ),
    LunarMansionInfo(
      number: 25,
      name: 'Sa\'d el-Ahbiye (Saadülahbiye / Çadırların Uğuru)',
      arabicName: 'Sa\'d al-Akhbiyah (سعد الأخبية)',
      signRange: '04° 17\' dk Balık – 17° 08\' dk Balık',
      startAbsoluteDegree: 334.285,
      endAbsoluteDegree: 347.142,
      nature: 'Uğurlu / Keşif & Korunma',
      element: 'Su',
      description: 'Sadachbia yıldızı durağı (04° 17\' dk Balık – 17° 08\' dk Balık). Toprağın altındaki gizli suların, saklı hazinelerin ve örtülü bilgilerin açığa çıktığı, koruyucu çadırların kurulduğu duraktır.',
      favorableFor: 'Keşif yapma, gizli ilimleri öğrenme, araştırma, korunma, şifa ve manevi derinleşme.',
      avoidFor: 'Gizli hilelere kalkışmak ve kibir.',
      hermeticTalisman: 'Gizli hazinelerin keşfi, ilahi muhafaza ve derin ilham.',
      hermeticStepTitle: '25. Hermetik Adım: Saadülahbiye Saklı Hazinelerin Uyanışı',
      hermeticIncense: 'Sandal Ağacı, Mür & Lotus',
      hermeticPractice: 'İç dünyanızdaki saklı yeteneklere ve sezgisel rüyalarınıza odaklanın; araştırmalarınızda derin katmanlara inin.',
    ),
    LunarMansionInfo(
      number: 26,
      name: 'El-Ferğ el-Mukaddem (Ön Kova)',
      arabicName: 'Al-Fargh al-Muqaddam (الفرغ المقدم)',
      signRange: '17° 09\' dk Balık – 29° 59\' dk Balık',
      startAbsoluteDegree: 347.142,
      endAbsoluteDegree: 360.0,
      nature: 'Uğurlu / Cömert',
      element: 'Su',
      description: 'Markab ve Sadalmelik hattı. Gökten inen rahmet pınarı; cömertlik, dostluk, bağışlama ve manevi arınma durağıdır.',
      favorableFor: 'Evlilik, hayır işleri yapma, dost barışması, şifa ve seyahat.',
      avoidFor: 'Deniz yolculuklarına tedbirsiz çıkmak ve aşırı dağılmak.',
      hermeticTalisman: 'Manevi rahmet, şefkat ve dostluk bereketi.',
      hermeticStepTitle: '26. Hermetik Adım: Rahmet Pınarı & Bağışlama',
      hermeticIncense: 'Yasemin, Günlük & Beyaz Misk',
      hermeticPractice: 'Cömertlik ve yardımlaşma enerjisini çalıştırın; ruhsal yüklerinizi şefkatle serbest bırakın.',
    ),
  ];

  /// Verilen zodyak mutlak derecesine (0.0 - 360.0) karşılık gelen 28 Ay menzilini hesaplar.
  static LunarMansionInfo getMansionForDegree(double absoluteDegree) {
    double deg = absoluteDegree % 360.0;
    if (deg < 0) deg += 360.0;

    for (final m in mansions) {
      if (deg >= m.startAbsoluteDegree && deg < m.endAbsoluteDegree) {
        return m;
      }
    }
    return mansions.last;
  }

  /// Burç adı ve burç içi dereceye (0° 00' dk – 29° 59' dk) göre menzili bulur
  static LunarMansionInfo getMansionForSignDegree(String signName, double degreeInSign) {
    final signIndex = _getSignIndex(signName);
    final clampedDeg = degreeInSign.clamp(0.0, 29.999);
    final absoluteDegree = signIndex * 30.0 + clampedDeg;
    return getMansionForDegree(absoluteDegree);
  }

  /// Canlı gökyüzü Ay menzili (Anlık canlı transit Ay boylamına göre)
  static LunarMansionInfo getCurrentMoonMansion([DateTime? dt]) {
    final now = dt ?? DateTime.now();
    final moonLon = SkyTransitsService.calculateMoonLongitude(now);
    return getMansionForDegree(moonLon);
  }

  /// Anlık transit Ay boylamını ve burç içi derecesini (00° 00' dk - 29° 59' dk) döndürür
  static Map<String, dynamic> getCurrentMoonPosition([DateTime? dt]) {
    final now = dt ?? DateTime.now();
    double moonLon = SkyTransitsService.calculateMoonLongitude(now) % 360.0;
    if (moonLon < 0) moonLon += 360.0;

    int signIdx = (moonLon / 30.0).floor() % 12;
    final degInSign = moonLon % 30.0;
    int deg = degInSign.floor();
    int min = ((degInSign - deg) * 60).round();
    if (min >= 60) {
      min = 0;
      deg += 1;
      if (deg >= 30) {
        deg = 0;
        signIdx = (signIdx + 1) % 12;
      }
    }
    const signNames = [
      'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
      'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
    ];
    final degStr = deg.toString().padLeft(2, '0');
    final minStr = min.toString().padLeft(2, '0');
    return {
      'absoluteDegree': moonLon,
      'sign': signNames[signIdx],
      'degree': deg,
      'minute': min,
      'formatted': '$degStr° $minStr\' dk ${signNames[signIdx]}',
      'mansion': getMansionForDegree(moonLon),
    };
  }

  /// Gelecek [daysAhead] gün içindeki 28 Ay Menzili geçişlerini dakika hassasiyetiyle tespit eder
  static List<MoonMansionTransitionEvent> findUpcomingMoonMansionTransitions({
    DateTime? from,
    int daysAhead = 14,
  }) {
    final start = from ?? DateTime.now();
    final end = start.add(Duration(days: daysAhead));
    final List<MoonMansionTransitionEvent> events = [];

    DateTime current = start;
    double currentLon = SkyTransitsService.calculateMoonLongitude(current);
    LunarMansionInfo currentMansion = getMansionForDegree(currentLon);

    const step = Duration(minutes: 30);

    while (current.isBefore(end)) {
      final next = current.add(step);
      final nextLon = SkyTransitsService.calculateMoonLongitude(next);
      final nextMansion = getMansionForDegree(nextLon);

      if (nextMansion.number != currentMansion.number) {
        // İkili arama (Binary search) ile menzil sınırını geçtiği tam dakikayı bul
        DateTime low = current;
        DateTime high = next;
        while (high.difference(low).inSeconds > 60) {
          final mid = low.add(Duration(seconds: high.difference(low).inSeconds ~/ 2));
          final midLon = SkyTransitsService.calculateMoonLongitude(mid);
          final midMansion = getMansionForDegree(midLon);
          if (midMansion.number == currentMansion.number) {
            low = mid;
          } else {
            high = mid;
          }
        }

        final transitionMoment = high;
        final favFirst = nextMansion.favorableFor.split('.').first.trim();
        final avoidFirst = nextMansion.avoidFor.split('.').first.trim();

        if (transitionMoment.isBefore(end)) {
          events.add(MoonMansionTransitionEvent(
            oldMansionNumber: currentMansion.number,
            oldMansionName: currentMansion.name,
            newMansionNumber: nextMansion.number,
            newMansionName: nextMansion.name,
            arabicName: nextMansion.arabicName,
            nature: nextMansion.nature,
            signRange: nextMansion.signRange,
            favorableFor: nextMansion.favorableFor,
            avoidFor: nextMansion.avoidFor,
            eventTime: transitionMoment,
            title: '🔮 Ay Yeni Menzile Geçti: ${nextMansion.name}',
            body: '${nextMansion.arabicName} [${nextMansion.nature}]. Uğurlu: $favFirst. Sakınılması gereken: $avoidFirst.',
          ));
        }

        current = high.add(const Duration(seconds: 1));
        currentLon = SkyTransitsService.calculateMoonLongitude(current);
        currentMansion = getMansionForDegree(currentLon);
      } else {
        current = next;
      }
    }

    return events;
  }

  static int _getSignIndex(String sign) {
    final s = sign.toLowerCase().trim();
    if (s.contains('koç') || s.contains('aries')) return 0;
    if (s.contains('boğa') || s.contains('taurus')) return 1;
    if (s.contains('ikizler') || s.contains('gemini')) return 2;
    if (s.contains('yengeç') || s.contains('cancer')) return 3;
    if (s.contains('aslan') || s.contains('leo')) return 4;
    if (s.contains('başak') || s.contains('virgo')) return 5;
    if (s.contains('terazi') || s.contains('libra')) return 6;
    if (s.contains('akrep') || s.contains('scorpio')) return 7;
    if (s.contains('yay') || s.contains('sagittarius')) return 8;
    if (s.contains('oğlak') || s.contains('capricorn')) return 9;
    if (s.contains('kova') || s.contains('aquarius')) return 10;
    if (s.contains('balık') || s.contains('pisces')) return 11;
    return 0;
  }
}
