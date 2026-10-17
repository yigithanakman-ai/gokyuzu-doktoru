import 'package:flutter/material.dart';
import 'storage_service.dart';

/// Gökyüzü Doktoru Çoklu Dil (TR, EN, JA) ve Yerelleştirme Servisi
class AppTranslationService {
  static final ValueNotifier<String> currentLangNotifier = ValueNotifier<String>('tr');

  static String get currentLang => currentLangNotifier.value;

  /// Servisi başlatır ve hafızadaki dili yükler
  static Future<void> init() async {
    final savedLang = await StorageService.getLanguage();
    currentLangNotifier.value = (savedLang == 'en' || savedLang == 'ja') ? savedLang : 'tr';
  }

  /// Dili değiştirir, hafızaya kaydeder ve tüm uygulamayı reaktif olarak günceller
  static Future<void> setLanguage(String langCode) async {
    if (langCode != 'tr' && langCode != 'en' && langCode != 'ja') {
      langCode = 'tr';
    }
    currentLangNotifier.value = langCode;
    await StorageService.setLanguage(langCode);
  }

  /// Anahtar veya direkt Türkçe metin üzerinden otomatik çeviri
  static String tr(String keyOrText) {
    final lang = currentLang;
    final clean = keyOrText.trim();
    if (clean.isEmpty) return '';

    // TR ise doğrudan karşılık veya orijinali döndür
    if (lang == 'tr') {
      return _translations['tr']?[clean] ?? _phraseTranslations[clean]?['tr'] ?? keyOrText;
    }

    // 1. Anahtar sözlükte birebir var mı?
    if (_translations.containsKey(lang) && _translations[lang]!.containsKey(clean)) {
      return _translations[lang]![clean]!;
    }

    // 2. Doğrudan Türkçe cümle / etiket tablosunda var mı?
    if (_phraseTranslations.containsKey(clean) && _phraseTranslations[clean]!.containsKey(lang)) {
      return _phraseTranslations[clean]![lang]!;
    }

    // 3. Burç / Gezegen / Element / Nitelik / Cinsiyet / Açı kontrolleri
    if (_signTranslations.containsKey(clean) && _signTranslations[clean]!.containsKey(lang)) {
      return _signTranslations[clean]![lang]!;
    }
    if (_planetTranslations.containsKey(clean) && _planetTranslations[clean]!.containsKey(lang)) {
      return _planetTranslations[clean]![lang]!;
    }
    if (_elementTranslations.containsKey(clean) && _elementTranslations[clean]!.containsKey(lang)) {
      return _elementTranslations[clean]![lang]!;
    }
    if (_qualityTranslations.containsKey(clean) && _qualityTranslations[clean]!.containsKey(lang)) {
      return _qualityTranslations[clean]![lang]!;
    }
    if (_genderTranslations.containsKey(clean) && _genderTranslations[clean]!.containsKey(lang)) {
      return _genderTranslations[clean]![lang]!;
    }

    // 4. Parçalı / bileşik sözcük kontrolü (Akıllı yerelleştirme)
    String result = keyOrText;
    bool modified = false;

    for (final entry in _phraseTranslations.entries) {
      if (entry.key.length > 3 && result.contains(entry.key)) {
        final replacement = entry.value[lang];
        if (replacement != null && replacement.isNotEmpty) {
          result = result.replaceAll(entry.key, replacement);
          modified = true;
        }
      }
    }

    if (modified) return result;

    // 5. Fallback (TR veya orijinal metin)
    return _translations['tr']?[clean] ?? _phraseTranslations[clean]?['tr'] ?? keyOrText;
  }

  /// Burç Adı Çevirisi
  static String signName(String rawSign) {
    final clean = rawSign.trim();
    final lang = currentLang;
    final map = _signTranslations[clean];
    if (map != null && map.containsKey(lang)) {
      return map[lang]!;
    }
    return clean;
  }

  /// Gezegen Adı Çevirisi
  static String planetName(String rawPlanet) {
    final clean = rawPlanet.trim();
    final lang = currentLang;
    final map = _planetTranslations[clean];
    if (map != null && map.containsKey(lang)) {
      return map[lang]!;
    }
    return clean;
  }

  /// Açı Tipi Çevirisi
  static String aspectName(String rawAspect) {
    final clean = rawAspect.trim();
    final lang = currentLang;
    for (final entry in _aspectTranslations.entries) {
      if (clean.contains(entry.key)) {
        return entry.value[lang] ?? clean;
      }
    }
    return clean;
  }

  /// Element Adı Çevirisi
  static String elementName(String rawElement) {
    final clean = rawElement.trim();
    final lang = currentLang;
    final map = _elementTranslations[clean];
    if (map != null && map.containsKey(lang)) {
      return map[lang]!;
    }
    return clean;
  }

  /// Nitelik Adı Çevirisi
  static String qualityName(String rawQuality) {
    final clean = rawQuality.trim();
    final lang = currentLang;
    final map = _qualityTranslations[clean];
    if (map != null && map.containsKey(lang)) {
      return map[lang]!;
    }
    return clean;
  }

  /// Cinsiyet Çevirisi
  static String genderName(String rawGender) {
    final clean = rawGender.trim();
    final lang = currentLang;
    final map = _genderTranslations[clean];
    if (map != null && map.containsKey(lang)) {
      return map[lang]!;
    }
    return clean;
  }

  // --- BURÇ ÇEVİRİ TABLOSU ---
  static const Map<String, Map<String, String>> _signTranslations = {
    'Koç': {'tr': 'Koç', 'en': 'Aries', 'ja': '牡羊座'},
    'Boğa': {'tr': 'Boğa', 'en': 'Taurus', 'ja': '牡牛座'},
    'İkizler': {'tr': 'İkizler', 'en': 'Gemini', 'ja': '双子座'},
    'Yengeç': {'tr': 'Yengeç', 'en': 'Cancer', 'ja': '蟹座'},
    'Aslan': {'tr': 'Aslan', 'en': 'Leo', 'ja': '獅子座'},
    'Başak': {'tr': 'Başak', 'en': 'Virgo', 'ja': '乙女座'},
    'Terazi': {'tr': 'Terazi', 'en': 'Libra', 'ja': '天秤座'},
    'Akrep': {'tr': 'Akrep', 'en': 'Scorpio', 'ja': '蠍座'},
    'Yay': {'tr': 'Yay', 'en': 'Sagittarius', 'ja': '射手座'},
    'Oğlak': {'tr': 'Oğlak', 'en': 'Capricorn', 'ja': '山羊座'},
    'Kova': {'tr': 'Kova', 'en': 'Aquarius', 'ja': '水瓶座'},
    'Balık': {'tr': 'Balık', 'en': 'Pisces', 'ja': '魚座'},
  };

  // --- GEZEGEN VE NOKTA ÇEVİRİ TABLOSU ---
  static const Map<String, Map<String, String>> _planetTranslations = {
    'Güneş': {'tr': 'Güneş', 'en': 'Sun', 'ja': '太陽'},
    'Ay': {'tr': 'Ay', 'en': 'Moon', 'ja': '月'},
    'Merkür': {'tr': 'Merkür', 'en': 'Mercury', 'ja': '水星'},
    'Venüs': {'tr': 'Venüs', 'en': 'Venus', 'ja': '金星'},
    'Mars': {'tr': 'Mars', 'en': 'Mars', 'ja': '火星'},
    'Jüpiter': {'tr': 'Jüpiter', 'en': 'Jupiter', 'ja': '木星'},
    'Satürn': {'tr': 'Satürn', 'en': 'Saturn', 'ja': '土星'},
    'Uranüs': {'tr': 'Uranüs', 'en': 'Uranus', 'ja': '天王星'},
    'Neptün': {'tr': 'Neptün', 'en': 'Neptune', 'ja': '海王星'},
    'Plüton': {'tr': 'Plüton', 'en': 'Pluto', 'ja': '冥王星'},
    'Chiron': {'tr': 'Chiron', 'en': 'Chiron', 'ja': 'カイロン'},
    'Ay Düğümleri': {'tr': 'Ay Düğümleri', 'en': 'Lunar Nodes', 'ja': '月の交点 (ノード)'},
    'Kuzey Ay Düğümü': {'tr': 'Kuzey Ay Düğümü', 'en': 'North Node (Rahu)', 'ja': '北ノード (ラーフ)'},
    'Güney Ay Düğümü': {'tr': 'Güney Ay Düğümü', 'en': 'South Node (Ketu)', 'ja': '南ノード (ケートゥ)'},
    'Yükselen': {'tr': 'Yükselen', 'en': 'Ascendant (ASC)', 'ja': '上昇宮 (ASC)'},
    'ASC': {'tr': 'Yükselen (ASC)', 'en': 'Ascendant (ASC)', 'ja': 'アセンダント (ASC)'},
    'MC': {'tr': 'Tepe Noktası (MC)', 'en': 'Midheaven (MC)', 'ja': '天頂 (MC)'},
    'DSC': {'tr': 'Alçalan (DSC)', 'en': 'Descendant (DSC)', 'ja': 'ディセンダント (DSC)'},
    'IC': {'tr': 'Dip Noktası (IC)', 'en': 'Imum Coeli (IC)', 'ja': '天底 (IC)'},
  };

  // --- ELEMENT ÇEVİRİ TABLOSU ---
  static const Map<String, Map<String, String>> _elementTranslations = {
    'Ateş': {'tr': 'Ateş', 'en': 'Fire', 'ja': '火'},
    'Toprak': {'tr': 'Toprak', 'en': 'Earth', 'ja': '地'},
    'Hava': {'tr': 'Hava', 'en': 'Air', 'ja': '風'},
    'Su': {'tr': 'Su', 'en': 'Water', 'ja': '水'},
  };

  // --- NİTELİK ÇEVİRİ TABLOSU ---
  static const Map<String, Map<String, String>> _qualityTranslations = {
    'Öncü': {'tr': 'Öncü', 'en': 'Cardinal', 'ja': '活動宮'},
    'Sabit': {'tr': 'Sabit', 'en': 'Fixed', 'ja': '不動宮'},
    'Değişken': {'tr': 'Değişken', 'en': 'Mutable', 'ja': '柔軟宮'},
  };

  // --- CİNSİYET ÇEVİRİ TABLOSU ---
  static const Map<String, Map<String, String>> _genderTranslations = {
    'Erkek': {'tr': 'Erkek', 'en': 'Male', 'ja': '男性'},
    'Kadın': {'tr': 'Kadın', 'en': 'Female', 'ja': '女性'},
    'Diğer': {'tr': 'Diğer', 'en': 'Other', 'ja': 'その他'},
  };

  // --- AÇI ÇEVİRİ TABLOSU ---
  static const Map<String, Map<String, String>> _aspectTranslations = {
    'Kavuşum': {'tr': 'Kavuşum (0°)', 'en': 'Conjunction (0°)', 'ja': '合 (0°)'},
    'Sekstil': {'tr': 'Sekstil (60°)', 'en': 'Sextile (60°)', 'ja': '六分 (60°)'},
    'Kare': {'tr': 'Kare (90°)', 'en': 'Square (90°)', 'ja': '矩 (90°)'},
    'Üçgen': {'tr': 'Üçgen (120°)', 'en': 'Trine (120°)', 'ja': '三分 (120°)'},
    'Karşıt': {'tr': 'Karşıt (180°)', 'en': 'Opposition (180°)', 'ja': '衝 (180°)'},
  };

