import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/saved_profile_model.dart';
import '../../data/services/profile_archive_service.dart';
import '../../data/services/storage_service.dart';
import '../screens/archive_screen.dart';

class SynastryModalContent extends StatefulWidget {
  final UserProfile profile;

  const SynastryModalContent({super.key, required this.profile});

  @override
  State<SynastryModalContent> createState() => _SynastryModalContentState();
}

class _SynastryModalContentState extends State<SynastryModalContent> {
  List<SavedProfile> _allProfiles = [];
  bool _isLoading = true;

  SavedProfile? _partner1;
  SavedProfile? _partner2;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final archived = await ProfileArchiveService.getProfiles();

    DateTime parsedBirthDate;
    try {
      parsedBirthDate = DateTime.parse(widget.profile.birthDate);
    } catch (_) {
      parsedBirthDate = DateTime(1995, 4, 12);
    }

    // Create a SavedProfile representation for the active user
    final selfProfile = SavedProfile(
      id: 'self_active',
      name: '${widget.profile.name} (Ben)',
      surname: '',
      birthDate: parsedBirthDate,
      birthCity: widget.profile.birthCity,
      birthCountry: widget.profile.birthCountry,
      birthTime: widget.profile.birthTime,
      sunSign: widget.profile.sunSign,
      moonSign: widget.profile.moonSign,
      risingSign: widget.profile.risingSign,
      gender: widget.profile.gender,
      createdAt: DateTime.now(),
      isPinned: true,
    );

    // Fallback partners if archive is empty or has only 1 profile
    final defaultPartner1 = SavedProfile(
      id: 'default_partner_libra',
      name: 'Partner (Terazi)',
      surname: '',
      birthDate: DateTime(1996, 10, 10),
      birthCity: 'İstanbul',
      birthCountry: 'Türkiye',
      birthTime: '14:20',
      sunSign: 'Terazi',
      moonSign: 'Aslan',
      risingSign: 'Kova',
      gender: 'Kadın',
      createdAt: DateTime.now(),
    );

    final defaultPartner2 = SavedProfile(
      id: 'default_partner_taurus',
      name: 'İş Ortağı (Boğa)',
      surname: '',
      birthDate: DateTime(1992, 5, 4),
      birthCity: 'İzmir',
      birthCountry: 'Türkiye',
      birthTime: '08:45',
      sunSign: 'Boğa',
      moonSign: 'Başak',
      risingSign: 'Akrep',
      gender: 'Erkek',
      createdAt: DateTime.now(),
    );

    final List<SavedProfile> list = [selfProfile];
    list.addAll(archived);

    if (list.length == 1) {
      list.add(defaultPartner1);
      list.add(defaultPartner2);
    } else if (list.length == 2) {
      list.add(defaultPartner2);
    }

