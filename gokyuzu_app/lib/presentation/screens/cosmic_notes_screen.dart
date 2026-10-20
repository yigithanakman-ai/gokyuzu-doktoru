import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/cosmic_note_model.dart';
import '../../data/models/saved_profile_model.dart';
import '../../data/services/cosmic_notes_service.dart';
import '../../data/services/profile_archive_service.dart';
import '../../data/services/storage_service.dart';

class CosmicNotesScreen extends StatefulWidget {
  const CosmicNotesScreen({super.key});

  @override
  State<CosmicNotesScreen> createState() => _CosmicNotesScreenState();
}

class _CosmicNotesScreenState extends State<CosmicNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CosmicNote> _notes = [];
  List<SavedProfile> _profiles = [];
  bool _isLoading = true;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final isVip = await StorageService.isVipUnlocked();
    final notes = await CosmicNotesService.getNotes();
    final profiles = await ProfileArchiveService.getProfiles();
    if (mounted) {
      setState(() {
        _isVip = isVip;
        _notes = notes;
        _profiles = profiles;
        _isLoading = false;
      });
    }
  }

  void _showAddNoteModal() {
    if (!_isVip) {
      _showVipLockedSheet();
      return;
    }

    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'Günlük';
    String selectedPlanet = 'Ay ☽';

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
            border: Border(top: BorderSide(color: AppColors.pastelMint, width: 1.2)),
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
                    const Icon(Icons.edit_note_rounded,
                        color: AppColors.pastelMint, size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Yeni Kozmik Not & Günlük',
                        style: TextStyle(
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
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Not Başlığı *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: 'Örn: Akrep Yeniayı Hislerim veya Rüyalarım',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Kategori Seçimi
                    const Text('Kategori', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Günlük', 'Rüya', 'Transit Hissi', 'Meditasyon'].map((c) {
                        final isSel = selectedCategory == c;
                        return ChoiceChip(
                          label: Text(c, style: TextStyle(fontSize: 11.5, color: isSel ? Colors.black : Colors.white70)),
                          selected: isSel,
                          selectedColor: AppColors.pastelMint,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedCategory = c);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Bağlantılı Gezegen
                    const Text('Odak Gezegen / Enerji', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Ay ☽', 'Güneş ☉', 'Venüs ♀\uFE0E', 'Mars ♂\uFE0E', 'Satürn ♄', 'Jüpiter ♃'].map((p) {
                        final isSel = selectedPlanet == p;
                        return ChoiceChip(
                          label: Text(p, style: TextStyle(fontSize: 11.5, color: isSel ? Colors.black : Colors.white70)),
                          selected: isSel,
                          selectedColor: AppColors.starlightGold,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedPlanet = p);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: contentController,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                      decoration: InputDecoration(
                        labelText: 'Kozmik Notunuz / Günlüğünüz *',
                        alignLabelWithHint: true,
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: 'Bugünkü gökyüzü transitlerinin sana hissettirdiklerini, rüyalarını veya aldığın kararları yaz...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pastelMint,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final content = contentController.text.trim();
                          if (title.isEmpty || content.isEmpty) return;

                          final newNote = CosmicNote(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            content: content,
                            date: DateTime.now(),
                            category: selectedCategory,
                            linkedPlanet: selectedPlanet,
                          );

                          await CosmicNotesService.saveNote(newNote);
                          if (!modalCtx.mounted) return;
                          Navigator.of(modalCtx).pop();
                          if (!mounted) return;
                          _loadData();
                        },
                        child: const Text('Günlüğü Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  void _showVipLockedSheet() {
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
              child: const Center(child: Text('🔒', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 14),
            const Text(
              'VIP Kozmik Günlük & Hatırlatıcı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.starlightGold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gökyüzü transitlerine göre hislerinizi, rüyalarınızı ve astrolojik notlarınızı tutmak, arşivdeki kişilerin doğum günlerini ve solar dönüşlerini takip etmek VIP üyelere özel ayrıcalıktır.',
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
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('VIP Ayrıcalıklarını Keşfet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Kozmik Günlük & Hatırlatıcı',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.pastelMint),
            tooltip: 'Yeni Not Ekle',
            onPressed: _showAddNoteModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.pastelMint,
          indicatorWeight: 3,
          labelColor: AppColors.pastelMint,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.book_rounded, size: 20), text: 'Astro-Günlük'),
            Tab(icon: Icon(Icons.cake_rounded, size: 20), text: 'Doğum Günleri'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.pastelMint))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotesTab(),
                _buildBirthdaysTab(),
              ],
            ),
    );
  }

  Widget _buildNotesTab() {
    if (!_isVip) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.pastelMint.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, size: 36, color: AppColors.pastelMint),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kozmik Günlük VIP Özelliğidir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Transit gezegen geçişleriyle eş zamanlı hislerinizi, rüyalarınızı ve ritüellerinizi güvenle not alabilmek için VIP üyeliğe geçin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pastelMint,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showVipLockedSheet,
                child: const Text('VIP Kilidini Aç', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (_notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.note_alt_outlined, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              const Text(
                'Henüz Günlük Notu Eklenmedi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gökyüzü enerjilerinin sende bıraktığı izleri kaydetmek için (+) butonuna tıkla.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pastelMint,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showAddNoteModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('İlk Notu Yaz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: _notes.length,
      itemBuilder: (context, idx) {
        final note = _notes[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF14121E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          note.category,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.pastelMint),
                        ),
                      ),
                      if (note.linkedPlanet != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.starlightGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            note.linkedPlanet!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.starlightGold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${note.date.day.toString().padLeft(2, '0')}.${note.date.month.toString().padLeft(2, '0')}.${note.date.year}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                note.content,
                style: const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBirthdaysTab() {
    if (_profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cake_outlined, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              const Text(
                'Arşivinizde Henüz Kişi Kaydı Yok',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              const Text(
                'Doğum günlerini ve Solar Dönüşlerini takip etmek için Harita Arşivi kısmından kişi ekleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
        ),
      );
    }

    // Doğum gününe kalan gün sayısına göre sırala (en yakın olan en üstte)
    final sorted = List<SavedProfile>.from(_profiles);
    sorted.sort((a, b) {
      final da = ProfileArchiveService.getDaysUntilBirthday(a.birthDate);
      final db = ProfileArchiveService.getDaysUntilBirthday(b.birthDate);
      return da.compareTo(db);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: sorted.length,
      itemBuilder: (context, idx) {
        final profile = sorted[idx];
        final days = ProfileArchiveService.getDaysUntilBirthday(profile.birthDate);
        final isNear = days <= 30;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isNear ? const Color(0xFF1E281F) : const Color(0xFF14121E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNear
                  ? AppColors.pastelMint.withValues(alpha: 0.5)
                  : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isNear
                      ? AppColors.pastelMint.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isNear ? '🎂' : '🎈',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.birthDate.day.toString().padLeft(2, '0')}.${profile.birthDate.month.toString().padLeft(2, '0')} • Yaklaşan Solar Dönüş',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isNear
                      ? AppColors.pastelMint
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  days == 0 ? 'BUGÜN! 🥳' : '$days Gün Kaldı',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isNear ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