  // --- DOĞRUDAN TÜRKÇE CÜMLE / ETİKET TABLOSU (Her Yerde Kusursuz Çalışır) ---
  static const Map<String, Map<String, String>> _phraseTranslations = {
    'GÖKYÜZÜ DOKTORU': {
      'tr': 'GÖKYÜZÜ DOKTORU',
      'en': 'SKY DOCTOR',
      'ja': '天空のドクター',
    },
    'KOZMİK DOKTOR': {
      'tr': 'KOZMİK DOKTOR',
      'en': 'COSMIC DOCTOR',
      'ja': 'コズミック・ドクター',
    },
    'Kozmik Doğum Haritası ve Gökyüzü Portalı': {
      'tr': 'Kozmik Doğum Haritası ve Gökyüzü Portalı',
      'en': 'Cosmic Natal Chart & Celestial Portal',
      'ja': '出生図解析と宇宙ポータル',
    },
    'Giriş Yap': {
      'tr': 'Giriş Yap',
      'en': 'Sign In',
      'ja': 'ログイン',
    },
    'Yeni Üye Ol': {
      'tr': 'Yeni Üye Ol',
      'en': 'Register',
      'ja': '新規登録',
    },
    'Ad *': {
      'tr': 'Ad *',
      'en': 'First Name *',
      'ja': '名 *',
    },
    'Soyad *': {
      'tr': 'Soyad *',
      'en': 'Last Name *',
      'ja': '姓 *',
    },
    'E-posta Adresi *': {
      'tr': 'E-posta Adresi *',
      'en': 'Email Address *',
      'ja': 'メールアドレス *',
    },
    'Şifre Belirleyin *': {
      'tr': 'Şifre Belirleyin *',
      'en': 'Create Password *',
      'ja': 'パスワード設定 *',
    },
    'Şifre *': {
      'tr': 'Şifre *',
      'en': 'Password *',
      'ja': 'パスワード *',
    },
    'Cinsiyet *': {
      'tr': 'Cinsiyet *',
      'en': 'Gender *',
      'ja': '性別 *',
    },
    'Erkek': {
      'tr': 'Erkek',
      'en': 'Male',
      'ja': '男性',
    },
    'Kadın': {
      'tr': 'Kadın',
      'en': 'Female',
      'ja': '女性',
    },
    'Diğer': {
      'tr': 'Diğer',
      'en': 'Other',
      'ja': 'その他',
    },
    'Hesap Oluştur & Haritaya Başla': {
      'tr': 'Hesap Oluştur & Haritaya Başla',
      'en': 'Create Account & Begin Chart',
      'ja': 'アカウントを作成して開始',
    },
    'Misafir Olarak Haritaya Devam Et →': {
      'tr': 'Misafir Olarak Haritaya Devam Et →',
      'en': 'Continue as Guest →',
      'ja': 'ゲストとして続ける →',
    },
    'Tüm Yasal Metinler': {
      'tr': 'Tüm Yasal Metinler',
      'en': 'All Legal Terms',
      'ja': '全法的文書',
    },
    'Gizlilik': {
      'tr': 'Gizlilik',
      'en': 'Privacy',
      'ja': 'プライバシー',
    },
    'KVKK': {
      'tr': 'KVKK',
      'en': 'Data Protection',
      'ja': '個人情報保護',
    },
    'Kullanım Koşulları': {
      'tr': 'Kullanım Koşulları',
      'en': 'Terms of Use',
      'ja': '利用規約',
    },
    'Mesafeli Satış & İade': {
      'tr': 'Mesafeli Satış & İade',
      'en': 'Sales & Refund',
      'ja': '特定商取引・返品',
    },
    'Sorumluluk Reddi': {
      'tr': 'Sorumluluk Reddi',
      'en': 'Disclaimer',
      'ja': '免責事項',
    },
    'Astrolojik içerikler öz farkındalık ve eğlence amaçlıdır; tıbbi, psikolojik, finansal veya hukuki danışmanlık yerine geçmez.': {
      'tr': 'Astrolojik içerikler öz farkındalık ve eğlence amaçlıdır; tıbbi, psikolojik, finansal veya hukuki danışmanlık yerine geçmez.',
      'en': 'Astrological content is for self-awareness and entertainment purposes; it is not a substitute for medical, psychological, financial, or legal advice.',
      'ja': '占星術コンテンツは自己理解およびエンターテインメントを目的としており、医療、心理療法、金融、法的な専門的助言に代わるものではありません。',
    },
    '6698 sayılı ': {
      'tr': '6698 sayılı ',
      'en': '',
      'ja': '',
    },
    'KVKK Aydınlatma Metni': {
      'tr': 'KVKK Aydınlatma Metni',
      'en': 'Privacy & Consent Agreement',
      'ja': '個人情報保護方針',
    },
    ' ve ': {
      'tr': ' ve ',
      'en': ' and ',
      'ja': 'および',
    },
    'Kullanıcı Sözleşmesi': {
      'tr': 'Kullanıcı Sözleşmesi',
      'en': 'Terms of Service',
      'ja': '利用規約',
    },
    '\'ni okudum, anladım ve kabul ediyorum. *': {
      'tr': '\'ni okudum, anladım ve kabul ediyorum. *',
      'en': ', I have read, understood, and accept. *',
      'ja': 'を読み、同意します。*',
    },
    'Kişisel verileriniz ve astrolojik profil bilgileriniz cihazınızda güvenle işlenir.': {
      'tr': 'Kişisel verileriniz ve astrolojik profil bilgileriniz cihazınızda güvenle işlenir.',
      'en': 'Your personal data and astrological profile are processed securely on your device.',
      'ja': 'お客様の個人データと星読みプロファイルは端末内で安全に処理されます。',
    },
    '⚠️ Yasal Onay Zorunludur: İçeriye giriş yapabilmek için lütfen KVKK Aydınlatma Metni ve Kullanıcı Sözleşmesi\'ni okuyup onay kutucuğunu (tik) işaretleyiniz.': {
      'tr': '⚠️ Yasal Onay Zorunludur: İçeriye giriş yapabilmek için lütfen KVKK Aydınlatma Metni ve Kullanıcı Sözleşmesi\'ni okuyup onay kutucuğunu (tik) işaretleyiniz.',
      'en': '⚠️ Legal Consent Required: Please review and check the agreement box before proceeding.',
      'ja': '⚠️ 同意が必要です: 続行するには利用規約とプライバシーポリシーのチェックボックスにチェックを入れてください。',
    },
    'Lütfen tüm alanları eksiksiz doldurunuz.': {
      'tr': 'Lütfen tüm alanları eksiksiz doldurunuz.',
      'en': 'Please fill in all required fields.',
      'ja': 'すべての必須項目を入力してください。',
    },
    'Lütfen geçerli bir e-posta adresi giriniz (örnek: ad@soyad.com). @ işareti ve geçerli alan adı zorunludur.': {
      'tr': 'Lütfen geçerli bir e-posta adresi giriniz (örnek: ad@soyad.com). @ işareti ve geçerli alan adı zorunludur.',
      'en': 'Please enter a valid email address (e.g. name@domain.com).',
      'ja': '有効なメールアドレスを入力してください (例: name@domain.com)。',
    },
    'Lütfen e-posta ve şifrenizi giriniz.': {
      'tr': 'Lütfen e-posta ve şifrenizi giriniz.',
      'en': 'Please enter your email and password.',
      'ja': 'メールアドレスとパスワードを入力してください。',
    },
    'Lütfen devam etmeden önce Kullanım Sözleşmesi ve KVKK onay kutucuğunu işaretleyin.': {
      'tr': 'Lütfen devam etmeden önce Kullanım Sözleşmesi ve KVKK onay kutucuğunu işaretleyin.',
      'en': 'Please check the agreement box before continuing.',
      'ja': '続行する前に利用規約とプライバシーポリシーの同意チェックボックスをチェックしてください。',
    },
    'Doğum Haritanızı Çıkarın': {
      'tr': 'Doğum Haritanızı Çıkarın',
      'en': 'Create Your Natal Chart',
      'ja': '出生図 (ホロスコープ) を作成',
    },
    'Kozmik parmak izinizi oluşturmak için lütfen doğum bilgilerinizi giriniz.': {
      'tr': 'Kozmik parmak izinizi oluşturmak için lütfen doğum bilgilerinizi giriniz.',
      'en': 'Please enter your birth details to generate your cosmic fingerprint.',
      'ja': '出生情報を入力して、あなたの宇宙の青写真を作成してください。',
    },
    'Adınız *': {
      'tr': 'Adınız *',
      'en': 'Your Name *',
      'ja': 'お名前 *',
    },
    'Doğum Tarihi *': {
      'tr': 'Doğum Tarihi *',
      'en': 'Birth Date *',
      'ja': '生年月日 *',
    },
    'Doğum Saati *': {
      'tr': 'Doğum Saati *',
      'en': 'Birth Time *',
      'ja': '出生時刻 *',
    },
    'Doğum Saati Bilinmiyor (Öğle 12:00 Alınır)': {
      'tr': 'Doğum Saati Bilinmiyor (Öğle 12:00 Alınır)',
      'en': 'Unknown Birth Time (Default 12:00 PM)',
      'ja': '出生時刻不明 (正午12:00として計算)',
    },
    'Ülke *': {
      'tr': 'Ülke *',
      'en': 'Country *',
      'ja': '国 *',
    },
    'Doğum Yeri (Şehir) *': {
      'tr': 'Doğum Yeri (Şehir) *',
      'en': 'Birth City *',
      'ja': '出生地 (都市) *',
    },
    'Kozmik Haritamı Hesapla': {
      'tr': 'Kozmik Haritamı Hesapla',
      'en': 'Calculate My Cosmic Chart',
      'ja': '出生図を計算する',
    },
    'Lütfen adınızı giriniz': {
      'tr': 'Lütfen adınızı giriniz',
      'en': 'Please enter your name',
      'ja': 'お名前を入力してください',
    },
    'Lütfen doğum tarihinizi seçiniz': {
      'tr': 'Lütfen doğum tarihinizi seçiniz',
      'en': 'Please select your birth date',
      'ja': '生年月日を選択してください',
    },
    'Lütfen doğum yerinizi seçiniz': {
      'tr': 'Lütfen doğum yerinizi seçiniz',
      'en': 'Please select your birth place',
      'ja': '出生地を選択してください',
    },
    'Şehir ara... (örn: İstanbul, İzmir, Berlin, Tokyo)': {
      'tr': 'Şehir ara... (örn: İstanbul, İzmir, Berlin, Tokyo)',
      'en': 'Search city... (e.g. London, New York, Tokyo)',
      'ja': '都市を検索... (例: 東京, 大阪, ロンドン)',
    },
    'VIP Profil & Üyelik': {
      'tr': 'VIP Profil & Üyelik',
      'en': 'VIP Profile & Membership',
      'ja': 'VIPプロフィール＆会員',
    },
    'Profil & Giriş / Kayıt': {
      'tr': 'Profil & Giriş / Kayıt',
      'en': 'Profile & Sign In',
      'ja': 'プロフィール・ログイン',
    },
    'Harita Arşivi': {
      'tr': 'Harita Arşivi',
      'en': 'Chart Archive',
      'ja': '保存した出生図',
    },
    'Kayıtlılar': {
      'tr': 'Kayıtlılar',
      'en': 'Saved Charts',
      'ja': '保存一覧',
    },
    'Doğum Günü': {
      'tr': 'Doğum Günü',
      'en': 'Birthday',
      'ja': '誕生日',
    },
    'Hatırlatıcı': {
      'tr': 'Hatırlatıcı',
      'en': 'Reminder',
      'ja': 'リマインダー',
    },
    'Profili Sıfırla': {
      'tr': 'Profili Sıfırla',
      'en': 'Reset Profile',
      'ja': 'プロファイルをリセット',
    },
    'Yeni Harita': {
      'tr': 'Yeni Harita',
      'en': 'New Chart',
      'ja': '新規作成',
    },
    'GÜNÜN KOZMİK YORUMU': {
      'tr': 'GÜNÜN KOZMİK YORUMU',
      'en': 'DAILY COSMIC INSIGHT',
      'ja': '本日の星読みインサイト',
    },
    'Günün Enerjisi': {
      'tr': 'Günün Enerjisi',
      'en': 'Daily Cosmic Energy',
      'ja': '本日のエネルギー',
    },
    'Tam Doğum Haritası': {
      'tr': 'Tam Doğum Haritası',
      'en': 'Full Natal Chart',
      'ja': '詳細な出生図',
    },
    '12 Ev, Gezegen Dereceleri, Elementler': {
      'tr': '12 Ev, Gezegen Dereceleri, Elementler',
      'en': '12 Houses, Planetary Degrees, Elements',
      'ja': '12ハウス、惑星度数、エレメント',
    },
    'VIP Kozmik Danışmanlık': {
      'tr': 'VIP Kozmik Danışmanlık',
      'en': 'VIP Cosmic Consultation',
      'ja': '専属星読みコンサル',
    },
    'AÇIK 👑': {
      'tr': 'AÇIK 👑',
      'en': 'UNLOCKED 👑',
      'ja': '利用可能 👑',
    },
    'VIP ÖZEL 🔒': {
      'tr': 'VIP ÖZEL 🔒',
      'en': 'VIP ONLY 🔒',
      'ja': 'VIP限定 🔒',
    },
    'Sinastri, Solar Return ve Özel Raporlar': {
      'tr': 'Sinastri, Solar Return ve Özel Raporlar',
      'en': 'Synastry, Solar Return & Custom Reports',
      'ja': 'シナストリー、ソーラーリターン、特別鑑定',
    },
    'Kozmik Numeroloji Matrisi': {
      'tr': 'Kozmik Numeroloji Matrisi',
      'en': 'Cosmic Numerology Matrix',
      'ja': '数秘術マトリックス',
    },
    'HERKESE AÇIK ✨': {
      'tr': 'HERKESE AÇIK ✨',
      'en': 'FREE ACCESS ✨',
      'ja': '無料公開 ✨',
    },
    'Yaşam Yolu, Kader Sayısı ve 2026 Döngüsü': {
      'tr': 'Yaşam Yolu, Kader Sayısı ve 2026 Döngüsü',
      'en': 'Life Path, Destiny Number & Cycles',
      'ja': 'ライフパスナンバー、運命数、運気サイクル',
    },
    'YİĞİTHAN AKMAN İLE İLETİŞİM': {
      'tr': 'YİĞİTHAN AKMAN İLE İLETİŞİM',
      'en': 'CONNECT WITH YİĞİTHAN AKMAN',
      'ja': '開発者 Yiğithan Akman に問い合わせ',
    },
    'Paylaş 📤': {
      'tr': 'Paylaş 📤',
      'en': 'Share 📤',
      'ja': '共有 📤',
    },
    'Açılar & Etkileşimler': {
      'tr': 'Açılar & Etkileşimler',
      'en': 'Aspects & Interactions',
      'ja': 'アスペクトと相互作用',
    },
    'Tutulmalar & Saros Döngüleri': {
      'tr': 'Tutulmalar & Saros Döngüleri',
      'en': 'Eclipses & Saros Cycles',
      'ja': '日食・月食とサロス周期',
    },
    'ASTRO BÜLTEN': {
      'tr': 'ASTRO BÜLTEN',
      'en': 'ASTRO BULLETIN',
      'ja': '天文速報',
    },
    'Burç Yorumları': {
      'tr': 'Burç Yorumları',
      'en': 'Zodiac Horoscopes',
      'ja': '星座別星読み',
    },
    'Ayın Gökyüzü Olayları': {
      'tr': 'Ayın Gökyüzü Olayları',
      'en': 'Monthly Celestial Events',
      'ja': '今月の天文現象',
    },
    'Haftalık Kozmik Özet': {
      'tr': 'Haftalık Kozmik Özet',
      'en': 'Weekly Cosmic Summary',
      'ja': '週間星読みサマリー',
    },
    'Gündüz Haritası': {
      'tr': 'Gündüz Haritası',
      'en': 'Day Chart (Diurnal)',
      'ja': '昼のチャート',
    },
    'Gece Haritası': {
      'tr': 'Gece Haritası',
      'en': 'Night Chart (Nocturnal)',
      'ja': '夜のチャート',
    },
    'Placidus Ev Sistemi': {
      'tr': 'Placidus Ev Sistemi',
      'en': 'Placidus House System',
      'ja': 'プラシーダスハウスシステム',
    },
    'Profili Sıfırla?': {
      'tr': 'Profili Sıfırla?',
      'en': 'Reset Profile?',
      'ja': 'プロファイルを初期化しますか？',
    },
    'Mevcut doğum haritanız ve kaydedilen profil bilgileriniz silinecektir. Devam etmek istiyor musunuz?': {
      'tr': 'Mevcut doğum haritanız ve kaydedilen profil bilgileriniz silinecektir. Devam etmek istiyor musunuz?',
      'en': 'Your current birth chart and saved profile data will be cleared. Do you want to continue?',
      'ja': '現在の出生図と保存されたプロファイル情報が初期化されます。続行しますか？',
    },
    'İptal': {
      'tr': 'İptal',
      'en': 'Cancel',
      'ja': 'キャンセル',
    },
    'Sıfırla': {
      'tr': 'Sıfırla',
      'en': 'Reset',
      'ja': 'リセット',
    },
    'Gökyüzü Bildirimleri': {
      'tr': 'Gökyüzü Bildirimleri',
      'en': 'Sky Notifications',
      'ja': '天体通知',
    },
    'Profil & Üyelik İşlemleri': {
      'tr': 'Profil & Üyelik İşlemleri',
      'en': 'Profile & Membership',
      'ja': 'プロフィール・会員管理',
    },
    'Kozmik Notlar': {
      'tr': 'Kozmik Notlar',
      'en': 'Cosmic Notes',
      'ja': 'コズミックメモ',
    },
    'Sert Gerçekler': {
      'tr': 'Sert Gerçekler',
      'en': 'Brutal Truths',
      'ja': '星の真実',
    },
    'Numeroloji': {
      'tr': 'Numeroloji',
      'en': 'Numerology',
      'ja': '数秘術',
    },
    'Hızlı Erişim Portalı': {
      'tr': 'Hızlı Erişim Portalı',
      'en': 'Quick Access Portal',
      'ja': 'クイックアクセス',
    },
    'Gezegen Konumları': {
      'tr': 'Gezegen Konumları',
      'en': 'Planetary Positions',
      'ja': '惑星の配置',
    },
    'Ev Dağılımı': {
      'tr': 'Ev Dağılımı',
      'en': 'House Distribution',
      'ja': 'ハウス配分',
    },
    'Element Dengesi': {
      'tr': 'Element Dengesi',
      'en': 'Elemental Balance',
      'ja': 'エレメントバランス',
    },
    'Nitelik Dağılımı': {
      'tr': 'Nitelik Dağılımı',
      'en': 'Qualities Distribution',
      'ja': 'クオリティ配分',
    },
    'Açılar Kılavuzu': {
      'tr': 'Açılar Kılavuzu',
      'en': 'Aspects Guide',
      'ja': 'アスペクト解説ガイド',
    },
    'Yalnızca Doğum Haritası Açılarım': {
      'tr': 'Yalnızca Doğum Haritası Açılarım',
      'en': 'Natal Aspects Only',
      'ja': 'ネイタル出生図のアスペクトのみ',
    },
    'Doğum Haritası + Canlı Transit Açılar': {
      'tr': 'Doğum Haritası + Canlı Transit Açılar',
      'en': 'Natal + Live Transit Aspects',
      'ja': '出生図 ＋ 現在のトランジット連携',
    },
    'Açılar Matrisi & Etkileşimler': {
      'tr': 'Açılar Matrisi & Etkileşimler',
      'en': 'Aspects Matrix & Interactions',
      'ja': 'アスペクト行列・相互作用',
    },
    'Açılar Kılavuzu (Majör & Minör)': {
      'tr': 'Açılar Kılavuzu (Majör & Minör)',
      'en': 'Aspects Guide (Major & Minor)',
      'ja': 'アスペクト解説ガイド (メジャー＆マイナー)',
    },
    'Yalnızca Natal Açılar': {
      'tr': 'Yalnızca Natal Açılar',
      'en': 'Natal Aspects Only',
      'ja': 'ネイタルアスペクトのみ',
    },
    'Natal + Transit Açılar': {
      'tr': 'Natal + Transit Açılar',
      'en': 'Natal + Transit Aspects',
      'ja': 'ネイタル＋トランジット',
    },
    'Açı Izgarası': {
      'tr': 'Açı Izgarası',
      'en': 'Aspect Grid',
      'ja': 'アスペクトグリッド',
    },
    'Açı Listesi': {
      'tr': 'Açı Listesi',
      'en': 'Aspect List',
      'ja': 'アスペクト一覧',
    },
    'Evler & Liste': {
      'tr': 'Evler & Liste',
      'en': 'Houses & List',
      'ja': 'ハウス＆一覧',
    },
    '360° Çark': {
      'tr': '360° Çark',
      'en': '360° Wheel',
      'ja': '360度ホイール',
    },
    'Sabit Yıldız 👑': {
      'tr': 'Sabit Yıldız 👑',
      'en': 'Fixed Stars 👑',
      'ja': '恒星 👑',
    },
    'Dekan & Melek 👑': {
      'tr': 'Dekan & Melek 👑',
      'en': 'Decans & Angels 👑',
      'ja': 'デカン＆天使 👑',
    },
    'Çakra & Beden ✨': {
      'tr': 'Çakra & Beden ✨',
      'en': 'Chakras & Body ✨',
      'ja': 'チャクラ＆身体 ✨',
    },
    'Doğal Taşlar 💎': {
      'tr': 'Doğal Taşlar 💎',
      'en': 'Healing Crystals 💎',
      'ja': 'パワーストーン 💎',
    },
    'Kabala Ağacı 👑': {
      'tr': 'Kabala Ağacı 👑',
      'en': 'Kabbalah Tree 👑',
      'ja': '生命の樹 👑',
    },
    'Tutulmalar & Saros 🌑': {
      'tr': 'Tutulmalar & Saros 🌑',
      'en': 'Eclipses & Saros 🌑',
      'ja': '食＆サロス周期 🌑',
    },
    'DOĞUM HARİTASI': {
      'tr': 'DOĞUM HARİTASI',
      'en': 'NATAL CHART',
      'ja': '出生図 (ホロスコープ)',
    },
    'ELEMENT DENGESİ': {
      'tr': 'ELEMENT DENGESİ',
      'en': 'ELEMENTAL BALANCE',
      'ja': 'エレメントバランス',
    },
    'Dengeleme için dokun': {
      'tr': 'Dengeleme için dokun',
      'en': 'Tap to balance',
      'ja': 'タップして調和',
    },
    'Hesap & Üyelik Bilgileri': {
      'tr': 'Hesap & Üyelik Bilgileri',
      'en': 'Account & Membership Info',
      'ja': 'アカウント＆会員情報',
    },
    'Kullanıcı:': {
      'tr': 'Kullanıcı:',
      'en': 'User:',
      'ja': 'ユーザー:',
    },
    'E-Posta:': {
      'tr': 'E-Posta:',
      'en': 'Email:',
      'ja': 'メール:',
    },
    'Doğum Yeri & Tarihi:': {
      'tr': 'Doğum Yeri & Tarihi:',
      'en': 'Birth Place & Date:',
      'ja': '出生地・生年月日:',
    },
    'VIP Ayrıcalıklı Statü Aktif': {
      'tr': 'VIP Ayrıcalıklı Statü Aktif',
      'en': 'VIP Exclusive Status Active',
      'ja': 'VIP会員ステータス有効',
    },
    'Standart Kullanıcı': {
      'tr': 'Standart Kullanıcı',
      'en': 'Standard User',
      'ja': '一般ユーザー',
    },
    'Standart Mod (Test)': {
      'tr': 'Standart Mod (Test)',
      'en': 'Standard Mode (Test)',
      'ja': '標準モード (テスト)',
    },
    'İstek & Öneri Bildirimi': {
      'tr': 'İstek & Öneri Bildirimi',
      'en': 'Feedback & Feature Request',
      'ja': 'ご意見・ご要望',
    },
    'İstek veya Öneri Bildir': {
      'tr': 'İstek veya Öneri Bildir',
      'en': 'Submit Feedback / Request',
      'ja': 'ご意見・ご要望を送信',
    },
    'Yasal Prosedürler & Aydınlatma': {
      'tr': 'Yasal Prosedürler & Aydınlatma',
      'en': 'Legal & Compliance',
      'ja': '法的開示と規約',
    },
    'Hesabı & Tüm Verileri Kalıcı Olarak Sil': {
      'tr': 'Hesabı & Tüm Verileri Kalıcı Olarak Sil',
      'en': 'Permanently Delete Account & Data',
      'ja': 'アカウントとデータを完全に削除',
    },
    'Hesabımı ve Verilerimi Kalıcı Olarak Sil': {
      'tr': 'Hesabımı ve Verilerimi Kalıcı Olarak Sil',
      'en': 'Permanently Delete My Account & Data',
      'ja': 'アカウントと全データを完全に削除する',
    },
    'Gizlilik Politikası': {
      'tr': 'Gizlilik Politikası',
      'en': 'Privacy Policy',
      'ja': 'プライバシーポリシー',
    },
    'Kullanım Koşulları & Sözleşme': {
      'tr': 'Kullanım Koşulları & Sözleşme',
      'en': 'Terms of Use & Agreement',
      'ja': '利用規約',
    },
    'Reklam & Çerez Politikası': {
      'tr': 'Reklam & Çerez Politikası',
      'en': 'Advertising & Cookie Policy',
      'ja': '広告・クッキーポリシー',
    },
    'Mesafeli Satış & İptal İade': {
      'tr': 'Mesafeli Satış & İptal İade',
      'en': 'Sales & Cancellation Policy',
      'ja': '特定商取引・解約ポリシー',
    },
    'Yasal Sorumluluk Reddi (Disclaimer)': {
      'tr': 'Yasal Sorumluluk Reddi (Disclaimer)',
      'en': 'Legal Disclaimer',
      'ja': '免責事項',
    },
    'Hesabı Kalıcı Olarak Sil?': {
      'tr': 'Hesabı Kalıcı Olarak Sil?',
      'en': 'Permanently Delete Account?',
      'ja': 'アカウントを完全に削除しますか？',
    },
    'Vazgeç': {
      'tr': 'Vazgeç',
      'en': 'Cancel',
      'ja': 'キャンセル',
    },
    'Evet, Kalıcı Olarak Sil': {
      'tr': 'Evet, Kalıcı Olarak Sil',
      'en': 'Yes, Permanently Delete',
      'ja': 'はい、完全に削除します',
    },
    'Günlük Kozmik Bildirimler': {
      'tr': 'Günlük Kozmik Bildirimler',
      'en': 'Daily Cosmic Notifications',
      'ja': '日々の天体通知',
    },
    'DERİN İNCELEME & ANALİZ': {
      'tr': 'DERİN İNCELEME & ANALİZ',
      'en': 'DEEP DIVE & ANALYSIS',
      'ja': '詳細分析＆鑑定',
    },
    'Bildirim Kategorisi:': {
      'tr': 'Bildirim Kategorisi:',
      'en': 'Feedback Category:',
      'ja': 'カテゴリー:',
    },
    'Öneri / Tavsiye': {
      'tr': 'Öneri / Tavsiye',
      'en': 'Suggestion / Advice',
      'ja': '提案・アドバイス',
    },
    'Yeni Özellik Talebi': {
      'tr': 'Yeni Özellik Talebi',
      'en': 'Feature Request',
      'ja': '新機能リクエスト',
    },
    'Astroloji Analiz Talebi': {
      'tr': 'Astroloji Analiz Talebi',
      'en': 'Astrology Analysis Request',
      'ja': '鑑定・分析リクエスト',
    },
    'Hata Bildirimi': {
      'tr': 'Hata Bildirimi',
      'en': 'Bug Report',
      'ja': 'バグ報告',
    },
    'Genel Görüş': {
      'tr': 'Genel Görüş',
      'en': 'General Feedback',
      'ja': 'ご意見・ご感想',
    },
    'İsteği / Öneriyi İlet': {
      'tr': 'İsteği / Öneriyi İlet',
      'en': 'Submit Feedback',
      'ja': '送信する',
    },
    'Gönderilen Bildirimleriniz:': {
      'tr': 'Gönderilen Bildirimleriniz:',
      'en': 'Your Submitted Requests:',
      'ja': '送信済みのリクエスト:',
    },
    'İnceleniyor': {
      'tr': 'İnceleniyor',
      'en': 'Under Review',
      'ja': '確認中',
    },
    'Öneri': {
      'tr': 'Öneri',
      'en': 'Suggestion',
      'ja': 'ご提案',
    },
    'STANDART': {
      'tr': 'STANDART',
      'en': 'STANDARD',
      'ja': '通常',
    },
    'VIP ÜYE': {
      'tr': 'VIP ÜYE',
      'en': 'VIP MEMBER',
      'ja': 'VIP会員',
    },
    'Sevgili': {
      'tr': 'Sevgili',
      'en': 'Dear',
      'ja': '親愛なる',
    },
    'HARİTA ÇÖZÜMLEMESİ': {
      'tr': 'HARİTA ÇÖZÜMLEMESİ',
      'en': 'NATAL CHART ANALYSIS',
      'ja': '出生図解析',
    },
    'Kişisel Farkındalık &\nTemel Harita Dinamikleri': {
      'tr': 'Kişisel Farkındalık &\nTemel Harita Dinamikleri',
      'en': 'Personal Awareness &\nCore Chart Dynamics',
      'ja': '自己認識と\n基本出生図ダイナミクス',
    },
    'Doğum haritanızdaki akslar ve yerleşimlerin ortaya koyduğu 3 kilit psikolojik gerçeklik.': {
      'tr': 'Doğum haritanızdaki akslar ve yerleşimlerin ortaya koyduğu 3 kilit psikolojik gerçeklik.',
      'en': '3 key psychological realities revealed by the axes and placements in your birth chart.',
      'ja': '出生図の軸と配置が明らかにする3つの主要な心理的真実。',
    },
    'Önceki Kart': {
      'tr': 'Önceki Kart',
      'en': 'Previous Card',
      'ja': '前のカード',
    },
    'Sonraki Kart': {
      'tr': 'Sonraki Kart',
      'en': 'Next Card',
      'ja': '次のカード',
    },
    'Sonraki Gerçeğe Geç ➔': {
      'tr': 'Sonraki Gerçeğe Geç ➔',
      'en': 'Next Insight ➔',
      'ja': '次の真実へ ➔',
    },
    'Kozmik Panele Geç ✨': {
      'tr': 'Kozmik Panele Geç ✨',
      'en': 'Enter Cosmic Dashboard ✨',
      'ja': 'コズミックパネルへ ✨',
    },
    'Psikolojik Kör Noktan': {
      'tr': 'Psikolojik Kör Noktan',
      'en': 'Psychological Blind Spot',
      'ja': '心理的盲点',
    },
    'İlişki Dinamikleri ve Projeksiyonların': {
      'tr': 'İlişki Dinamikleri ve Projeksiyonların',
      'en': 'Relationship Dynamics & Projections',
      'ja': '関係性の力学と投影',
    },
    'Karmik Gelişim & Ruhun Sınavı': {
      'tr': 'Karmik Gelişim & Ruhun Sınavı',
      'en': 'Karmic Evolution & Soul Challenge',
      'ja': '魂のカルマ的試練',
    },
    'ASTRO BÜLTEN & REHBER': {
      'tr': 'ASTRO BÜLTEN & REHBER',
      'en': 'ASTRO BULLETIN & GUIDE',
      'ja': '天文速報＆ガイド',
    },
    'Günlük / Haftalık Yorumlar & Aylık Gökyüzü Takvimi': {
      'tr': 'Günlük / Haftalık Yorumlar & Aylık Gökyüzü Takvimi',
      'en': 'Daily / Weekly Horoscopes & Monthly Celestial Calendar',
      'ja': '日次・週間星読み＆月間天体カレンダー',
    },
    'GÜNLÜK YORUM ☀️': {
      'tr': 'GÜNLÜK YORUM ☀️',
      'en': 'DAILY FORECAST ☀️',
      'ja': '今日の星読み ☀️',
    },
    'HAFTALIK YORUM & OLASILIKLAR 📅': {
      'tr': 'HAFTALIK YORUM & OLASILIKLAR 📅',
      'en': 'WEEKLY FORECAST & ODDS 📅',
      'ja': '週間星読み＆確率 📅',
    },
    'BUGÜNÜN KOZMİK TEMASI': {
      'tr': 'BUGÜNÜN KOZMİK TEMASI',
      'en': 'TODAY\'S COSMIC THEME',
      'ja': '本日のテーマ',
    },
    'GÜNÜN ODAK NOKTASI & TAVSİYE': {
      'tr': 'GÜNÜN ODAK NOKTASI & TAVSİYE',
      'en': 'DAILY FOCUS & ADVICE',
      'ja': '本日のアドバイス',
    },
    'HAFTALIK GENEL BAKIŞ': {
      'tr': 'HAFTALIK GENEL BAKIŞ',
      'en': 'WEEKLY OVERVIEW',
      'ja': '今週の全体像',
    },
    'AŞK & İLİŞKİLER ❤️': {
      'tr': 'AŞK & İLİŞKİLER ❤️',
      'en': 'LOVE & RELATIONSHIPS ❤️',
      'ja': '恋愛・パートナーシップ ❤️',
    },
    'KARİYER & FİNANS 💼': {
      'tr': 'KARİYER & FİNANS 💼',
      'en': 'CAREER & FINANCE 💼',
      'ja': '仕事・金運 💼',
    },
    'BEDEN & RUH SAĞLIĞI 🌿': {
      'tr': 'BEDEN & RUH SAĞLIĞI 🌿',
      'en': 'BODY & MIND WELLNESS 🌿',
      'ja': '心身の健康 🌿',
    },
    'BURCUNUZA ÖZEL HAFTALIK OLASILIKLAR:': {
      'tr': 'BURCUNUZA ÖZEL HAFTALIK OLASILIKLAR:',
      'en': 'WEEKLY ODDS FOR YOUR SIGN:',
      'ja': 'あなたの星座の週間確率:',
    },
    'AKTİF GÖKYÜZÜ OLAYLARI & MAJÖR AÇILAR': {
      'tr': 'AKTİF GÖKYÜZÜ OLAYLARI & MAJÖR AÇILAR',
      'en': 'ACTIVE CELESTIAL EVENTS & MAJOR ASPECTS',
      'ja': '注目の天文現象＆メジャーアスペクト',
    },
    'Olay': {
      'tr': 'Olay',
      'en': 'Events',
      'ja': '件の現象',
    },
    'Tutulma': {
      'tr': 'Tutulma',
      'en': 'Eclipses',
      'ja': '食',
    },
    'Her ayın 1\'inde yayınlanır. Zamanı geçen gökyüzü olayları ve açılar kafa karıştırmamak ve hafızayı şişirmemek için otomatik olarak silinir.': {
      'tr': 'Her ayın 1\'inde yayınlanır. Zamanı geçen gökyüzü olayları ve açılar kafa karıştırmamak ve hafızayı şişirmemek için otomatik olarak silinir.',
      'en': 'Published on the 1st of each month. Expired celestial events and aspects are automatically purged to prevent clutter.',
      'ja': '毎月1日に更新されます。終了した天文現象やアスペクトはメモリを圧迫しないよう自動的に消去されます。',
    },
    'Yalnızca Merkür, Venüs, Mars, Jüpiter, Satürn, Uranüs, Neptün, Plüton, Ay Düğümleri ve Chiron arasındaki majör açılar ile Yeniay/Dolunay/Tutulmalar yer alır.': {
      'tr': 'Yalnızca Merkür, Venüs, Mars, Jüpiter, Satürn, Uranüs, Neptün, Plüton, Ay Düğümleri ve Chiron arasındaki majör açılar ile Yeniay/Dolunay/Tutulmalar yer alır.',
      'en': 'Includes only major aspects between Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto, Lunar Nodes, Chiron, and New Moons/Full Moons/Eclipses.',
      'ja': '水星、金星、火星、木星、土星、天王星、海王星、冥王星、月の交点、カイロン間のメジャーアスペクトおよび新月・満月・日食・月食のみを掲載しています。',
    },
    'Bu ayın gerçekleşen tüm olayları tamamlandı ve hafızadan temizlendi. Gelecek ayın ilk günü yeni kozmik takvim yayınlanacaktır.': {
      'tr': 'Bu ayın gerçekleşen tüm olayları tamamlandı ve hafızadan temizlendi. Gelecek ayın ilk günü yeni kozmik takvim yayınlanacaktır.',
      'en': 'All events for this month have concluded and been cleared. The new cosmic calendar will arrive on the 1st of next month.',
      'ja': '今月の主要な天文現象はすべて終了し消去されました。来月1日に新しいカレンダーが公開されます。',
    },
    'HAFTANIN ÖNE ÇIKAN AÇILARI:': {
      'tr': 'HAFTANIN ÖNE ÇIKAN AÇILARI:',
      'en': 'FEATURED ASPECTS THIS WEEK:',
      'ja': '今週の注目アスペクト:',
    },
    'HAFTALIK BAŞARI & FIRSAT OLASILIKLARI': {
      'tr': 'HAFTALIK BAŞARI & FIRSAT OLASILIKLARI',
      'en': 'WEEKLY SUCCESS & OPPORTUNITY ODDS',
      'ja': '今週の成功＆チャンス確率',
    },
    'Kozmik Enerji': {
      'tr': 'Kozmik Enerji',
      'en': 'Cosmic Energy',
      'ja': 'コズミックエネルギー',
    },
    'Uyumlu:': {
      'tr': 'Uyumlu:',
      'en': 'Compatible:',
      'ja': '相性:',
    },
    'Skor': {
      'tr': 'Skor',
      'en': 'Score',
      'ja': 'スコア',
    },
    'Burcu': {
      'tr': 'Burcu',
      'en': 'Sign',
      'ja': '座',
    },
    'BİR SONRAKİ KOZMİK TUTULMA': {
      'tr': 'BİR SONRAKİ KOZMİK TUTULMA',
      'en': 'NEXT COSMIC ECLIPSE',
      'ja': '次回の天文日食・月食',
    },
    'GÜN': {
      'tr': 'GÜN',
      'en': 'DAYS',
      'ja': '日',
    },
    'SAAT': {
      'tr': 'SAAT',
      'en': 'HOURS',
      'ja': '時間',
    },
    'DAKİKA': {
      'tr': 'DAKİKA',
      'en': 'MINUTES',
      'ja': '分',
    },
    'SANİYE': {
      'tr': 'SANİYE',
      'en': 'SECONDS',
      'ja': '秒',
    },
    'Görünürlük:': {
      'tr': 'Görünürlük:',
      'en': 'Visibility:',
      'ja': '観測可能地域:',
    },
    '2026 - 2030 Kataloğu 🌌': {
      'tr': '2026 - 2030 Kataloğu 🌌',
      'en': '2026 - 2030 Catalog 🌌',
      'ja': '2026〜2030年カタログ 🌌',
    },
    'Saros & Eğitim 📚': {
      'tr': 'Saros & Eğitim 📚',
      'en': 'Saros & Academy 📚',
      'ja': 'サロス＆学術講座 📚',
    },
    'ÖNÜMÜZDEKİ YILLARIN TUTULMALARI': {
      'tr': 'ÖNÜMÜZDEKİ YILLARIN TUTULMALARI',
      'en': 'UPCOMING YEARS ECLIPSES',
      'ja': '今後の日食・月食一覧',
    },
    'Tamamlandı': {
      'tr': 'Tamamlandı',
      'en': 'Concluded',
      'ja': '終了',
    },
    'Yaklaşıyor': {
      'tr': 'Yaklaşıyor',
      'en': 'Approaching',
      'ja': '接近中',
    },
    'Burç': {
      'tr': 'Burç',
      'en': 'Sign',
      'ja': '星座',
    },
    'Düğüm': {
      'tr': 'Düğüm',
      'en': 'Node',
      'ja': 'ノード',
    },
    'Saros': {
      'tr': 'Saros',
      'en': 'Saros',
      'ja': 'サロス',
    },
    'Süre': {
      'tr': 'Süre',
      'en': 'Duration',
      'ja': '継続時間',
    },
    'SAROS & TUTULMA ASTROLOJİSİ DERSLERİ': {
      'tr': 'SAROS & TUTULMA ASTROLOJİSİ DERSLERİ',
      'en': 'SAROS & ECLIPSE ASTROLOGY LESSONS',
      'ja': 'サロス＆日食月食マスタークラス',
    },
    'Astronomik mekanikler, Saros periyotları ve doğum haritası üzerindeki kadersel tetikleyiciler.': {
      'tr': 'Astronomik mekanikler, Saros periyotları ve doğum haritası üzerindeki kadersel tetikleyiciler.',
      'en': 'Astronomical mechanics, Saros cycles, and karmic triggers on the natal chart.',
      'ja': '天文学的メカニズム、サロス周期、そして出生図に及ぼすカルマ的影響。',
    },
    'KADERSEL TUTULMA DANIŞMANLIĞI': {
      'tr': 'KADERSEL TUTULMA DANIŞMANLIĞI',
      'en': 'DESTINED ECLIPSE COUNSELING',
      'ja': 'カルマの日食・月食特別鑑定',
    },
    'Kişisel Harita Etkileri & 18 Yıllık Saros Yankısı': {
      'tr': 'Kişisel Harita Etkileri & 18 Yıllık Saros Yankısı',
      'en': 'Personal Chart Impacts & 18-Year Saros Echo',
      'ja': '出生図への影響と18年のサロス周期の共鳴',
    },
    '2026 Yılı Tutulmaları': {
      'tr': '2026 Yılı Tutulmaları',
      'en': '2026 Eclipses',
      'ja': '2026年の食',
    },
    '2027 Yılı Tutulmaları': {
      'tr': '2027 Yılı Tutulmaları',
      'en': '2027 Eclipses',
      'ja': '2027年の食',
    },
    'Tetiklenen Ev Aksı:': {
      'tr': 'Tetiklenen Ev Aksı:',
      'en': 'Activated House Axis:',
      'ja': '活性化されるハウス軸:',
    },
    'HARİTA TEMASLARI': {
      'tr': 'HARİTA TEMASLARI',
      'en': 'CHART CONTACTS (ASPECT TRIGGERS)',
      'ja': '出生図へのアスペクト接触',
    },
    '18 YILLIK SAROS DÖNGÜ YANKISI': {
      'tr': '18 YILLIK SAROS DÖNGÜ YANKISI',
      'en': '18-YEAR SAROS CYCLE ECHO',
      'ja': '18年のサロス周期の共鳴',
    },
    'KOZMİK DANIŞMANLIK & STRATEJİ:': {
      'tr': 'KOZMİK DANIŞMANLIK & STRATEJİ:',
      'en': 'COSMIC COUNSELING & STRATEGY:',
      'ja': '星読み戦略＆アドバイス:',
    },
    'Tam': {
      'tr': 'Tam',
      'en': 'Total',
      'ja': '皆既',
    },
    'Halkalı': {
      'tr': 'Halkalı',
      'en': 'Annular',
      'ja': '金環',
    },
    'Parçalı': {
      'tr': 'Parçalı',
      'en': 'Partial',
      'ja': '部分',
    },
    'Yarı Gölgeli': {
      'tr': 'Yarı Gölgeli',
      'en': 'Penumbral',
      'ja': '半影',
    },
    'Güneş Tutulması': {
      'tr': 'Güneş Tutulması',
      'en': 'Solar Eclipse',
      'ja': '日食',
    },
    'Ay Tutulması': {
      'tr': 'Ay Tutulması',
      'en': 'Lunar Eclipse',
      'ja': '月食',
    },
    'Tam Güneş Tutulması': {
      'tr': 'Tam Güneş Tutulması',
      'en': 'Total Solar Eclipse',
      'ja': '皆既日食',
    },
    'Parçalı Güneş Tutulması': {
      'tr': 'Parçalı Güneş Tutulması',
      'en': 'Partial Solar Eclipse',
      'ja': '部分日食',
    },
    'Halkalı Güneş Tutulması': {
      'tr': 'Halkalı Güneş Tutulması',
      'en': 'Annular Solar Eclipse',
      'ja': '金環日食',
    },
    'Tam Ay Tutulması': {
      'tr': 'Tam Ay Tutulması',
      'en': 'Total Lunar Eclipse',
      'ja': '皆既月食',
    },
    'Parçalı Ay Tutulması': {
      'tr': 'Parçalı Ay Tutulması',
      'en': 'Partial Lunar Eclipse',
      'ja': '部分月食',
    },
    'Yarı Gölgeli Ay Tutulması': {
      'tr': 'Yarı Gölgeli Ay Tutulması',
      'en': 'Penumbral Lunar Eclipse',
      'ja': '半影月食',
    },
    'Arşive Yeni Harita Ekle': {
      'tr': 'Arşive Yeni Harita Ekle',
      'en': 'Add New Chart to Archive',
      'ja': 'アーカイブに新規出生図を追加',
    },
    'Profili Sil': {
      'tr': 'Profili Sil',
      'en': 'Delete Profile',
      'ja': 'プロファイルを削除',
    },
    'Sil': {
      'tr': 'Sil',
      'en': 'Delete',
      'ja': '削除',
    },
    'Şehir (Dünya/TR) *': {
      'tr': 'Şehir (Dünya/TR) *',
      'en': 'City (Global/TR) *',
      'ja': '都市名 (世界/TR) *',
    },
    'Kariyer & İlerleme': {
      'tr': 'Kariyer & İlerleme',
      'en': 'Career & Advancement',
      'ja': 'キャリアと進展',
    },
    'Finansal Fırsatlar': {
      'tr': 'Finansal Fırsatlar',
      'en': 'Financial Opportunities',
      'ja': '金運・投資チャンス',
    },
    'Aşk & Romantizm': {
      'tr': 'Aşk & Romantizm',
      'en': 'Love & Romance',
      'ja': '恋愛・ロマンス',
    },
    'Ruhsal / Zihinsel Berraklık': {
      'tr': 'Ruhsal / Zihinsel Berraklık',
      'en': 'Spiritual / Mental Clarity',
      'ja': '精神の明晰さ',
    },
    'İletişim & Yeni Anlaşmalar': {
      'tr': 'İletişim & Yeni Anlaşmalar',
      'en': 'Communication & Contracts',
      'ja': '対話と新規契約',
    },
    'Kozmik Enerji:': {
      'tr': 'Kozmik Enerji:',
      'en': 'Cosmic Energy:',
      'ja': 'コズミックエネルギー:',
    },
    'KOZMİK NUMEROLOJİ MATRİSİ': {
      'tr': 'KOZMİK NUMEROLOJİ MATRİSİ',
      'en': 'COSMIC NUMEROLOGY MATRIX',
      'ja': 'コズミック数秘術マトリックス',
    },
    'ÖNEMLİ KRİTİK NOKTALAR:': {
      'tr': 'ÖNEMLİ KRİTİK NOKTALAR:',
      'en': 'KEY CRITICAL POINTS:',
      'ja': '重要ポイント:',
    },
    'Yılı Tutulmaları': {
      'tr': 'Yılı Tutulmaları',
      'en': 'Eclipses',
      'ja': '年の日食・月食',
    },
    'yılı için tutulma bulunamadı.': {
      'tr': 'yılı için tutulma bulunamadı.',
      'en': 'no eclipses found for this year.',
      'ja': '年の該当する食は見つかりませんでした。',
    },
    'HARİTANIZDAKİ DOĞRUDAN TEMASLAR (ASPECT TRIGGERS):': {
      'tr': 'HARİTANIZDAKİ DOĞRUDAN TEMASLAR (ASPECT TRIGGERS):',
      'en': 'DIRECT CONTACTS IN YOUR CHART (ASPECT TRIGGERS):',
      'ja': 'あなたの出生図との直接アスペクト（トリガー）:',
    },
    'Element': {
      'tr': 'Element',
      'en': 'Element',
      'ja': '元素',
    },
    'Uyumlu': {
      'tr': 'Uyumlu',
      'en': 'Compatible',
      'ja': '好相性',
    },
    'Günün Şanslı Saatleri': {
      'tr': 'Günün Şanslı Saatleri',
      'en': 'Auspicious Hours of the Day',
      'ja': '本日の幸運な時間帯',
    },
    'Bildirimleri Kapat': {
      'tr': 'Bildirimleri Kapat',
      'en': 'Disable Notifications',
      'ja': '通知を無効にする',
    },
    'Daha Sonra': {
      'tr': 'Daha Sonra',
      'en': 'Later',
      'ja': '後で',
    },
    'Günlük bildirimler kapatıldı.': {
      'tr': 'Günlük bildirimler kapatıldı.',
      'en': 'Daily notifications have been disabled.',
      'ja': '毎日の通知が無効化されました。',
    },
    'Kopyala': {
      'tr': 'Kopyala',
      'en': 'Copy',
      'ja': 'コピー',
    },
    'VIP KOZMİK ABONELİK PAKETLERİ': {
      'tr': 'VIP KOZMİK ABONELİK PAKETLERİ',
      'en': 'VIP COSMIC SUBSCRIPTION PLANS',
      'ja': 'VIPコズミック購読プラン',
    },
    'Apple App Store Güvencesiyle Resmi Abonelik': {
      'tr': 'Apple App Store Güvencesiyle Resmi Abonelik',
      'en': 'Official Subscription Secured by Apple App Store',
      'ja': 'Apple App Store管理の公式定期購入',
    },
    'Google Play Store Güvencesiyle Resmi Abonelik': {
      'tr': 'Google Play Store Güvencesiyle Resmi Abonelik',
      'en': 'Official Subscription Secured by Google Play Store',
      'ja': 'Google Play管理の公式定期購入',
    },
    'Promosyon Kodu Gir': {
      'tr': 'Promosyon Kodu Gir',
      'en': 'Enter Promo Code',
      'ja': 'プロモーションコードを入力',
    },
    'Promosyon Kodu': {
      'tr': 'Promosyon Kodu',
      'en': 'Promo Code',
      'ja': 'プロモーションコード',
    },
    'Aktif Et': {
      'tr': 'Aktif Et',
      'en': 'Activate',
      'ja': '有効化',
    },
    'VIP KOZMİK DANIŞMANLIK': {
      'tr': 'VIP KOZMİK DANIŞMANLIK',
      'en': 'VIP COSMIC CONSULTATION',
      'ja': 'VIP星読みコンサルティング',
    },
    'VIP Ayrıcalıklarını Başlatın': {
      'tr': 'VIP Ayrıcalıklarını Başlatın',
      'en': 'Start VIP Privileges',
      'ja': 'VIP特典を開始する',
    },
    'Rehber': {
      'tr': 'Rehber',
      'en': 'Guide',
      'ja': 'ガイド',
    },
    'TRANSİT': {
      'tr': 'TRANSİT',
      'en': 'TRANSIT',
      'ja': 'トランジット',
    },
    'NATAL': {
      'tr': 'NATAL',
      'en': 'NATAL',
      'ja': 'ネイタル',
    },
    'CANLI TRANSİT ÖNGÖRÜ ANALİZİ': {
      'tr': 'CANLI TRANSİT ÖNGÖRÜ ANALİZİ',
      'en': 'LIVE TRANSIT PREDICTIVE ANALYSIS',
      'ja': 'リアルタイム・トランジット予測分析',
    },
    'Açı Tipi': {
      'tr': 'Açı Tipi',
      'en': 'Aspect Type',
      'ja': 'アスペクト種別',
    },
    'Majör ve Minör Gezegen Etkileşimleri': {
      'tr': 'Majör ve Minör Gezegen Etkileşimleri',
      'en': 'Major and Minor Planetary Interactions',
      'ja': 'メジャーおよびマイナー惑星間相互作用',
    },
    'Kozmik Harita Arşivi': {
      'tr': 'Kozmik Harita Arşivi',
      'en': 'Cosmic Chart Archive',
      'ja': '出生図アーカイブ',
    },
    'VIP Sınırsız Harita Arşivi': {
      'tr': 'VIP Sınırsız Harita Arşivi',
      'en': 'VIP Unlimited Chart Archive',
      'ja': 'VIP無制限チャートアーカイブ',
    },
    'Tüm Harita Kayıtları': {
      'tr': 'Tüm Harita Kayıtları',
      'en': 'All Saved Charts',
      'ja': '保存済みチャート一覧',
    },
    'Henüz Kayıtlı Harita Yok': {
      'tr': 'Henüz Kayıtlı Harita Yok',
      'en': 'No Saved Charts Yet',
      'ja': '保存された出生図はありません',
    },
    'İlk Haritayı Ekle': {
      'tr': 'İlk Haritayı Ekle',
      'en': 'Add Your First Chart',
      'ja': '最初の出生図を追加',
    },
    'Yeni Harita Ekle': {
      'tr': 'Yeni Harita Ekle',
      'en': 'Add New Chart',
      'ja': '新規出生図を追加',
    },
    'Haritayı Aç': {
      'tr': 'Haritayı Aç',
      'en': 'Open Chart',
      'ja': '出生図を開く',
    },
    'Arşive Kaydet': {
      'tr': 'Arşive Kaydet',
      'en': 'Save to Archive',
      'ja': 'アーカイブに保存',
    },
    'Doğum Tarihi': {
      'tr': 'Doğum Tarihi',
      'en': 'Birth Date',
      'ja': '生年月日',
    },
    'Doğum Saati': {
      'tr': 'Doğum Saati',
      'en': 'Birth Time',
      'ja': '出生時間',
    },
    'Cinsiyet': {
      'tr': 'Cinsiyet',
      'en': 'Gender',
      'ja': '性別',
    },
    'VIP Yükselt': {
      'tr': 'VIP Yükselt',
      'en': 'Upgrade to VIP',
      'ja': 'VIPにアップグレード',
    },
    'VIP Sınırsız Arşiv Aktif': {
      'tr': 'VIP Sınırsız Arşiv Aktif',
      'en': 'VIP Unlimited Archive Active',
      'ja': 'VIP無制限アーカイブ有効',
    },
    'VIP Ayrıcalıklarını İncele': {
      'tr': 'VIP Ayrıcalıklarını İncele',
      'en': 'Explore VIP Privileges',
      'ja': 'VIP特典を確認',
    },
    'Sabitlemeyi Kaldır': {
      'tr': 'Sabitlemeyi Kaldır',
      'en': 'Unpin',
      'ja': '固定を解除',
    },
    'Başa Sabitle (VIP)': {
      'tr': 'Başa Sabitle (VIP)',
      'en': 'Pin to Top (VIP)',
      'ja': 'トップに固定 (VIP)',
    },
    'Güncellendi': {
      'tr': 'Güncellendi',
      'en': 'Updated',
      'ja': '更新されました',
    },
    'Hata oluştu': {
      'tr': 'Hata oluştu',
      'en': 'An error occurred',
      'ja': 'エラーが発生しました',
    },
    'SABİT YILDIZLAR VE DERECE ANLAMLARI': {
      'tr': 'SABİT YILDIZLAR VE DERECE ANLAMLARI',
      'en': 'FIXED STARS & DEGREE MEANINGS',
      'ja': '恒星と度数の意味',
    },
    'HARİTANIZLA KAVUŞUM YAPAN SABİT YILDIZLAR': {
      'tr': 'HARİTANIZLA KAVUŞUM YAPAN SABİT YILDIZLAR',
      'en': 'FIXED STARS CONJUNCT YOUR CHART',
      'ja': '出生図と合 (コンジャンクション) の恒星',
    },
    'CANLI TRANSİT SABİT YILDIZ TETİKLERİ': {
      'tr': 'CANLI TRANSİT SABİT YILDIZ TETİKLERİ',
      'en': 'LIVE TRANSIT FIXED STAR TRIGGERS',
      'ja': '現在のトランジット恒星トリガー',
    },
    'Aktif Gökyüzü': {
      'tr': 'Aktif Gökyüzü',
      'en': 'Active Sky',
      'ja': '現在の天空',
    },
    'Detay için dokun': {
      'tr': 'Detay için dokun',
      'en': 'Tap for details',
      'ja': 'タップして詳細を表示',
    },
    'CANLI SAYAÇ': {
      'tr': 'CANLI SAYAÇ',
      'en': 'LIVE COUNTDOWN',
      'ja': 'カウントダウン',
    },
    'YENİ': {
      'tr': 'YENİ',
      'en': 'NEW',
      'ja': '新機能',
    },
    'Yükselen': {
      'tr': 'Yükselen',
      'en': 'Ascendant',
      'ja': 'アセンダント',
    },
    'Kariyer': {
      'tr': 'Kariyer',
      'en': 'Career',
      'ja': 'キャリア',
    },
    'İlişkiler': {
      'tr': 'İlişkiler',
      'en': 'Relationships',
      'ja': '人間関係',
    },
    'Kökler': {
      'tr': 'Kökler',
      'en': 'Roots',
      'ja': 'ルーツ・家庭',
    },
    'Üçgen': {
      'tr': 'Üçgen',
      'en': 'Trine',
      'ja': '三分 (トライン)',
    },
    'Kare': {
      'tr': 'Kare',
      'en': 'Square',
      'ja': '四分 (スクエア)',
    },
    'Karşıt': {
      'tr': 'Karşıt',
      'en': 'Opposition',
      'ja': '衝 (オポジション)',
    },
    'Sekstil': {
      'tr': 'Sekstil',
      'en': 'Sextile',
      'ja': '六分 (セクスタイル)',
    },
    'Açılar Matrisi & Gezegen Açıları': {
      'tr': 'Açılar Matrisi & Gezegen Açıları',
      'en': 'Aspects Matrix & Planetary Aspects',
      'ja': 'アスペクト行列と惑星のアスペクト',
    },
    'Klasik Üçgen Izgara, Majör/Minör Açılar & Transitler': {
      'tr': 'Klasik Üçgen Izgara, Majör/Minör Açılar & Transitler',
      'en': 'Classical Triangle Grid, Major/Minor Aspects & Transits',
      'ja': '古典的な三角グリッド、メジャー/マイナーアスペクト、トランジット',
    },
    'Tutulmalar & Saros Akademisi': {
      'tr': 'Tutulmalar & Saros Akademisi',
      'en': 'Eclipses & Saros Academy',
      'ja': '日食・月食とサロス周期アカデミー',
    },
    '2026-2030 Kataloğu, Saros Döngüleri & Astronomi Dersi': {
      'tr': '2026-2030 Kataloğu, Saros Döngüleri & Astronomi Dersi',
      'en': '2026-2030 Catalog, Saros Cycles & Astronomy Masterclass',
      'ja': '2026-2030年カタログ、サロス周期、天文学マスタークラス',
    },
    'Izgara': {
      'tr': 'Izgara',
      'en': 'Grid',
      'ja': 'グリッド',
    },
    'Transit×Natal': {
      'tr': 'Transit×Natal',
      'en': 'Transit×Natal',
      'ja': 'トランジット×ネイタル',
    },
    'Natal': {
      'tr': 'Natal',
      'en': 'Natal',
      'ja': 'ネイタル',
    },
    'CANLI TRANSİT → NATAL MODU: Anlık gökyüzü gezegenlerinin doğum haritanıza yaptığı güncel açılar ve öngörü yorumları listeleniyor.': {
      'tr': 'CANLI TRANSİT → NATAL MODU: Anlık gökyüzü gezegenlerinin doğum haritanıza yaptığı güncel açılar ve öngörü yorumları listeleniyor.',
      'en': 'LIVE TRANSIT → NATAL MODE: Listing current aspects formed by real-time transiting planets to your birth chart and predictive interpretations.',
      'ja': 'リアルタイム・トランジット→ネイタル：現在の天空の惑星が出生図に形成する最新のアスペクトと未来予測の解釈を表示中。',
    },
    'NATAL HARİTA MODU: Doğum anınızdaki gezegenlerin kendi aralarındaki gerçek astronomik açıları ve karakter/potansiyel yorumları listeleniyor.': {
      'tr': 'NATAL HARİTA MODU: Doğum anınızdaki gezegenlerin kendi aralarındaki gerçek astronomik açıları ve karakter/potansiyel yorumları listeleniyor.',
      'en': 'NATAL CHART MODE: Listing real astronomical aspects between planets at your birth time and character/potential interpretations.',
      'ja': 'ネイタル出生図モード：出生時の惑星同士の天文学的アスペクトと性格・潜在能力の解釈を表示中。',
    },
    'Hücrelere dokunarak anlık transit gezegenlerin doğum haritanıza yaptığı açıların canlı öngörü yorumunu okuyabilirsiniz.': {
      'tr': 'Hücrelere dokunarak anlık transit gezegenlerin doğum haritanıza yaptığı açıların canlı öngörü yorumunu okuyabilirsiniz.',
      'en': 'Tap cells to read live predictive interpretations of aspects formed by transiting planets to your birth chart.',
      'ja': 'セルをタップすると、現在の運行惑星が出生図に与える影響のリアルタイム予測解説を読めます。',
    },
    'Hücrelere dokunarak doğum haritanızdaki iki gezegen arasındaki gerçek açının detaylı yorumunu okuyabilirsiniz.': {
      'tr': 'Hücrelere dokunarak doğum haritanızdaki iki gezegen arasındaki gerçek açının detaylı yorumunu okuyabilirsiniz.',
      'en': 'Tap cells to read detailed interpretations of the astronomical aspect between two planets in your birth chart.',
      'ja': 'セルをタップすると、出生図における2つの惑星間の天文学的アスペクトの詳細な解釈を読めます。',
    },
    'Belirtilen orb aralığında aktif açı bulunamadı.': {
      'tr': 'Belirtilen orb aralığında aktif açı bulunamadı.',
      'en': 'No active aspects found within the specified orb range.',
      'ja': '指定されたオーブ範囲内にアクティブなアスペクトは見つかりませんでした。',
    },
    'DOĞUM HARİTASI (NATAL) ETKİ ANALİZİ': {
      'tr': 'DOĞUM HARİTASI (NATAL) ETKİ ANALİZİ',
      'en': 'NATAL BIRTH CHART IMPACT ANALYSIS',
      'ja': 'ネイタル出生図の影響分析',
    },
    'Tolerans (Orb Sapması)': {
      'tr': 'Tolerans (Orb Sapması)',
      'en': 'Tolerance (Orb Deviation)',
      'ja': 'オーブ許容度',
    },
    'AÇILAR KILAVUZU (ANSİKLOPEDİ)': {
      'tr': 'AÇILAR KILAVUZU (ANSİKLOPEDİ)',
      'en': 'ASPECTS GUIDE (ENCYCLOPEDIA)',
      'ja': 'アスペクト百科事典ガイド',
    },
    'Majör Açılar (Temel)': {
      'tr': 'Majör Açılar (Temel)',
      'en': 'Major Aspects (Fundamental)',
      'ja': 'メジャーアスペクト（基本）',
    },
    'Minör Açılar (Özel)': {
      'tr': 'Minör Açılar (Özel)',
      'en': 'Minor Aspects (Special)',
      'ja': 'マイナーアスペクト（特殊）',
    },
    'Psikolojik Anlamı': {
      'tr': 'Psikolojik Anlamı',
      'en': 'Psychological Meaning',
      'ja': '心理的意味',
    },
    'Hediye': {
      'tr': 'Hediye',
      'en': 'Gift',
      'ja': '才能・ギフト',
    },
    'Sınav': {
      'tr': 'Sınav',
      'en': 'Challenge',
      'ja': '課題・試練',
    },
    'Orb Toleransı': {
      'tr': 'Orb Toleransı',
      'en': 'Orb Tolerance',
      'ja': 'オーブ許容範囲',
    },
    'Açısı': {
      'tr': 'Açısı',
      'en': 'Aspect',
      'ja': 'アスペクト',
    },
    'Açı': {
      'tr': 'Açı',
      'en': 'Aspect',
      'ja': 'アスペクト',
    },
    'Majör': {
      'tr': 'Majör',
      'en': 'Major',
      'ja': 'メジャー',
    },
    'Minör': {
      'tr': 'Minör',
      'en': 'Minor',
      'ja': 'マイナー',
    },
    'Kavuşum': {
      'tr': 'Kavuşum',
      'en': 'Conjunction',
      'ja': '合 (コンジャンクション)',
    },
    '150° Quincunx': {
      'tr': '150° Quincunx',
      'en': '150° Quincunx',
      'ja': '150度 クインカンクス',
    },
    'Yarı Kare (Semisquare)': {
      'tr': 'Yarı Kare (Semisquare)',
      'en': 'Semi-Square',
      'ja': 'セミスクエア (45°)',
    },
    'Sesquiquadrate': {
      'tr': 'Sesquiquadrate',
      'en': 'Sesquiquadrate',
      'ja': 'セスキコードレート (135°)',
    },
    'Quintile': {
      'tr': 'Quintile',
      'en': 'Quintile',
      'ja': 'クインタイル (72°)',
    },
    'Biquintile': {
      'tr': 'Biquintile',
      'en': 'Biquintile',
      'ja': 'ビクインタイル (144°)',
    },
    'Yarı Sekstil (Semisextile)': {
      'tr': 'Yarı Sekstil (Semisextile)',
      'en': 'Semi-Sextile',
      'ja': 'セミセクスタイル (30°)',
    },
    'Septile': {
      'tr': 'Septile',
      'en': 'Septile',
      'ja': 'セプタイル (51.4°)',
    },
    'Novile': {
      'tr': 'Novile',
      'en': 'Novile',
      'ja': 'ノヴァイル (40°)',
    },
    'Uyumlu / Akıcı': {
      'tr': 'Uyumlu / Akıcı',
      'en': 'Harmonious / Flowing',
      'ja': '調和的・流麗',
    },
    'Zorlayıcı / Dinamik': {
      'tr': 'Zorlayıcı / Dinamik',
      'en': 'Challenging / Dynamic',
      'ja': '挑戦的・躍動',
    },
    'Güçlü / Nötr': {
      'tr': 'Güçlü / Nötr',
      'en': 'Powerful / Neutral',
      'ja': '強力・中立',
    },
    'Stresli / Ayar Gerektiren': {
      'tr': 'Stresli / Ayar Gerektiren',
      'en': 'Stressful / Adjustment Required',
      'ja': '緊張・調整必須',
    },
    'Yaratıcı / Özel Yetenek': {
      'tr': 'Yaratıcı / Özel Yetenek',
      'en': 'Creative / Special Gift',
      'ja': '創造的・特別才能',
    },
    'Kadersel / Spiritüel': {
      'tr': 'Kadersel / Spiritüel',
      'en': 'Fated / Spiritual',
      'ja': '宿命的・霊的覚醒',
    },
    'Derin Dönüşüm / Arayış': {
      'tr': 'Derin Dönüşüm / Arayış',
      'en': 'Deep Transformation / Quest',
      'ja': '深層変容・精神探求',
    },
    'Odaklanmış Güç': {
      'tr': 'Odaklanmış Güç',
      'en': 'Focused Power',
      'ja': '凝縮された力',
    },
    'Kutupsallık & Denge': {
      'tr': 'Kutupsallık & Denge',
      'en': 'Polarity & Balance',
      'ja': '極性と調和',
    },
    'Ahenk & Akış': {
      'tr': 'Ahenk & Akış',
      'en': 'Harmony & Flow',
      'ja': '調和と流麗',
    },
    'Dinamik Gerilim': {
      'tr': 'Dinamik Gerilim',
      'en': 'Dynamic Tension',
      'ja': '躍動する緊張',
    },
    'Fırsat & İşbirliği': {
      'tr': 'Fırsat & İşbirliği',
      'en': 'Opportunity & Synergy',
      'ja': '機会と共創',
    },
    'İnce Ayar & Uyum': {
      'tr': 'İnce Ayar & Uyum',
      'en': 'Fine-Tuning & Alignment',
      'ja': '微調整と適応',
    },
    'Yaratıcı Deha': {
      'tr': 'Yaratıcı Deha',
      'en': 'Creative Genius',
      'ja': '創造的才能',
    },
    'Mikro Tetikleyici': {
      'tr': 'Mikro Tetikleyici',
      'en': 'Micro Trigger',
      'ja': 'マイクロ・トリガー',
    },
    'Sabır & Strateji': {
      'tr': 'Sabır & Strateji',
      'en': 'Patience & Strategy',
      'ja': '忍耐と戦略',
    },
    'Komşu Burç Bağı': {
      'tr': 'Komşu Burç Bağı',
      'en': 'Adjacent Sign Bond',
      'ja': '隣接星座の絆',
    },
    'Hücrelere dokunarak ilgili Transit gezegenin Natal gezegeninize yaptığı açının güncel öngörü yorumunu okuyabilirsiniz.': {
      'tr': 'Hücrelere dokunarak ilgili Transit gezegenin Natal gezegeninize yaptığı açının güncel öngörü yorumunu okuyabilirsiniz.',
      'en': 'Tap cells to read live predictive interpretations of aspects formed by transiting planets to your birth chart.',
      'ja': 'セルをタップすると、現在の運行惑星が出生図に与える影響のリアルタイム予測解説を読めます。',
    },
    'İki gezegenin gökyüzünde aynı burç ve derece civarında (0°) buluşmasıdır. En güçlü ve doğrudan açı formudur.': {
      'tr': 'İki gezegenin gökyüzünde aynı burç ve derece civarında (0°) buluşmasıdır. En güçlü ve doğrudan açı formudur.',
      'en': 'Two planets meeting at the same sign and degree in the sky (0°). The most powerful and direct aspect form.',
      'ja': '天空の同一星座・同一度数（0度）で2つの惑星が重なり合う配置。最も強力で直接的なアスペクト。',
    },
    'İki farklı arketipsel enerjinin ayrılmaz biçimde birleşmesi. Birey bu iki gücü birbirinden bağımsız deneyimleyemez; biri tetiklendiğinde diğeri derhal devreye girer.': {
      'tr': 'İki farklı arketipsel enerjinin ayrılmaz biçimde birleşmesi. Birey bu iki gücü birbirinden bağımsız deneyimleyemez; biri tetiklendiğinde diğeri derhal devreye girer.',
      'en': 'Inseparable fusion of two archetypal energies. Triggering one instantly activates the other.',
      'ja': '2つの元型エネルギーが不可分に融合。一方が刺激されると、もう一方も瞬時に発動します。',
    },
    'Yüksek odaklanma, yoğun irade ve tek bir hedef doğrultusunda muazzam enerji akışı.': {
      'tr': 'Yüksek odaklanma, yoğun irade ve tek bir hedef doğrultusunda muazzam enerji akışı.',
      'en': 'Laser focus, intense willpower, and formidable momentum toward a single purpose.',
      'ja': '卓越した集中力、強靭な意志、単一の目標に向けた圧倒的な推進力。',
    },
    'Gezegenlerin sınırlarını ayırt edememekten kaynaklanan körleşme ve sübjektiflik.': {
      'tr': 'Gezegenlerin sınırlarını ayırt edememekten kaynaklanan körleşme ve sübjektiflik.',
      'en': 'Blindness or lack of objectivity from inability to differentiate planetary boundaries.',
      'ja': '境界が曖昧になることによる視野狭窄や過度の主観性。',
    },
    'İki gezegenin tam karşıt burç ve derecelerde (180° mesafede, örn. Oğlak - Yengeç, Koç - Terazi) bulunmasıdır.': {
      'tr': 'İki gezegenin tam karşıt burç ve derecelerde (180° mesafede, örn. Oğlak - Yengeç, Koç - Terazi) bulunmasıdır.',
      'en': 'Two planets located in opposite signs and degrees (180° distance, e.g. Capricorn-Cancer, Aries-Libra).',
      'ja': '対向する星座・度数（180度）に位置する配置（例：山羊座-蟹座、牡羊座-天秤座）。',
    },
    'İçsel kutupsallık ve bu gerilimin sıklıkla dış dünyaya veya ilişkilere projekte edilmesi. Karşıtlık, bireye kendisini başkasının aynasında görme ve iki zıt kutbu dengeleme fırsatı sunar.': {
      'tr': 'İçsel kutupsallık ve bu gerilimin sıklıkla dış dünyaya veya ilişkilere projekte edilmesi. Karşıtlık, bireye kendisini başkasının aynasında görme ve iki zıt kutbu dengeleme fırsatı sunar.',
      'en': 'Internal polarity projected into relationships and the outer world, offering mirroring and integration.',
      'ja': '内的な二極化が対人関係や外部環境に投影され、他者を鏡として統合を果たす機会を提供します。',
    },
    'Geniş perspektif, objektiflik, ilişkilerde yüksek farkındalık ve kutupları uzlaştırma bilgeliği.': {
      'tr': 'Geniş perspektif, objektiflik, ilişkilerde yüksek farkındalık ve kutupları uzlaştırma bilgeliği.',
      'en': 'Broad perspective, deep objectivity, and wisdom in synthesizing opposing dualities.',
      'ja': '広い視野、高度な客観性、対極にある二面性を統合する調停の知恵。',
    },
    'Bir uçtan diğerine savrulma, ikilemde kalma ve karşı tarafı suçlama eğilimi.': {
      'tr': 'Bir uçtan diğerine savrulma, ikilemde kalma ve karşı tarafı suçlama eğilimi.',
      'en': 'Swings between extremes, chronic ambivalence, and projecting blame onto others.',
      'ja': '極端から極端への揺れ動き、葛藤、他者への責任転嫁。',
    },
    'Aynı elementteki iki burcun gezegenleri arasındaki 120 derecelik uyumlu açıdır (örn. Ateş-Ateş, Toprak-Toprak).': {
      'tr': 'Aynı elementteki iki burcun gezegenleri arasındaki 120 derecelik uyumlu açıdır (örn. Ateş-Ateş, Toprak-Toprak).',
      'en': 'Harmonious 120° aspect between planets sharing the same element (e.g. Fire-Fire, Earth-Earth).',
      'ja': '同一エレメント（火-火、地-地など）の星座間を結ぶ120度の調和的なアスペクト。',
    },
    'Doğuştan gelen yetenekler, akış hali ve rahat enerji transferi. Birey bu alanda doğal bir koruma, sezgi ve ustalık taşır.': {
      'tr': 'Doğuştan gelen yetenekler, akış hali ve rahat enerji transferi. Birey bu alanda doğal bir koruma, sezgi ve ustalık taşır.',
      'en': 'Innate gifts, flow state, and natural protection where energy circulates effortlessly.',
      'ja': '生まれながらの才能、フロー状態、自然な保護力のもとでエネルギーが循環します。',
    },
    'Doğal yaratıcılık, yüksek şans, sezgisel kolaylık ve içsel sükunet.': {
      'tr': 'Doğal yaratıcılık, yüksek şans, sezgisel kolaylık ve içsel sükunet.',
      'en': 'Natural creativity, effortless fortune, intuitive wisdom, and inner peace.',
      'ja': '天賦の創造性、引き寄せの幸運、直観的な洞察、内なる平穏。',
    },
    'Kolaylığa alışıp rehavete kapılmak, potansiyeli daha ileri taşımak için çaba göstermemek.': {
      'tr': 'Kolaylığa alışıp rehavete kapılmak, potansiyeli daha ileri taşımak için çaba göstermemek.',
      'en': 'Complacency and inertia due to lack of friction to push growth further.',
      'ja': '容易さに甘えて向上心を失い、潜在能力を開発しきれない怠惰。',
    },
    'Aynı nitelikteki (Öncü, Sabit veya Değişken) burçlar arasındaki 90 derecelik dik ve eylem odaklı açıdır.': {
      'tr': 'Aynı nitelikteki (Öncü, Sabit veya Değişken) burçlar arasındaki 90 derecelik dik ve eylem odaklı açıdır.',
      'en': '90° right-angle action aspect between signs of the same modality (Cardinal, Fixed, Mutable).',
      'ja': '同一クオリティ（活動宮、不動宮、柔軟宮）の星座間で90度の直角を成す行動指向のアスペクト。',
    },
    'İçsel sürtünme ve gelişim motoru. Rahatlığa izin vermeyen bu açı, insanı somut adım atmaya ve engelleri aşarak ustalaşmaya zorlar.': {
      'tr': 'İçsel sürtünme ve gelişim motoru. Rahatlığa izin vermeyen bu açı, insanı somut adım atmaya ve engelleri aşarak ustalaşmaya zorlar.',
      'en': 'Internal friction acting as a powerhouse engine of growth, demanding courage to achieve mastery.',
      'ja': '内的な摩擦が魂の進化の推進力となり、障害を克服して達人への到達を促します。',
    },
    'Kararlılık, krizleri avantaja çevirme, yüksek direnç ve kalıcı başarı inşa etme gücü.': {
      'tr': 'Kararlılık, krizleri avantaja çevirme, yüksek direnç ve kalıcı başarı inşa etme gücü.',
      'en': 'Decisiveness, turning adversity into triumph, high resilience, and enduring accomplishments.',
      'ja': '不屈の決断力、逆境を勝機に変える力、高い耐久性と偉業の構築。',
    },
    'Kronik stres, sabırsızlık, içsel çatışma ve gereksiz güç mücadeleleri.': {
      'tr': 'Kronik stres, sabırsızlık, içsel çatışma ve gereksiz güç mücadeleleri.',
      'en': 'Chronic stress, impatience, internal friction, and unproductive power struggles.',
      'ja': '慢性的なストレス、焦燥感、内的な衝突、不毛な主導権争い。',
    },
    'Birbiriyle uyumlu elementler (Ateş-Hava veya Toprak-Su) arasındaki 60 derecelik destekleyici açıdır.': {
      'tr': 'Birbiriyle uyumlu elementler (Ateş-Hava veya Toprak-Su) arasındaki 60 derecelik destekleyici açıdır.',
      'en': 'Supportive 60° aspect between compatible elements (Fire-Air or Earth-Water).',
      'ja': '相性の良いエレメント（火-風、地-水）の星座間を結ぶ60度の友好的なアスペクト。',
    },
    'Bilinçli çaba ve iletişim ile açığa çıkan fırsatlar. Birey inisiyatif aldığında zihinsel ve sosyal kapılar hızla açılır.': {
      'tr': 'Bilinçli çaba ve iletişim ile açığa çıkan fırsatlar. Birey inisiyatif aldığında zihinsel ve sosyal kapılar hızla açılır.',
      'en': 'Latent opportunities unlocked through conscious communication and initiative.',
      'ja': '意識的な対話と自発的な一歩によって開花する潜在的なチャンス。',
    },
    'Zihinsel kıvraklık, işbirliği kurma yeteneği, sosyal köprüler ve pratik çözümler.': {
      'tr': 'Zihinsel kıvraklık, işbirliği kurma yeteneği, sosyal köprüler ve pratik çözümler.',
      'en': 'Mental agility, collaborative talent, networking ease, and practical solutions.',
      'ja': '知的機転、協力関係の構築力、人脈の広がり、実践的な問題解決力。',
    },
    'Harekete geçilmezse fırsatların değerlendirilmeden geçip gitmesi.': {
      'tr': 'Harekete geçilmezse fırsatların değerlendirilmeden geçip gitmesi.',
      'en': 'Opportunities slipping away unseized without decisive proactivity.',
      'ja': '自ら行動を起こさないと、好機が何事もなく通り過ぎてしまうこと。',
    },
    'Ortak elementi veya niteliği bulunmayan burçlar arasındaki 150 derecelik adaptasyon açısıdır.': {
      'tr': 'Ortak elementi veya niteliği bulunmayan burçlar arasındaki 150 derecelik adaptasyon açısıdır.',
      'en': '150° inconjunct aspect between signs sharing neither element nor modality.',
      'ja': 'エレメントもクオリティも共有しない星座間を結ぶ150度のインコンジャンクト配置。',
    },
    'Birbirinden çok farklı iki yaşam alanını aynı anda yönetme ve sürekli bilinçli kalibrasyon yapma ihtiyacı.': {
      'tr': 'Birbirinden çok farklı iki yaşam alanını aynı anda yönetme ve sürekli bilinçli kalibrasyon yapma ihtiyacı.',
      'en': 'Managing two disparate life domains simultaneously, requiring constant conscious calibration.',
      'ja': '異質な2つの領域を同時に調和させるため、継続的な意識的調整を要します。',
    },
    'Yüksek adaptasyon kabiliyeti, kriz çözme zekası ve detaylı revizyon ustalığı.': {
      'tr': 'Yüksek adaptasyon kabiliyeti, kriz çözme zekası ve detaylı revizyon ustalığı.',
      'en': 'High adaptability, crisis problem-solving intelligence, and subtle revision artistry.',
      'ja': '高度な適応能力、危機解決の知性、精密な軌道修正の才能。',
    },
    'İçsel huzursuzluk, aşırı yüklenme ve sınırları koruyamama.': {
      'tr': 'İçsel huzursuzluk, aşırı yüklenme ve sınırları koruyamama.',
      'en': 'Inner restlessness, feeling overstretched, and difficulty maintaining boundaries.',
      'ja': '内的な落ち着きのなさ、過負荷、境界線の曖昧さ。',
    },
    '360 derecelik çemberin 5\'e bölünmesiyle elde edilen 72 derecelik özel yetenek ve sanatsal zeka açısıdır.': {
      'tr': '360 derecelik çemberin 5\'e bölünmesiyle elde edilen 72 derecelik özel yetenek ve sanatsal zeka açısıdır.',
      'en': '72° aspect dividing the 360° circle by 5, highlighting artistic intelligence and special gifts.',
      'ja': '360度の黄道帯を5分割（72度）した、芸術的知性と独自の天分を示すアスペクト。',
    },
    'Orijinal düşünce, teknik ustalık ve kalıpların dışına çıkan sıra dışı ilham kanalları.': {
      'tr': 'Orijinal düşünce, teknik ustalık ve kalıpların dışına çıkan sıra dışı ilham kanalları.',
      'en': 'Out-of-the-box original thought, technical finesse, and unconventional creative inspiration.',
      'ja': '枠にとらわれない独創的思考、技術的洗練、非凡なインスピレーション。',
    },
    'Yenilikçi buluşlar, sanatsal incelik ve özgün problem çözme yeteneği.': {
      'tr': 'Yenilikçi buluşlar, sanatsal incelik ve özgün problem çözme yeteneği.',
      'en': 'Innovative discoveries, artistic craftsmanship, and inventive problem-solving.',
      'ja': '革新的な発見、芸術的センス、独創的な解決力。',
    },
    'Sıradan rutinlere uyum sağlamakta zorlanma.': {
      'tr': 'Sıradan rutinlere uyum sağlamakta zorlanma.',
      'en': 'Impatience with mundane conformist routines.',
      'ja': '平凡な日常ルーティンや画一的な環境への適応の難しさ。',
    },
    '90 derecelik karenin yarısı olan 45 derecelik harekete geçirici minör açıdır.': {
      'tr': '90 derecelik karenin yarısı olan 45 derecelik harekete geçirici minör açıdır.',
      'en': '45° minor aspect representing half of a square, acting as a subtle friction prompt.',
      'ja': '90度スクエアの半分（45度）にあたる、行動を促す刺激的なマイナーアスペクト。',
    },
    'Yüzeye çıkmayı bekleyen içsel motivasyon ve küçük pürüzleri erkenden fark edip önlem alma refleksi.': {
      'tr': 'Yüzeye çıkmayı bekleyen içsel motivasyon ve küçük pürüzleri erkenden fark edip önlem alma refleksi.',
      'en': 'Latent urge waiting beneath the surface to address small friction before it escalates.',
      'ja': '水面下にある動機と、小さな違和感を早期に察知して手を打つ反射力。',
    },
    'Gelişmiş erken algı, çeviklik ve hızlı müdahale yeteneği.': {
      'tr': 'Gelişmiş erken algı, çeviklik ve hızlı müdahale yeteneği.',
      'en': 'Sharp early perception, agile reflexes, and preemptive problem resolution.',
      'ja': '鋭い初期感知力、敏捷性、問題の先回り解決。',
    },
    'Küçük detaylara gereğinden fazla takılma ve huzursuzluk.': {
      'tr': 'Küçük detaylara gereğinden fazla takılma ve huzursuzluk.',
      'en': 'Overanalyzing minor flaws and lingering restlessness.',
      'ja': '些細な欠陥への過度な執着と不安感。',
    },
    '90° kare ile 45° yarım karenin birleşimi olan 135 derecelik disiplin ve irade testi açısıdır.': {
      'tr': '90° kare ile 45° yarım karenin birleşimi olan 135 derecelik disiplin ve irade testi açısıdır.',
      'en': '135° aspect (square + semisquare) pushing for transformation through persistent grit.',
      'ja': 'スクエア（90度）＋セミスクエア（45度）からなる135度の持続的変容アスペクト。',
    },
    'Hedeflere giderken karşılaşılan pürüzleri sabır, strateji ve soğukkanlılıkla aşma dersi.': {
      'tr': 'Hedeflere giderken karşılaşılan pürüzleri sabır, strateji ve soğukkanlılıkla aşma dersi.',
      'en': 'Accumulation of persistent resistance that ultimately forces monumental breakthroughs.',
      'ja': '長期的な負荷が蓄積し、最終的に画期的なブレイクスルーを余儀なくさせる力学。',
    },
    'Yüksek dayanıklılık ve karmaşık engelleri yönetme disiplini.': {
      'tr': 'Yüksek dayanıklılık ve karmaşık engelleri yönetme disiplini.',
      'en': 'Tenacity, unyielding willpower under pressure, and mastery through obstacles.',
      'ja': '粘り強さ、逆境下での不屈の意志、困難を通じた達人への到達。',
    },
    'İnatçılık, acelecilik ve enerjinin yanlış yöne savrulması.': {
      'tr': 'İnatçılık, acelecilik ve enerjinin yanlış yöne savrulması.',
      'en': 'Stubborn defensive postures and friction with authority.',
      'ja': '頑なな防御姿勢や権威との摩擦。',
    },
    'Yan yana komşu iki burç arasındaki 30 derecelik tamamlayıcı farkındalık açısıdır.': {
      'tr': 'Yan yana komşu iki burç arasındaki 30 derecelik tamamlayıcı farkındalık açısıdır.',
      'en': 'Complementary 30° awareness aspect connecting two adjacent neighboring signs.',
      'ja': '隣接する2つの星座間を結ぶ30度の補完的気づきのアスペクト。',
    },
    'Bir burcun dersini tamamlayıp bir sonraki burcun deneyimine geçerken kurulan ince zihinsel köprü.': {
      'tr': 'Bir burcun dersini tamamlayıp bir sonraki burcun deneyimine geçerken kurulan ince zihinsel köprü.',
      'en': 'Subtle mental bridge formed while graduating from one sign\'s lesson to the next.',
      'ja': 'ひとつの星座の学びを完了し、次の星座の体験へと移行する架け橋。',
    },
    'Aşamalı büyüme, gözlem gücü ve bilgiyi entegre etme yeteneği.': {
      'tr': 'Aşamalı büyüme, gözlem gücü ve bilgiyi entegre etme yeteneği.',
      'en': 'Gradual growth, sharp observation, and integration of new wisdom.',
      'ja': '段階的な成長、鋭い観察眼、知識を統合する能力。',
    },
    'Komşu burçların farklı doğalarını dengelemekte kararsızlık.': {
      'tr': 'Komşu burçların farklı doğalarını dengelemekte kararsızlık.',
      'en': 'Hesitation in reconciling disparate adjoining elemental natures.',
      'ja': '隣接する星座の異質な本質を調和させる際の躊躇。',
    },
  };

