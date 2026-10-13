import 'sky_transits_service.dart';

class LunarMansionInfo {
  final int number; // 1 - 28
  final String name; // Türkçe / Yaygın isim
  final String arabicName; // Arapça / Kadim isim
  final String signRange; // Burç derecesi aralığı (örn: 0°00' Koç - 12°51' Koç)
  final double startAbsoluteDegree;
  final double endAbsoluteDegree;
  final String nature; // Uğurlu (Sa'd), Nötr, Dikkat/Zorlu (Nahs)
  final String element; // Ateş, Toprak, Hava, Su
  final String description; // Genel Hermetik Anlam
  final String favorableFor; // Bu menzilde ne yapılmalı?
  final String avoidFor; // Bu menzilde nelerden sakınılmalı?
  final String hermeticTalisman; // Kadim Hermetik Tılsım/Sembol enerjisi

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
  });
}

class LunarMansionsService {
  static const double mansionSpan = 360.0 / 28.0; // 12.857142857° (12° 51' 26")

  static const List<LunarMansionInfo> mansions = [
    LunarMansionInfo(
      number: 1,
      name: 'El-Şaratan (Boynuzlar)',
      arabicName: 'Al-Sharatain (الشرطان)',
      signRange: '0°00\' - 12°51\' Koç',
      startAbsoluteDegree: 0.0,
      endAbsoluteDegree: 12.857,
      nature: 'Zorlu / Ateşli',
      element: 'Ateş',
      description: 'Koç burcunun öncü başı. Cesaret, hızlı hamleler ve ani başlangıçların durağıdır. Dürtüsellik yüksektir.',
      favorableFor: 'Fiziksel güç gerektiren işler, ameliyatlar, cesaretle adım atma, mücadele ve rekabet.',
      avoidFor: 'Evlilik, antlaşma imzalama, uzun vadeli ortaklıklar ve borç alma.',
      hermeticTalisman: 'Cesaret, zafer ve engelleri aşma iradesi.',
    ),
    LunarMansionInfo(
      number: 2,
      name: 'El-Butayn (Karın)',
      arabicName: 'Al-Butain (البطين)',
      signRange: '12°51\' - 25°43\' Koç',
      startAbsoluteDegree: 12.857,
      endAbsoluteDegree: 25.714,
      nature: 'Uğurlu / Bereketli',
      element: 'Toprak',
      description: 'Gizli tohumların filizlendiği duraktır. Sabırla ekilen şeylerin kök salmasını sağlar.',
      favorableFor: 'Tohum ekme, gayrimenkul alımı, hazine ve kaynak arayışı, seyahat hazırlığı.',
      avoidFor: 'Aceleci spekülasyonlar ve fevri tartışmalar.',
      hermeticTalisman: 'Zenginleşme, bereket ve gizli kaynakların açığa çıkması.',
    ),
    LunarMansionInfo(
      number: 3,
      name: 'El-Süreyya (Ülker / Pleiades)',
      arabicName: 'Al-Thurayya (الثريا)',
      signRange: '25°43\' Koç - 8°34\' Boğa',
      startAbsoluteDegree: 25.714,
      endAbsoluteDegree: 38.571,
      nature: 'Çok Uğurlu / Işıltılı',
      element: 'Hava',
      description: 'Kadim gökyüzünün mücevheri. Aşk, sanat, kadınsı bilgelik ve derin çekim gücü verir.',
      favorableFor: 'Sanat, müzik, aşk itirafları, güzellik bakımları, ticaret ve simya çalışmaları.',
      avoidFor: 'Deniz yolculukları ve intikam içeren düşünceler.',
      hermeticTalisman: 'Sevgi celbi, şöhret, estetik cazibe ve bolluk.',
    ),
    LunarMansionInfo(
      number: 4,
      name: 'El-Deberan (Aldebaran)',
      arabicName: 'Al-Dabaran (الدبران)',
      signRange: '8°34\' - 21°26\' Boğa',
      startAbsoluteDegree: 38.571,
      endAbsoluteDegree: 51.428,
      nature: 'Sert / Hükmedici',
      element: 'Toprak',
      description: 'Doğu\'nun Kraliyet Yıldızı Aldebaran\'ın durağı. Güçlü irade, dürüstlük ve yıkıcı tutkular barındırır.',
      favorableFor: 'İnşaat temeli atma, madencilik, düşman planlarını bozma ve liderlik kararları.',
      avoidFor: 'Evlilik, dostluk kurma ve duygusal uzlaşmalar.',
      hermeticTalisman: 'Kudret, düşmanları bertaraf etme ve kararlılık.',
    ),
    LunarMansionInfo(
      number: 5,
      name: 'El-Heka (Avcının Başı)',
      arabicName: 'Al-Haq\'ah (الهقعة)',
      signRange: '21°26\' Boğa - 4°17\' İkizler',
      startAbsoluteDegree: 51.428,
      endAbsoluteDegree: 64.285,
      nature: 'Uğurlu / Zihinsel',
      element: 'Hava',
      description: 'Orion takımyıldızının tacı. Zihinsel uyanış, öğrenme ve ruhsal rehberlik durağıdır.',
      favorableFor: 'Eğitim, okuma, ezoterik ilimler, antlaşmalar ve usta çırak ilişkileri.',
      avoidFor: 'Bedenen aşırı yorulma ve borç kefaleti.',
      hermeticTalisman: 'Zihin açıklığı, ilham ve sezgisel kavrayış.',
    ),
    LunarMansionInfo(
      number: 6,
      name: 'El-Hana (Damga / Çapraz)',
      arabicName: 'Al-Han\'ah (الهنعة)',
      signRange: '4°17\' - 17°09\' İkizler',
      startAbsoluteDegree: 64.285,
      endAbsoluteDegree: 77.142,
      nature: 'Uğurlu / Sosyal',
      element: 'Su',
      description: 'İkizler burcunun kalbi. İletişim, dostluk, ittifaklar ve sevgi bağlarını güçlendirir.',
      favorableFor: 'Ortaklık kurma, dostlukları pekiştirme, avlanma ve ticaret anlaşmaları.',
      avoidFor: 'Miras davaları ve hukuki restleşmeler.',
      hermeticTalisman: 'Uzlaşma, dostluk ve sevgide devamlılık.',
    ),
    LunarMansionInfo(
      number: 7,
      name: 'El-Zira (Aslanın Pençesi)',
      arabicName: 'Al-Dhira (الذراع)',
      signRange: '17°09\' İkizler - 0°00\' Yengeç',
      startAbsoluteDegree: 77.142,
      endAbsoluteDegree: 90.0,
      nature: 'Çok Uğurlu / Yüce',
      element: 'Ateş',
      description: 'Yaz gündönümünün kapısı. Ticari başarı, itibar, otoriteyle iyi geçinme ve korunma durağıdır.',
      favorableFor: 'Resmi makamlarla görüşme, büyük ticaret, seyahat, bolluk duaları.',
      avoidFor: 'Düşmanlık besleme ve kibir gösterme.',
      hermeticTalisman: 'Kabul görme, itibar ve koruyucu zırh.',
    ),
    LunarMansionInfo(
      number: 8,
      name: 'El-Nesra (Sis / Arı Kovanı)',
      arabicName: 'Al-Nathrah (النثرة)',
      signRange: '0°00\' - 12°51\' Yengeç',
      startAbsoluteDegree: 90.0,
      endAbsoluteDegree: 102.857,
      nature: 'Uğurlu / Şifalı',
      element: 'Su',
      description: 'Praesepe kümesi. Aile, ev sıcaklığı, derin duygular ve bedensel şifa durağıdır.',
      favorableFor: 'Evlilik, ev alma/taşınma, dost ziyareti ve doğal şifa tedavileri.',
      avoidFor: 'Gizli kalması gereken sırları paylaşmak.',
      hermeticTalisman: 'Aile huzuru, sağlık ve bereketli yuva.',
    ),
    LunarMansionInfo(
      number: 9,
      name: 'El-Tarf (Aslanın Bakışı)',
      arabicName: 'Al-Tarf (الطرف)',
      signRange: '12°51\' - 25°43\' Yengeç',
      startAbsoluteDegree: 102.857,
      endAbsoluteDegree: 115.714,
      nature: 'Zorlu / Keskin',
      element: 'Ateş',
      description: 'Aslanın keskin bakışı. Yanılsamaları yıkar, aldanmaları engeller fakat gerginlik yaratabilir.',
      favorableFor: 'Düşman planlarını ifşa etme, savunma stratejisi ve sınır çizme.',
      avoidFor: 'Yeni ortaklık, düğün ve seyahat başlangıcı.',
      hermeticTalisman: 'Göz açıklığı, basiret ve nazardan korunma.',
    ),
    LunarMansionInfo(
      number: 10,
      name: 'El-Cebhe (Alın / Regulus)',
      arabicName: 'Al-Jabhah (الجبهة)',
      signRange: '25°43\' Yengeç - 8°34\' Aslan',
      startAbsoluteDegree: 115.714,
      endAbsoluteDegree: 128.571,
      nature: 'Kraliyet / Yüce',
      element: 'Ateş',
      description: 'Kuzey\'in Kralı Regulus\'un hakimiyeti. Hükümdarlık, liderlik ve yüksek onur durağıdır.',
      favorableFor: 'Yönetici pozisyonuna geçme, terfi isteme, bina yapımı ve halka hitap.',
      avoidFor: 'Gizli/kaçak işler ve yalan söylemek (ağır bedel ödetir).',
      hermeticTalisman: 'Şan, şeref, iktidar ve soyluluk.',
    ),
    LunarMansionInfo(
      number: 11,
      name: 'El-Zübre (Aslanın Yelesi)',
      arabicName: 'Al-Zubrah (الزبرة)',
      signRange: '8°34\' - 21°26\' Aslan',
      startAbsoluteDegree: 128.571,
      endAbsoluteDegree: 141.428,
      nature: 'Uğurlu / Güçlü',
      element: 'Toprak',
      description: 'Aslanın omzu ve yelesi. Maddi güç, saygınlık ve kurtuluş enerjisi barındırır.',
      favorableFor: 'Ticari kazanç, borçlardan kurtulma, seyahate çıkma ve terfi.',
      avoidFor: 'Hastalık tedavisine başlamak için dikkat edilmeli.',
      hermeticTalisman: 'Kazanç kapılarının açılması ve borçtan halas olma.',
    ),
    LunarMansionInfo(
      number: 12,
      name: 'El-Sarfe (Dönüşüm / Değişim)',
      arabicName: 'Al-Sarfah (الصرفة)',
      signRange: '21°26\' Aslan - 4°17\' Başak',
      startAbsoluteDegree: 141.428,
      endAbsoluteDegree: 154.285,
      nature: 'Değişken / Nötr',
      element: 'Hava',
      description: 'Denebola yıldızıyla bağlantılıdır. Mevsim dönüşümünü ve eskiyi geride bırakmayı simgeler.',
      favorableFor: 'Toprak işleri, tarım, eski alışkanlıkları terk etme ve hizmet sözleşmeleri.',
      avoidFor: 'Evlilik ve uzun vadeli ortaklıklar.',
      hermeticTalisman: 'Zararlı bağları kesme ve radikal dönüşüm.',
    ),
    LunarMansionInfo(
      number: 13,
      name: 'El-Avva (Uluyanlar / Köpekler)',
      arabicName: 'Al-Awwa (العواء)',
      signRange: '4°17\' - 17°09\' Başak',
      startAbsoluteDegree: 154.285,
      endAbsoluteDegree: 167.142,
      nature: 'Çok Uğurlu / Şifalı',
      element: 'Su',
      description: 'Hasat ve bereket durağı. Zanaat, ticaret, sevgi ve cinsel şifa konularında etkilidir.',
      favorableFor: 'Evlilik, aşk, ticari anlaşma, tedaviye başlama ve zanaat üretimi.',
      avoidFor: 'Deniz yolculukları ve ani söz kesmeler.',
      hermeticTalisman: 'Aşk, şifa, üretkenlik ve ticari bereket.',
    ),
    LunarMansionInfo(
      number: 14,
      name: 'El-Simak (Spica / Başak Başağı)',
      arabicName: 'Al-Simak (السماك الأعزل)',
      signRange: '17°09\' Başak - 0°00\' Terazi',
      startAbsoluteDegree: 167.142,
      endAbsoluteDegree: 180.0,
      nature: 'Son Derece Uğurlu / Kutsal',
      element: 'Toprak',
      description: 'Spica yıldızının kutsal durağı. Sanat, bilgelik, ruhsal korunma ve refahın zirvesidir.',
      favorableFor: 'Her türlü hayırlı iş, evlilik, şifa, sanat ve manevi çalışmalar.',
      avoidFor: 'Olumsuz hiçbir tarafı yoktur, tam sa\'d durağıdır.',
      hermeticTalisman: 'İlahi koruma, şans, bereket ve ruhsal aydınlanma.',
    ),
    LunarMansionInfo(
      number: 15,
      name: 'El-Gafir (Örtü / Koruyucu)',
      arabicName: 'Al-Ghafr (الغفر)',
      signRange: '0°00\' - 12°51\' Terazi',
      startAbsoluteDegree: 180.0,
      endAbsoluteDegree: 192.857,
      nature: 'Uğurlu / Gizleyici',
      element: 'Hava',
      description: 'Gizlenme, korunma ve sükunet durağı. Sır saklama ve huzurlu ilişkiler için idealdir.',
      favorableFor: 'Sır tutma, barışma, hazine saklama, anlaşma imzalama ve meditasyon.',
      avoidFor: 'Açık savaş ve meydan okumalar.',
      hermeticTalisman: 'Görünmezlik, korunma ve sükunete erme.',
    ),
    LunarMansionInfo(
      number: 16,
      name: 'El-Zübana (Terazinin Kefeleri)',
      arabicName: 'Al-Zubana (الزبانا)',
      signRange: '12°51\' - 25°43\' Terazi',
      startAbsoluteDegree: 192.857,
      endAbsoluteDegree: 205.714,
      nature: 'Karmaşık / Yanık Yol Başlangıcı',
      element: 'Ateş',
      description: 'Zubenelgenubi ve Zubeneschamali. Adalet, denge arayışı ve Yanık Yol (Via Combusta) eşiği.',
      favorableFor: 'Alacak tahsilatı, ticari pazarlık ve hak arama davaları.',
      avoidFor: 'Evlilik, cerrahi operasyonlar ve yeni ortaklıklar.',
      hermeticTalisman: 'Adalet, hak teslimi ve denge kurma.',
    ),
    LunarMansionInfo(
      number: 17,
      name: 'El-İklil (Taç / Al-Iklil)',
      arabicName: 'Al-Iklil (الإكليل)',
      signRange: '25°43\' Terazi - 8°34\' Akrep',
      startAbsoluteDegree: 205.714,
      endAbsoluteDegree: 218.571,
      nature: 'Güçlü / Gizemli (Yanık Yol Kuşağı)',
      element: 'Su',
      description: 'Akrep burcunun başı. Gizemli ilimler, derin sezgiler ve sabırla gelen zafer durağıdır.',
      favorableFor: 'Ruhsal arınma, gizli araştırmalar, strateji yapma ve koruyucu zikirler.',
      avoidFor: 'Aceleci kararlar, cerrahi müdahaleler ve borçlanma.',
      hermeticTalisman: 'Gizli güç, sezgisel uyanış ve sabır tacı.',
    ),
    LunarMansionInfo(
      number: 18,
      name: 'El-Kalb (Akrep Kalbi / Antares)',
      arabicName: 'Al-Qalb (القلب)',
      signRange: '8°34\' - 21°26\' Akrep',
      startAbsoluteDegree: 218.571,
      endAbsoluteDegree: 231.428,
      nature: 'Sert / Savaşçı',
      element: 'Ateş',
      description: 'Batı\'nın Kraliyet Yıldızı Antares. Tutku, krizler, savaş sanatı ve ölüm kalım döngüsü.',
      favorableFor: 'Korkularla yüzleşme, ameliyat (zorunlu hallerde), düşmana karşı savunma.',
      avoidFor: 'Evlilik, barış görüşmeleri ve borç para vermek.',
      hermeticTalisman: 'Yenilmezlik, korkusuzluk ve kriz yönetimi.',
    ),
    LunarMansionInfo(
      number: 19,
      name: 'El-Şevle (Akrep İğnesi / Shaula)',
      arabicName: 'Al-Shaulah (الشولة)',
      signRange: '21°26\' Akrep - 4°17\' Yay',
      startAbsoluteDegree: 231.428,
      endAbsoluteDegree: 244.285,
      nature: 'Keskin / Dönüştürücü',
      element: 'Su',
      description: 'Akrep burcunun zehirli kuyruğu. Zehirden panzehir üretme, köklü temizlik ve detoks.',
      favorableFor: 'Zararlı alışkanlıkları bırakma, cerrahi kesiler ve kötü bağları koparma.',
      avoidFor: 'Yeni ortaklık, düğün ve seyahat başlangıcı.',
      hermeticTalisman: 'Şifa bulma, arınma ve zehri panzehire çevirme.',
    ),
    LunarMansionInfo(
      number: 20,
      name: 'El-Neayim (Deve Kuşları)',
      arabicName: 'Al-Na\'am (النعائم)',
      signRange: '4°17\' - 17°09\' Yay',
      startAbsoluteDegree: 244.285,
      endAbsoluteDegree: 257.142,
      nature: 'Çok Uğurlu / Vizyoner',
      element: 'Ateş',
      description: 'Yay burcunun kalbi. Felsefe, uzun seyahatler, maneviyat ve vizyon geliştirme durağıdır.',
      favorableFor: 'Uzak seyahatler, yüksek eğitim, kitap basımı ve ruhsal inziva.',
      avoidFor: 'Dar görüşlü tartışmalar ve küçük hesaplar.',
      hermeticTalisman: 'Vizyon açıklığı, yüksek başarı ve seyahat selameti.',
    ),
    LunarMansionInfo(
      number: 21,
      name: 'El-Belde (Şehir / Kutsal Alan)',
      arabicName: 'Al-Baldah (البلدة)',
      signRange: '17°09\' Yay - 0°00\' Oğlak',
      startAbsoluteDegree: 257.142,
      endAbsoluteDegree: 270.0,
      nature: 'Uğurlu / Yapıcı',
      element: 'Toprak',
      description: 'Kış gündönümü kapısı. Şehirleşme, temel atma, mülk edinme ve sağlam kurallar koyma.',
      favorableFor: 'Gayrimenkul alımı, inşaat başlatma, evlilik ve ortaklık sözleşmesi.',
      avoidFor: 'Kefalet altına girmek.',
      hermeticTalisman: 'Kalıcı mülk, güvenli sığınak ve istikrar.',
    ),
    LunarMansionInfo(
      number: 22,
      name: 'Sa\'d el-Zabih (Kurban Edenin Uğuru)',
      arabicName: 'Sa\'d al-Dhabih (سعد الذابح)',
      signRange: '0°00\' - 12°51\' Oğlak',
      startAbsoluteDegree: 270.0,
      endAbsoluteDegree: 282.857,
      nature: 'Sert / Şifalı Fedakarlık',
      element: 'Toprak',
      description: 'Oğlak burcunun başı. Disiplin, adak, nefis terbiyesi ve şifa ilacı hazırlama durağı.',
      favorableFor: 'Tıbbi tedavi, ilaç hazırlama, köklü disiplin ve borç ödeme.',
      avoidFor: 'Evlilik ve neşeli kutlamalar.',
      hermeticTalisman: 'İlaç şifası, sadakat ve nefis terbiyesi.',
    ),
    LunarMansionInfo(
      number: 23,
      name: 'Sa\'d Bula (Yutanın Uğuru)',
      arabicName: 'Sa\'d Bula (سعد بلع)',
      signRange: '12°51\' - 25°43\' Oğlak',
      startAbsoluteDegree: 282.857,
      endAbsoluteDegree: 295.714,
      nature: 'Değişken / Arındırıcı',
      element: 'Hava',
      description: 'Hastalıkları, kederleri ve negatif enerjileri yutup yok eden kadim duraktır.',
      favorableFor: 'Tutsaklıktan kurtulma, borç tasfiyesi ve beden detoksu.',
      avoidFor: 'Yeni borçlanma ve spekülatif yatırımlar.',
      hermeticTalisman: 'Kederlerin dağılması ve hürriyet.',
    ),
    LunarMansionInfo(
      number: 24,
      name: 'Sa\'d el-Suud (Uğurların En Uğurlusu)',
      arabicName: 'Sa\'d al-Su\'ud (سعد السعود)',
      signRange: '25°43\' Oğlak - 8°34\' Kova',
      startAbsoluteDegree: 295.714,
      endAbsoluteDegree: 308.571,
      nature: 'En Yüce Uğurlu (Sa\'d-ı Ekber)',
      element: 'Hava',
      description: 'Göklerin en bereketli durağı. Talih, refah, beklenmedik lütuflar ve evrensel destek.',
      favorableFor: 'Evlilik, yeni iş kurma, çocuk sahibi olma niyeti, büyük yatırımlar.',
      avoidFor: 'Hastalara hüzünlü ziyarette bulunmak.',
      hermeticTalisman: 'Maksimum şans, ilahi lütuf ve büyük saadet.',
    ),
    LunarMansionInfo(
      number: 25,
      name: 'Sa\'d el-Ahbiye (Çadırların Uğuru)',
      arabicName: 'Sa\'d al-Akhbiyah (سعد الأخبية)',
      signRange: '8°34\' - 21°26\' Kova',
      startAbsoluteDegree: 308.571,
      endAbsoluteDegree: 321.428,
      nature: 'Uğurlu / Keşif',
      element: 'Su',
      description: 'Toprağın altındaki gizli suların, madenlerin ve saklı bilgilerin fışkırdığı durak.',
      favorableFor: 'Su kuyusu açma, keşif yapma, gizli ilimleri öğrenme ve araştırma.',
      avoidFor: 'Gizli hilelere kalkışmak.',
      hermeticTalisman: 'Gizli hazinelerin keşfi ve ilham.',
    ),
    LunarMansionInfo(
      number: 26,
      name: 'El-Ferğ el-Mukaddem (Ön Kova)',
      arabicName: 'Al-Fargh al-Muqaddam (الفرغ المقدم)',
      signRange: '21°26\' Kova - 4°17\' Balık',
      startAbsoluteDegree: 321.428,
      endAbsoluteDegree: 334.285,
      nature: 'Uğurlu / Cömert',
      element: 'Su',
      description: 'Gökten inen rahmet kovası. Cömertlik, dostluk, bağışlama ve manevi arınma.',
      favorableFor: 'Evlilik, hayır işleri yapma, dost barışması ve seyahat.',
      avoidFor: 'Deniz yolculuklarına tedbirsiz çıkmak.',
      hermeticTalisman: 'Manevi rahmet, şefkat ve dostluk bereketi.',
    ),
    LunarMansionInfo(
      number: 27,
      name: 'El-Ferğ el-Muahhar (Arka Kova)',
      arabicName: 'Al-Fargh al-Thani (الفرغ المؤخر)',
      signRange: '4°17\' - 17°09\' Balık',
      startAbsoluteDegree: 334.285,
      endAbsoluteDegree: 347.142,
      nature: 'Orta / Manevi',
      element: 'Su',
      description: 'Balık burcunun kalbi. Rüyalar, hayal gücü, sanatsal ilham ve derin teslimiyet.',
      favorableFor: 'Rüya tabirleri, manevi ibadetler, sanat, balıkçılık ve ticaret.',
      avoidFor: 'Aşırı borçlanma ve gerçeklerden kaçış.',
      hermeticTalisman: 'Sanatsal deha ve rüyalar yoluyla haber alma.',
    ),
    LunarMansionInfo(
      number: 28,
      name: 'El-Rişa (Balığın İpi / Göbek Bağı)',
      arabicName: 'Al-Risha (الرشاء)',
      signRange: '17°09\' Balık - 0°00\' Koç',
      startAbsoluteDegree: 347.142,
      endAbsoluteDegree: 360.0,
      nature: 'Uğurlu / Tamamlayıcı',
      element: 'Su',
      description: 'Zodyak çemberinin son durağı. Döngülerin tamamlanması, barış, kavuşma ve yeniye hazırlık.',
      favorableFor: 'Küslerin barışması, evlilik, deniz ticareti ve arınma ritüelleri.',
      avoidFor: 'Zararlı alışkanlıklara tekrar başlamak.',
      hermeticTalisman: 'Tamamlanma, içsel barış ve hayırlı netice.',
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
    return mansions.last; // 360.0 sınır durumu
  }

  /// Burç adı ve burç içi dereceye (0-30) göre menzili bulur
  static LunarMansionInfo getMansionForSignDegree(String signName, double degreeInSign) {
    final signIndex = _getSignIndex(signName);
    final absoluteDegree = signIndex * 30.0 + degreeInSign;
    return getMansionForDegree(absoluteDegree);
  }

  /// Canlı gökyüzü Ay menzili (Anlık canlı transit Ay boylamına göre)
  static LunarMansionInfo getCurrentMoonMansion([DateTime? dt]) {
    final now = dt ?? DateTime.now();
    final moonLon = SkyTransitsService.calculateMoonLongitude(now);
    return getMansionForDegree(moonLon);
  }

  /// Anlık transit Ay boylamını ve burç içi derecesini döndürür
  static Map<String, dynamic> getCurrentMoonPosition([DateTime? dt]) {
    final now = dt ?? DateTime.now();
    final moonLon = SkyTransitsService.calculateMoonLongitude(now);
    final signIdx = (moonLon / 30.0).floor() % 12;
    final degInSign = moonLon % 30.0;
    final deg = degInSign.floor();
    final min = ((degInSign - deg) * 60).round();
    const signNames = [
      'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
      'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
    ];
    return {
      'absoluteDegree': moonLon,
      'sign': signNames[signIdx],
      'degree': deg,
      'minute': min,
      'formatted': '$deg°${min.toString().padLeft(2, '0')}\' ${signNames[signIdx]}',
      'mansion': getMansionForDegree(moonLon),
    };
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
