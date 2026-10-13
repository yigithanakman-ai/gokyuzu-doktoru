import 'package:flutter/material.dart';
import '../models/birth_chart_model.dart';
import '../../core/constants/app_colors.dart';

class ChakraInfo {
  final int number;
  final String name;
  final String sanskritName;
  final Color color;
  final String rulingPlanets;
  final String signs;
  final String element;
  final String bodyParts;
  final String spiritualMeaning;
  final String deficiencySymptoms;
  final String excessSymptoms;
  final String balancingTips;
  final String crystals;
  final String mantra;
  final String affirmation;

  const ChakraInfo({
    required this.number,
    required this.name,
    required this.sanskritName,
    required this.color,
    required this.rulingPlanets,
    required this.signs,
    required this.element,
    required this.bodyParts,
    required this.spiritualMeaning,
    required this.deficiencySymptoms,
    required this.excessSymptoms,
    required this.balancingTips,
    required this.crystals,
    required this.mantra,
    required this.affirmation,
  });
}

class UserChakraAnalysis {
  final ChakraInfo chakra;
  final String status; // 'Dengeli', 'Güçlü / Aşırı', 'Blokajlı / Düşük'
  final Color statusColor;
  final String personalInsight;

  const UserChakraAnalysis({
    required this.chakra,
    required this.status,
    required this.statusColor,
    required this.personalInsight,
  });
}