    if (mounted) {
      setState(() {
        _allProfiles = list;
        _partner1 = list.first;
        _partner2 = list.length > 1 ? list[1] : list.first;
        _isLoading = false;
      });
    }
  }

  void _swapPartners() {
    setState(() {
      final temp = _partner1;
      _partner1 = _partner2;
      _partner2 = temp;
    });
  }

  int _calculateCompatibilityScore(SavedProfile p1, SavedProfile p2) {
    int score = 75;

    // Element helper
    String getElement(String sign) {
      switch (sign) {
        case 'Koç':
        case 'Aslan':
        case 'Yay':
          return 'Ateş';
        case 'Boğa':
        case 'Başak':
        case 'Oğlak':
          return 'Toprak';
        case 'İkizler':
        case 'Terazi':
        case 'Kova':
          return 'Hava';
        case 'Yengeç':
        case 'Akrep':
        case 'Balık':
          return 'Su';
        default:
          return 'Ateş';
      }
    }

    final elSun1 = getElement(p1.sunSign);
    final elSun2 = getElement(p2.sunSign);
    final elMoon1 = getElement(p1.moonSign);
    final elMoon2 = getElement(p2.moonSign);

    // Sun-Sun compatibility
    if (elSun1 == elSun2) {
      score += 10;
    } else if ((elSun1 == 'Ateş' && elSun2 == 'Hava') ||
        (elSun1 == 'Hava' && elSun2 == 'Ateş') ||
        (elSun1 == 'Toprak' && elSun2 == 'Su') ||
        (elSun1 == 'Su' && elSun2 == 'Toprak')) {
      score += 12;
    } else {
      score += 2;
    }

    // Moon-Moon emotional resonance
    if (elMoon1 == elMoon2) {
      score += 8;
    } else if ((elMoon1 == 'Toprak' && elMoon2 == 'Su') ||
        (elMoon1 == 'Ateş' && elMoon2 == 'Hava')) {
      score += 7;
    }

    return score.clamp(65, 98);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF13111C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        ),
      );
    }

    final p1 = _partner1 ?? _allProfiles.first;
    final p2 = _partner2 ?? _allProfiles.last;
    final score = _calculateCompatibilityScore(p1, p2);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF13111C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFB6C1), width: 1.2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pastelPink.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.pastelPink,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sinastri & İlişki Uyumu Analizi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pastelPink,
                        ),
                      ),
                      Text(
                        'Arşivdeki kayıtlı kişiler arasında dinamik çift karşılaştırması',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // PARTNER SELECTION CONTROL HUB
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A2B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Karşılaştırılacak Haritaları Seçin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.person_add_alt_1_rounded,
                                    size: 14, color: AppColors.pastelPink),
                                SizedBox(width: 4),
                                Text(
                                  'Arşive Ekle',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.pastelPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 1. Partner Dropdown
                      _buildPartnerDropdown(
                        label: '1. Harita (Danışan / Kendiniz)',
                        selectedProfile: p1,
                        color: AppColors.pastelLavender,
                        onChanged: (newP) {
                          if (newP != null) setState(() => _partner1 = newP);
                        },
                      ),
                      const SizedBox(height: 8),

                      // Swap Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _swapPartners,
                          icon: const Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.pastelPink),
                          label: const Text(
                            'Sırayı Değiştir (Swap)',
                            style: TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 2. Partner Dropdown
                      _buildPartnerDropdown(
                        label: '2. Harita (Partner / Eş / İş Ortağı)',
                        selectedProfile: p2,
                        color: AppColors.pastelPink,
                        onChanged: (newP) {
                          if (newP != null) setState(() => _partner2 = newP);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SYNASTRY COMPATIBILITY SCORE CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pastelPink.withAlpha(50),
                        const Color(0xFF1E1A2B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.pastelPink.withAlpha(100), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. ${p1.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '☀️ ${p1.sunSign} • 🌙 ${p1.moonSign} • 🏹 ${p1.risingSign} ASC',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.favorite_rounded, color: AppColors.pastelPink, size: 26),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '2. ${p2.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '☀️ ${p2.sunSign} • 🌙 ${p2.moonSign} • 🏹 ${p2.risingSign} ASC',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.pastelPink.withAlpha(60),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.pastelPink),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Genel Uyum Skoru: %$score (Kozmik Rezonans)',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Kilit Gezegensel Etkileşimler (Placidus Çift Açıları):',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                _buildAspectItem(
                  aspect: '${p1.name} Güneş - ${p2.name} Ay Etkileşimi',
                  tag: 'Ruh Bağı & Derin Şefkat',
                  desc:
                      '${p1.sunSign} Güneşi ile ${p2.moonSign} Ayı arasında doğal bir duygusal rezonans mevcuttur. Biri sustuğunda diğeri içsel olarak ne hissettiğini kavrar.',
                  color: AppColors.pastelMint,
                ),
                _buildAspectItem(
                  aspect: 'Venüs & Mars Çekim Dinamiği',
                  tag: 'Tutku, Kimya & Romantizm',
                  desc:
                      'Aşk ve tutku gezegenlerinin açıları yüksek bir cinsel çekim ve karşılıklı estetik beğeni oluşturmaktadır. Birlikteyken enerji ve yaşam sevinci yükselir.',
                  color: AppColors.pastelPink,
                ),
                _buildAspectItem(
                  aspect: 'Merkür - Merkür Zihinsel Anlaşma',
                  tag: 'İletişim & Fikir Birliği',
                  desc:
                      '${p1.sunSign} ve ${p2.sunSign} burçlarının düşünme biçimleri saatlerce sohbet etmeye ve entelektüel ortak projeler üretmeye imkan tanır.',
                  color: AppColors.starlightGold,
                ),
                _buildAspectItem(
                  aspect: 'Satürn Karmik Taahhüt Açısı',
                  tag: 'Uzun Vadeli Güven & Sadakat',
                  desc:
                      'Geçici bir heves olmanın ötesinde; karşılıklı sorumluluk alma, hayatı birlikte inşa etme ve zorluklarda birbirine sığınma potansiyeli yüksektir.',
                  color: AppColors.pastelLavender,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerDropdown({
    required String label,
    required SavedProfile selectedProfile,
    required Color color,
    required ValueChanged<SavedProfile?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.bold),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<SavedProfile>(
              value: selectedProfile,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1626),
              icon: Icon(Icons.arrow_drop_down, color: color),
              items: _allProfiles.map((p) {
                return DropdownMenuItem<SavedProfile>(
                  value: p,
                  child: Row(
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${p.sunSign})',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectItem({
    required String aspect,
    required String tag,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  aspect,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
