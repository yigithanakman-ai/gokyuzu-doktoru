import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/saved_profile_model.dart';
import '../../data/services/astrology_engine.dart';
import '../../data/services/profile_archive_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/world_cities_service.dart';
import '../../data/services/active_profile_service.dart';
import 'chart_detail_screen.dart';
import 'cosmic_notes_screen.dart';
import '../widgets/vip_upgrade_modal.dart';
import '../../data/services/app_translation_service.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<SavedProfile> _profiles = [];
  bool _isLoading = true;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final isVip = await StorageService.isVipUnlocked();
    final list = await ProfileArchiveService.getProfiles();
    if (mounted) {
      setState(() {
        _isVip = isVip;
        _profiles = list;
        _isLoading = false;
      });
    }
  }

  void _togglePin(SavedProfile profile) async {
    final res = await ProfileArchiveService.togglePin(profile.id);
    if (!mounted) return;

    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslationService.tr(res.message ?? 'Hata oluştu')),
          backgroundColor: AppColors.savageRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslationService.tr(res.message ?? 'Güncellendi')),
          backgroundColor: AppColors.pastelMint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteProfile(SavedProfile profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        title: Text(AppTranslationService.tr('Profili Sil'), style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          '${profile.fullName} ${AppTranslationService.tr('isimli harita kaydı arşivinizden silinecektir. Emin misiniz?')}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppTranslationService.tr('Vazgeç'), style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.savageRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppTranslationService.tr('Sil'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ProfileArchiveService.deleteProfile(profile.id);
      _loadData();
    }
  }

  void _openProfileChart(SavedProfile profile) {
    final d = profile.birthDate;
    final birthDateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final tp = profile.birthTime.split(':');
    final hour = tp.isNotEmpty ? (int.tryParse(tp[0]) ?? 12) : 12;
    final minute = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;

    final chart = AstrologyEngine.calculateChart(
      name: profile.fullName,
      birthDate: d,
      birthTime: TimeOfDay(hour: hour, minute: minute),
      city: profile.birthCity,
      country: profile.birthCountry,
    );

    final userProf = UserProfile(
      name: profile.fullName,
      birthDate: birthDateStr,
      birthTime: profile.birthTime,
      birthCity: profile.birthCity,
      birthCountry: profile.birthCountry,
      sunSign: chart.sunSign.split(' ').first,
      moonSign: chart.moonSign.split(' ').first,
      risingSign: chart.risingSign.split(' ').first,
      gender: profile.gender,
      isVip: _isVip,
      rawChart: chart.rawChart,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChartDetailScreen(profile: userProf),
      ),
    );
  }

  void _showAddProfileModal() {
    if (_profiles.length >= ProfileArchiveService.maxFreeProfiles && !_isVip) {
      _showVipRequiredSheet();
      return;
    }

    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final cityController = TextEditingController(text: 'İstanbul');
    final countryController = TextEditingController(text: 'Türkiye');
    DateTime selectedDate = DateTime(1996, 6, 15);
    TimeOfDay selectedTime = const TimeOfDay(hour: 14, minute: 30);
    String selectedGender = 'Kadın';
    List<CityLocation> filteredArchiveCities = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          height: MediaQuery.of(modalCtx).size.height * 0.85,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF13111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.starlightGold, width: 1)),
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
                    const Icon(Icons.person_add_alt_1_rounded,
                        color: AppColors.starlightGold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppTranslationService.tr('Arşive Yeni Harita Ekle'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(modalCtx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'İsim *',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: surnameController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Soyisim *',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Doğum Tarihi & Saati
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: modalCtx,
                                initialDate: selectedDate,
                                firstDate: DateTime(1930),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Doğum Tarihi', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: modalCtx,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setModalState(() => selectedTime = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Doğum Saati', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.starlightGold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            onChanged: (val) {
                              setModalState(() {
                                filteredArchiveCities = val.trim().isEmpty
                                    ? []
                                    : WorldCitiesService.search(val.trim(), limit: 5);
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Şehir (Dünya/TR) *',
                              hintText: 'Örn: Tokyo, Bolu, Paris...',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: countryController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Ülke *',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (filteredArchiveCities.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Material(
                        color: const Color(0xFF1E1A2B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.starlightGold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: filteredArchiveCities.map((loc) {
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(Icons.location_city,
                                  color: AppColors.pastelPeach, size: 16),
                              title: Text(
                                '${loc.city}, ${loc.country}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'UTC+${loc.timezoneOffset.toInt()} • ${loc.latitude.toStringAsFixed(1)}°, ${loc.longitude.toStringAsFixed(1)}°',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                              onTap: () {
                                cityController.text = loc.city;
                                countryController.text = loc.country;
                                setModalState(() {
                                  filteredArchiveCities = [];
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Cinsiyet
                    const Text('Cinsiyet', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Kadın', 'Erkek', 'Diğer'].map((g) {
                        final isSel = selectedGender == g;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(g, style: TextStyle(fontSize: 12, color: isSel ? Colors.black : Colors.white70)),
                            selected: isSel,
                            selectedColor: AppColors.starlightGold,
                            onSelected: (val) {
                              if (val) setModalState(() => selectedGender = g);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.starlightGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final surname = surnameController.text.trim();
                          if (name.isEmpty) return;

                          final newProfile = SavedProfile(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            surname: surname,
                            birthDate: selectedDate,
                            birthTime: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            birthCity: cityController.text.trim(),
                            birthCountry: countryController.text.trim(),
                            gender: selectedGender,
                          );

                          final res = await ProfileArchiveService.saveProfile(newProfile);
                          if (!modalCtx.mounted) return;
                          Navigator.of(modalCtx).pop();

                          if (!mounted) return;
                          if (!res.success && res.requiresVip) {
                            _showVipRequiredSheet();
                          } else {
                            _loadData();
                          }
                        },
                        child: const Text('Arşive Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVipRequiredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1B162E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.starlightGold, width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.starlightGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('👑', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 14),
            const Text(
              'VIP Sınırsız Harita Arşivi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.starlightGold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ücretsiz arşiv hakkınız olan 3 profil sınırına ulaştınız. Ailenizin, eşinizin, çocuklarınızın ve danışanlarınızın tüm haritalarını sınırsızca saklamak ve 3 kişiyi en üste sabitlemek (Pinlemek) için VIP üyeliğe geçiş yapabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, height: 1.45, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.starlightGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  VipUpgradeModal.show(context, onPurchased: _loadData);
                },
                child: const Text('VIP Ayrıcalıklarını İncele', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedProfiles = _profiles.where((p) => p.isPinned).toList();
    final otherProfiles = _profiles.where((p) => !p.isPinned).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppTranslationService.tr('Kozmik Harita Arşivi'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // Kozmik Günlük & Hatırlatıcı İkonu
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, color: AppColors.pastelMint),
            tooltip: AppTranslationService.tr('Kozmik Günlük & Hatırlatıcı'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CosmicNotesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.starlightGold),
            tooltip: AppTranslationService.tr('Yeni Harita Ekle'),
            onPressed: _showAddProfileModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.starlightGold))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Kota Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isVip
                        ? AppColors.starlightGold.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isVip
                          ? AppColors.starlightGold.withValues(alpha: 0.4)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isVip ? Icons.workspace_premium_rounded : Icons.folder_shared_rounded,
                        color: _isVip ? AppColors.starlightGold : AppColors.pastelLavender,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isVip
                                  ? AppTranslationService.tr('VIP Sınırsız Arşiv Aktif')
                                  : '${_profiles.length} / ${ProfileArchiveService.maxFreeProfiles} ${AppTranslationService.tr('Ücretsiz Profil Kullanıldı')}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isVip ? AppColors.starlightGold : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isVip
                                  ? AppTranslationService.tr('Tüm kayıtlar güvenli şifrelenmiş kasada saklanıyor.')
                                  : AppTranslationService.tr('3 profile kadar ücretsiz kaydedebilir, haritaları inceleyebilirsiniz.'),
                              style: const TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      if (!_isVip)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.starlightGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => VipUpgradeModal.show(context, onPurchased: _loadData),
                          child: Text(AppTranslationService.tr('VIP Yükselt'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Sabitlenenler (Pinned)
                if (pinnedProfiles.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.starlightGold),
                      const SizedBox(width: 6),
                      Text(
                        '${AppTranslationService.tr('Sabitlenen Haritalar')} (${pinnedProfiles.length}/3)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...pinnedProfiles.map((p) => _buildProfileCard(p, isPinnedSection: true)),
                  const SizedBox(height: 16),
                ],

                // Tüm Kayıtlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppTranslationService.tr('Tüm Harita Kayıtları'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${_profiles.length} ${AppTranslationService.tr('Kişi')}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_profiles.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.group_add_rounded, size: 48, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(
                          AppTranslationService.tr('Henüz Kayıtlı Harita Yok'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppTranslationService.tr('Sevdiklerinizin, eşinizin veya danışanlarınızın haritalarını kaydetmek için yukarıdaki (+) butonuna dokunun.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.white38),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.starlightGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _showAddProfileModal,
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(AppTranslationService.tr('İlk Haritayı Ekle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...otherProfiles.map((p) => _buildProfileCard(p, isPinnedSection: false)),
                ],

                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildProfileCard(SavedProfile profile, {required bool isPinnedSection}) {
    final daysToBday = ProfileArchiveService.getDaysUntilBirthday(profile.birthDate);
    final isUpcoming = daysToBday <= 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPinnedSection
            ? const Color(0xFF1D1829)
            : const Color(0xFF14121E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPinnedSection
              ? AppColors.starlightGold.withValues(alpha: 0.45)
              : Colors.white10,
          width: isPinnedSection ? 1.2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _openProfileChart(profile),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isPinnedSection
                          ? AppColors.starlightGold.withValues(alpha: 0.2)
                          : AppColors.pastelLavender.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        profile.gender == 'Kadın' ? '♀\uFE0E' : (profile.gender == 'Erkek' ? '♂\uFE0E' : '⚕'),
                        style: TextStyle(
                          fontSize: 18,
                          color: isPinnedSection ? AppColors.starlightGold : AppColors.pastelLavender,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (profile.isPinned) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.starlightGold),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.birthCity}, ${profile.birthCountry} • ${profile.birthTime}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      profile.isPinned ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: profile.isPinned ? AppColors.starlightGold : Colors.white30,
                      size: 22,
                    ),
                    tooltip: profile.isPinned ? 'Sabitlemeyi Kaldır' : 'Başa Sabitle (VIP)',
                    onPressed: () => _togglePin(profile),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white30, size: 20),
                    tooltip: 'Profili Sil',
                    onPressed: () => _deleteProfile(profile),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Doğum Günü Hatırlatıcısı Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? AppColors.pastelMint.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUpcoming
                            ? AppColors.pastelMint.withValues(alpha: 0.4)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cake_rounded,
                          size: 13,
                          color: isUpcoming ? AppColors.pastelMint : Colors.white60,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          daysToBday == 0
                              ? 'Bugün Doğum Günü! 🎂'
                              : 'Doğum gününe $daysToBday gün kaldı',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                            color: isUpcoming ? AppColors.pastelMint : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        AppTranslationService.tr('Haritayı Aç'),
                        style: const TextStyle(fontSize: 11.5, color: AppColors.starlightGold, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.starlightGold),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final mainProf = await StorageService.getProfile();
                  if (!mounted) return;
                  if (mainProf != null) {
                    final switched = await ActiveProfileService.switchProfile(
                      context: context,
                      targetSavedProfile: profile,
                      mainProfile: mainProf,
                    );
                    if (switched && mounted) {
                      setState(() {});
                    }
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.starlightGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.starlightGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.starlightGold),
                      const SizedBox(width: 6),
                      Text(
                        AppTranslationService.tr('Bu Haritayı Uygulamaya Yansıt (VIP)'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