class ChakraService {
  static const List<ChakraInfo> chakras = [
    ChakraInfo(
      number: 1,
      name: 'Kök Çakra',
      sanskritName: 'Muladhara (मूलाधार)',
      color: AppColors.savageRed,
      rulingPlanets: 'Satürn & Mars',
      signs: 'Oğlak & Koç',
      element: 'Toprak',
      bodyParts: 'Omurga tabanı, kemikler, dişler, bacaklar, kalın bağırsak, böbrek üstü bezleri.',
      spiritualMeaning: 'Madde dünyasında var olma, fiziksel güvenlik, hayatta kalma içgüdüsü ve topraklanma temeli.',
      deficiencySymptoms: 'Sürekli gelecek kaygısı, finansal kıtlık korkusu, bedenden kopukluk, kronik yorgunluk ve köksüzlük hissi.',
      excessSymptoms: 'Aşırı materyalizm, değişime katı direnç, açgözlülük, tembellik ve güvenlik takıntısı.',
      balancingTips: 'Toprakta çıplak ayakla yürümek, kök sebzeler tüketmek, doğada yürüyüş ve fiziksel egzersiz yapmak.',
      crystals: 'Kırmızı Jasper, Granat, Obsidyen, Dumanlı Kuvars.',
      mantra: 'LAM',
      affirmation: 'Dünyada güvendeyim, bedenimde huzurluyum ve evren tüm ihtiyaçlarımı karşılıyor.',
    ),
    ChakraInfo(
      number: 2,
      name: 'Sakral Çakra',
      sanskritName: 'Svadhisthana (स्वाधिष्ठान)',
      color: AppColors.warningOrange,
      rulingPlanets: 'Venüs, Ay & Plüton',
      signs: 'Boğa, Yengeç & Akrep',
      element: 'Su',
      bodyParts: 'Alt karın, cinsel organlar, böbrekler, mesane, dolaşım sıvıları ve lenfler.',
      spiritualMeaning: 'Duygusal akış, yaratıcılık, haz alma sanatı, tutku ve başkalarıyla kurulan derin bağlar.',
      deficiencySymptoms: 'Duygusal donukluk, suçluluk kompleksi, yaratıcı kısırlık, zevk alamama (anhedoni) ve yakınlık korkusu.',
      excessSymptoms: 'Duygusal bağımlılıklar, kontrolsüz haz arayışı, aşırı dramatik tepkiler ve cinsel takıntılar.',
      balancingTips: 'Su kenarında vakit geçirmek, bol su içmek, dans etmek, yaratıcı sanatlarla uğraşmak ve duyguları bastırmamak.',
      crystals: 'Karnelyan (Akik), Turuncu Kalsit, Aytaşı.',
      mantra: 'VAM',
      affirmation: 'Yaşamın hazzını ve coşkusunu hak ediyorum; duygularım su gibi temiz ve özgür akıyor.',
    ),
    ChakraInfo(
      number: 3,
      name: 'Solar Pleksus Çakrası',
      sanskritName: 'Manipura (मणिपूर)',
      color: AppColors.starlightGold,
      rulingPlanets: 'Güneş & Mars',
      signs: 'Aslan & Koç',
      element: 'Ateş',
      bodyParts: 'Mide, karaciğer, safra kesesi, dalak, sindirim sistemi ve pankreas.',
      spiritualMeaning: 'Kişisel güç, irade, özgüven, eyleme geçme cesareti ve benliğin dış dünyadaki otoritesi.',
      deficiencySymptoms: 'Özgüven eksikliği, kurban psikolojisi, karar verememe, pasiflik ve sindirim/mide rahatsızlıkları.',
      excessSymptoms: 'Kibir, aşırı kontrolcülük, öfke patlamaları, tahammülsüzlük ve mükemmeliyetçilik krizleri.',
      balancingTips: 'Güneş ışığı almak, sarı gıdalar (limon, muz, zencefil) tüketmek, sınır çizmeyi öğrenmek ve kararlı adımlar atmak.',
      crystals: 'Sitrin, Kaplan Gözü, Pirit, Sarı Akik.',
      mantra: 'RAM',
      affirmation: 'Kendi gücümü sevgiyle kabul ediyorum; hayatımın kararlarını güven ve cesaretle alıyorum.',
    ),
    ChakraInfo(
      number: 4,
      name: 'Kalp Çakrası',
      sanskritName: 'Anahata (अनाहत)',
      color: AppColors.pastelMint,
      rulingPlanets: 'Venüs & Güneş',
      signs: 'Terazi, Boğa & Aslan',
      element: 'Hava',
      bodyParts: 'Kalp, göğüs kafesi, akciğerler, timus bezi ve dolaşım sistemi.',
      spiritualMeaning: 'Koşulsuz sevgi, şefkat, affetme, empati ve maddi ile manevi alemler arasındaki köprü.',
      deficiencySymptoms: 'İçine kapanıklık, insanlardan uzaklaşma, affedememe, derin kırgınlıklar ve kendini sevememe.',
      excessSymptoms: 'Kendi sınırlarını unutup başkaları için tükenme, aşırı fedakarlık ve boğucu sahiplenme.',
      balancingTips: 'Doğada yeşillikler içinde nefes egzersizleri, geçmiş kırgınlıkları serbest bırakma ve kalpten teşekkür etme pratiği.',
      crystals: 'Zümrüt, Pembe Kuvars, Yeşim Taşı, Malakit.',
      mantra: 'YAM',
      affirmation: 'Kalbimi sevgiye, şefkate ve affetmeye açıyorum; sevgi almayı ve vermeyi hak ediyorum.',
    ),
    ChakraInfo(
      number: 5,
      name: 'Boğaz Çakrası',
      sanskritName: 'Vishuddha (विशुद्ध)',
      color: AppColors.pastelBlue,
      rulingPlanets: 'Merkür',
      signs: 'İkizler & Başak',
      element: 'Eter / Ses',
      bodyParts: 'Boğaz, tiroid ve paratiroid bezleri, ses telleri, boyun omurları, ağız ve kulaklar.',
      spiritualMeaning: 'Otantik ifade, hakikati dile getirme gücü, dürüst iletişim ve içsel sesin yankısı.',
      deficiencySymptoms: 'Duygularını ve fikirlerini yutkunup söyleyememe, çekingenlik, boğaz düğümlenmesi ve tiroid problemleri.',
      excessSymptoms: 'Sürekli konuşup dinlememe, dedikodu yapma, sert ve kırıcı sözler kullanma.',
      balancingTips: 'Şarkı söylemek, günlük tutmak, sessizlik oruçları, dürüst konuşmak ve nane/okaliptüs çayları tüketmek.',
      crystals: 'Akuamarin, Lapis Lazuli, Sodalit, Mavi Dantelli Akik.',
      mantra: 'HAM',
      affirmation: 'Kendi hakikatimi sevgiyle, dürüstçe ve cesaretle ifade ediyorum; sesim değerlidir.',
    ),
    ChakraInfo(
      number: 6,
      name: 'Üçüncü Göz Çakrası',
      sanskritName: 'Ajna (आज्ञा)',
      color: AppColors.pastelLavender,
      rulingPlanets: 'Jüpiter, Ay & Neptün',
      signs: 'Yay, Balık & Akrep',
      element: 'Işık / Sezgi',
      bodyParts: 'Alın merkezi, iki kaşın arası, hipofiz bezi, gözler ve sinir sisteminin kontrol merkezi.',
      spiritualMeaning: 'Sezgi gücü, içsel bilgelik, durugörü, illüzyonların ötesindeki kozmik gerçeği algılama.',
      deficiencySymptoms: 'Yön kaybı, vizyonsuzluk, sezgilerine güvenememe, aşırı katı rasyonalizm ve baş ağrıları.',
      excessSymptoms: 'Gerçeklikten kopuk hayalperestlik, aşırı kuruntu, sanrılar ve dünyevi sorumlulukları terk etme.',
      balancingTips: 'Meditasyon yapmak, lavanta yağı koklamak, yıldızları izlemek ve rüyaları not etmek.',
      crystals: 'Ametist, Lapis Lazuli, Labradorit, Florit.',
      mantra: 'OM / KSHAM',
      affirmation: 'İçsel sesime ve sezgilerime güveniyorum; evrenin işaretlerini netlikle görüyorum.',
    ),
    ChakraInfo(
      number: 7,
      name: 'Tepe / Taç Çakra',
      sanskritName: 'Sahasrara (सहस्रार)',
      color: Color(0xFFE5D4FF),
      rulingPlanets: 'Uranüs, Neptün & Güneş',
      signs: 'Kova & Balık',
      element: 'Kozmik Zihin / Nur',
      bodyParts: 'Başın tepe noktası, epifiz bezi, beyin korteksi ve tüm sinir sistemi.',
      spiritualMeaning: 'Kozmik birlik bilinci, ilahi kaynakla doğrudan temas, evrensel aşkınlık ve aydınlanma.',
      deficiencySymptoms: 'Ruhsal boşluk, anlamsızlık hissi, varoluşsal depresyon, yalnızlık ve manevi yabancılaşma.',
      excessSymptoms: 'Ruhsal kibir, dünyevi hayatı küçümseme ve kopukluk.',
      balancingTips: 'Sessizlik meditasyonu, dua, tefekkür, temiz havada başı açık gökyüzüne bakmak.',
      crystals: 'Kristal Kuvars, Selenit, Elmas, Ametist.',
      mantra: 'SESSİZLİK / AUM',
      affirmation: 'Evrensel bilinçle birim; ilahi sevginin ve sonsuz ışığın koruması altındayım.',
    ),
  ];