  // --- GENEL UYGULAMA ÇEVİRİ SÖZLÜĞÜ (SEMANTİK ANAHTARLAR) ---
  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      'app_title': 'GÖKYÜZÜ DOKTORU',
      'app_subtitle': 'Geocentric & Placidus Profesyonel Doğum Haritası Sistemi',
      'lang_prompt': 'Lütfen Kullanmak İstediğiniz Dili Seçiniz',
      'start_app': 'Uygulamaya Giriş Yap',
      'daily_energy': 'Günün Enerjisi & Canlı Transitler',
      'big3_title': 'Üç Temel Direk',
      'sun_sign': 'Güneş Burcu',
      'moon_sign': 'Ay Burcu',
      'rising_sign': 'Yükselen Burcu',
      'sun': 'Güneş',
      'moon': 'Ay',
      'rising': 'Yükselen',
      'astro_bulletin': 'ASTRO BÜLTEN',
      'monthly_events': 'Ayın Gökyüzü Olayları',
      'weekly_summary': 'Haftalık Kozmik Özet',
      'zodiac_horoscopes': 'Burç Yorumları',
      'chart_details': 'Tam Doğum Haritası',
      'aspects_matrix': 'Açılar & Etkileşimler',
      'eclipses_guide': 'Tutulmalar & Saros',
      'vip_consulting': 'Kozmik Danışmanlık',
      'share_chart': 'Haritayı Paylaş',
      'notifications': 'Bildirimler',
      'enable_notifications': 'Bildirimleri Aç',
      'notifications_desc': 'Günlük gezegen transitleri ve ay fazı bildirimleri alın.',
      'settings': 'Ayarlar',
      'profile': 'Profil',
      'language': 'Dil Seçimi',
      'change_language': 'Dili Değiştir',
      'active_events': 'Aktif Olay',
      'loading': 'Yükleniyor...',
      'no_active_events': 'Bu ayın kalan günlerinde bekleyen majör olay bulunmuyor. Gelecek ayın ilk gününde yeni bülten yayınlanacaktır.',
      'elements_distribution': 'Elementer & Nitelik Dağılımı',
      'fire': 'Ateş',
      'earth': 'Toprak',
      'air': 'Hava',
      'water': 'Su',
      'vip_membership': 'VIP Kozmik Üyelik',
      'manage_subscription_google': 'Abonelik Google Play üzerinden yönetilmektedir.',
      'open_full_bulletin': 'Tüm Bülteni Aç',
      'daily_focus': 'Günün Odak Noktası',
      'lucky_hours': 'Şanslı Saatler',
      'compatible_sign': 'Uyumlu Burç',
      'weekly_overview': 'Haftalık Genel Bakış',
      'career_and_money': 'Kariyer & Maddiyat',
      'love_and_relationships': 'Aşk & İlişkiler',
      'health_and_wellness': 'Sağlık & Beden',
      'cosmic_probability': 'Kozmik Olasılık Dağılımı',
      'aspect_guide': 'Açılar Kılavuzu',
      'natal_aspects': 'Yalnızca Doğum Haritası Açılarım',
      'transit_aspects': 'Doğum Haritası + Canlı Transit Açılar',
      'close': 'Kapat',
      'back': 'Geri',
      'hello': 'Merhaba',
      'burc_yorumlari_yukselen_notu': 'Burç yorumları öncelikle Yükselen burcunuza göre takip edilmelidir. Yükselen burcunuzu bilmiyorsanız Güneş burcunuzu baz alabilirsiniz.',
      'yukselen_badge': 'YÜKSELEN',
      'gunes_badge': 'GÜNEŞ',
      'burcu': 'Burcu',
      'element_label': 'Element',
    },
    'en': {
      'app_title': 'SKY DOCTOR',
      'app_subtitle': 'Professional Geocentric & Placidus Natal Chart System',
      'lang_prompt': 'Please Select Your Preferred Language',
      'start_app': 'Enter Application',
      'daily_energy': 'Daily Cosmic Energy & Live Transits',
      'big3_title': 'The Big Three',
      'sun_sign': 'Sun Sign',
      'moon_sign': 'Moon Sign',
      'rising_sign': 'Rising Sign',
      'sun': 'Sun',
      'moon': 'Moon',
      'rising': 'Rising',
      'astro_bulletin': 'ASTRO BULLETIN',
      'monthly_events': 'Monthly Celestial Events',
      'weekly_summary': 'Weekly Cosmic Summary',
      'zodiac_horoscopes': 'Zodiac Forecasts',
      'chart_details': 'Full Natal Chart',
      'aspects_matrix': 'Aspects & Interactions',
      'eclipses_guide': 'Eclipses & Saros',
      'vip_consulting': 'Cosmic Consultation',
      'share_chart': 'Share Chart',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable Notifications',
      'notifications_desc': 'Receive daily planetary transits and moon phase updates.',
      'settings': 'Settings',
      'profile': 'Profile',
      'language': 'Language',
      'change_language': 'Change Language',
      'active_events': 'Active Events',
      'loading': 'Loading...',
      'no_active_events': 'No more pending major celestial events for this month. New events will appear on the 1st of next month.',
      'elements_distribution': 'Elements & Qualities Distribution',
      'fire': 'Fire',
      'earth': 'Earth',
      'air': 'Air',
      'water': 'Water',
      'vip_membership': 'VIP Cosmic Membership',
      'manage_subscription_google': 'Subscriptions are managed securely via Google Play.',
      'open_full_bulletin': 'Open Full Bulletin',
      'daily_focus': 'Daily Focus',
      'lucky_hours': 'Auspicious Hours',
      'compatible_sign': 'Compatible Sign',
      'weekly_overview': 'Weekly Overview',
      'career_and_money': 'Career & Finance',
      'love_and_relationships': 'Love & Relationships',
      'health_and_wellness': 'Health & Body',
      'cosmic_probability': 'Cosmic Probability Distribution',
      'aspect_guide': 'Aspects Guide',
      'natal_aspects': 'Natal Aspects Only',
      'transit_aspects': 'Natal + Live Transit Aspects',
      'close': 'Close',
      'back': 'Back',
      'hello': 'Hello',
      'burc_yorumlari_yukselen_notu': 'Horoscopes should primarily be followed according to your Rising Sign (Ascendant). If you do not know your Rising sign, you may refer to your Sun sign.',
      'yukselen_badge': 'RISING',
      'gunes_badge': 'SUN',
      'burcu': 'Sign',
      'element_label': 'Element',
    },
    'ja': {
      'app_title': '天空のドクター',
      'app_subtitle': '高精度ジオセントリック・プラシーダス出生図解析システム',
      'lang_prompt': '言語を選択してください',
      'start_app': 'アプリを開始する',
      'daily_energy': '本日のエネルギーと運行状況',
      'big3_title': '主要三要素 (ビッグスリー)',
      'sun_sign': '太陽星座',
      'moon_sign': '月星座',
      'rising_sign': '上昇宮 (アセンダント)',
      'sun': '太陽',
      'moon': '月',
      'rising': 'アセンダント',
      'astro_bulletin': '天文速報',
      'monthly_events': '今月の天文現象',
      'weekly_summary': '週間星読みサマリー',
      'zodiac_horoscopes': '星座別運勢',
      'chart_details': '詳細な出生図',
      'aspects_matrix': 'アスペクトと相互作用',
      'eclipses_guide': '日食・月食とサロス周期',
      'vip_consulting': '専属星読みコンサル',
      'share_chart': '出生図を共有',
      'notifications': '通知設定',
      'enable_notifications': '通知を有効にする',
      'notifications_desc': '毎日の惑星運行と月齢の最新情報を受け取ります。',
      'settings': '設定',
      'profile': 'プロフィール',
      'language': '言語設定',
      'change_language': '言語を変更する',
      'active_events': '件の注目現象',
      'loading': '読み込み中...',
      'no_active_events': '今月の残りの期間に予定されている主要天文現象はありません。翌月1日に新しい速報が届きます。',
      'elements_distribution': 'エレメントとクオリティの配分',
      'fire': '火',
      'earth': '地',
      'air': '風',
      'water': '水',
      'vip_membership': 'VIP星読みメンバーシップ',
      'manage_subscription_google': '定期購入はGoogle Playを通じて安全に管理されます。',
      'open_full_bulletin': '速報の全文を見る',
      'daily_focus': '今日のテーマ',
      'lucky_hours': '幸運の時間帯',
      'compatible_sign': '相性の良い星座',
      'weekly_overview': '今週の全体運',
      'career_and_money': '仕事運・金運',
      'love_and_relationships': '恋愛・パートナーシップ',
      'health_and_wellness': '健康・メンタルケア',
      'cosmic_probability': '天文学的確率分布',
      'aspect_guide': 'アスペクト解説ガイド',
      'natal_aspects': 'ネイタル出生図のアスペクトのみ',
      'transit_aspects': '出生図 ＋ 現在のトランジット連携',
      'close': '閉じる',
      'back': '戻る',
      'hello': 'こんにちは',
      'burc_yorumlari_yukselen_notu': '星読み運勢はアセンダント（上昇宮）を基準にお読みいただくことを推奨します。上昇宮が不明な場合は太陽星座をご参照ください。',
      'yukselen_badge': '上昇宮',
      'gunes_badge': '太陽',
      'burcu': '座',
      'element_label': 'エレメント',
    },
  };
}