  /// Haritadaki element dağılımı ve gezegen yerleşimlerine göre kişisel çakra analizini üretir
  static List<UserChakraAnalysis> analyzeUserChakras(BirthChartModel chart) {
    final elements = chart.elements;
    final ates = elements['Ateş'] ?? 0;
    final toprak = elements['Toprak'] ?? 0;
    final hava = elements['Hava'] ?? 0;
    final su = elements['Su'] ?? 0;

    return [
      // 1. Kök Çakra (Toprak & Satürn)
      _buildAnalysis(
        chakra: chakras[0],
        elementScore: toprak,
        lowInsight: 'Toprak elementinizin düşük olması, dünyevi köklenme ve finansal güvende hissetme konularında Kök Çakranızda blokaj yaratabilir. Düzenli doğa temasları önerilir.',
        highInsight: 'Toprak elementinizin yüksek olması Kök Çakranızı son derece sağlam kılıyor; maddi disiplininiz ve sabrınız yüksek, ancak değişime esneklik katmalısınız.',
        balancedInsight: 'Kök Çakranız ideal dengede. Maddi hayat ile ruhsal hedefleriniz arasında güvenli bir zemin kurmuş durumdasınız.',
      ),

      // 2. Sakral Çakra (Su & Ay/Venüs)
      _buildAnalysis(
        chakra: chakras[1],
        elementScore: su,
        lowInsight: 'Haritanızda Su elementinin azlığı duygusal akışta kuruluk yaratabilir. Sakral Çakranızı canlandırmak için yaratıcı hobiler ve duyguları paylaşma pratiği yapmalısınız.',
        highInsight: 'Su elementiniz güçlü; Sakral Çakranız oldukça aktif ve tutkulu. Ancak başkalarının duygusal yüklerini emmemeye ve sınır çekmeye dikkat edin.',
        balancedInsight: 'Sakral Çakranız dengeli akıyor. Yaşamdan haz alma, şefkat ve yaratıcılık dengesini doğal bir zarafetle sürdürüyorsunuz.',
      ),

      // 3. Solar Pleksus (Ateş & Güneş/Mars)
      _buildAnalysis(
        chakra: chakras[2],
        elementScore: ates,
        lowInsight: 'Ateş elementinizin azlığı irade ve motivasyon dalgalanmaları yaratabilir. Solar Pleksus çakranızı güneş ışığı ve kararlı hedeflerle güçlendirmelisiniz.',
        highInsight: 'Ateş elementiniz yüksek; Solar Pleksus çakranız alev alev parlıyor! Liderlik ve cesaretiniz müthiş, fakat sabırsızlık ve öfkeye dikkat etmelisiniz.',
        balancedInsight: 'Solar Pleksus çakranız altın oran dengesinde. Özgüveniniz sakin ve güçlü, iradeniz hedeflerinizi gerçekleştirmek için yetkin.',
      ),

      // 4. Kalp Çakrası (Hava & Venüs)
      _buildAnalysis(
        chakra: chakras[3],
        elementScore: hava,
        lowInsight: 'Zihinsel iletişim ve bağ kurmada çekimserlik hissedebilirsiniz. Kalp Çakranızı yeşil taşlar ve affetme meditasyonlarıyla genişletmeniz önerilir.',
        highInsight: 'Hava enerjiniz çok güçlü; sosyal sevgi ve hoşgörünüz geniş. Ancak sevgiyi sadece entelektüel kılmayıp kalpten hissetmeyi unutmayın.',
        balancedInsight: 'Kalp Çakranız dengeli atıyor. Sevgi alıp vermede doğal bir ahenk içindesiniz; şefkatiniz etrafınıza huzur yayıyor.',
      ),

      // 5. Boğaz Çakrası (Merkür & İletişim)
      _buildAnalysis(
        chakra: chakras[4],
        elementScore: hava,
        lowInsight: 'İçinizdekileri tam olarak kelimelere dökmekte zaman zaman zorlanabilirsiniz. Mavi taşlar ve günlük tutmak Boğaz Çakranızı açacaktır.',
        highInsight: 'İfade gücünüz ve sözcük dağarcığınız çok kuvvetli. Boğaz Çakranız çok aktif; sözlerinizin yaratım gücünü yapıcı yönlendirmelisiniz.',
        balancedInsight: 'Boğaz Çakranız dengeli. Hakikati ne eksik ne fazla, tam kararında ve saygıyla ifade edebilme yeteneğine sahipsiniz.',
      ),

      // 6. Üçüncü Göz (Sezgi, Ay & Jüpiter)
      _buildAnalysis(
        chakra: chakras[5],
        elementScore: su,
        lowInsight: 'Rasyonel akıl sezgilerinizin sesini bastırıyor olabilir. Üçüncü Göz Çakranızı meditasyon ve rüyalarınızı kaydederek uyandırabilirsiniz.',
        highInsight: 'Derin durugörü ve güçlü önsezilere sahipsiniz. İçsel rehberiniz çok berrak; gördüğünüz işaretlere güvenebilirsiniz.',
        balancedInsight: 'Üçüncü Göz Çakranız dengeli. Mantık ve sezgiyi mükemmel bir sentezle harmanlayarak doğru kararlar alıyorsunuz.',
      ),

      // 7. Taç Çakra (Kozmik Zihin & İlahi Işık)
      UserChakraAnalysis(
        chakra: chakras[6],
        status: 'Kozmik Uyumda',
        statusColor: const Color(0xFFE5D4FF),
        personalInsight: 'Doğum haritanızdaki ${chart.sunSign} Güneşi ve ${chart.moonSign} Ayı, ruhsal yolculuğunuzda ilahi nura açık bir potansiyel barındırıyor. Tefekkür ve teslimiyet bu bağı daima diri tutacaktır.',
      ),
    ];
  }

  static UserChakraAnalysis _buildAnalysis({
    required ChakraInfo chakra,
    required int elementScore,
    required String lowInsight,
    required String highInsight,
    required String balancedInsight,
  }) {
    if (elementScore < 3) {
      return UserChakraAnalysis(
        chakra: chakra,
        status: 'Blokajlı / Düşük',
        statusColor: AppColors.savageRed,
        personalInsight: lowInsight,
      );
    } else if (elementScore > 5) {
      return UserChakraAnalysis(
        chakra: chakra,
        status: 'Güçlü / Aşırı',
        statusColor: AppColors.warningOrange,
        personalInsight: highInsight,
      );
    } else {
      return UserChakraAnalysis(
        chakra: chakra,
        status: 'Dengeli',
        statusColor: AppColors.pastelMint,
        personalInsight: balancedInsight,
      );
    }
  }
}
