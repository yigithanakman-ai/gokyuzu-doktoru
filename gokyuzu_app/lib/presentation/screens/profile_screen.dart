import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import 'legal_document_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isVip = false;
  Map<String, dynamic>? _savedAccount;
  List<Map<String, dynamic>> _feedbackList = [];

  // Gizli Yönetici Konsolu Sayaçları (5 Dokunuş)
  int _secretTaps = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final vip = await StorageService.isVip();
    final account = await StorageService.getUserAccount();
    final feedback = await StorageService.getFeedbackList();
    if (mounted) {
      setState(() {
        _isVip = vip;
        _savedAccount = account;
        _feedbackList = feedback;
      });
    }
  }

  /// Küfür, hakaret, argo, taciz, nefret söylemi ve tehdit içeren kelimeleri filtreleyen güvenlik motoru
  static bool _containsInappropriateContent(String input) {
    if (input.trim().isEmpty) return false;

    // Normalizasyon: Küçük harfe dönüştür, Türkçe karakterleri eşle
    String text = input.toLowerCase();
    text = text
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('@', 'a')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' '); // özel karakterleri boşluğa çevir

    // Yinelenen harfleri teke indir (ör: piiiççç -> pic, siiiikkk -> sik)
    final deduplicated = text.replaceAll(RegExp(r'(.)\1{2,}'), r'$1');

    // Yasaklı sözcük ve kök listesi (Küfür, hakaret, taciz, rencide edici ifadeler)
    const bannedWords = [
      'amk', 'aq', 'amq', 'amina', 'aminakoyayim', 'aminakoyim', 'amcik',
      'sik', 'sikerim', 'sikeyim', 'sikik', 'siktir', 'siktirgit', 'sikeyim',
      'yarrak', 'yarak', 'yarrag',
      'orospu', 'oruspu', 'orspu', 'oc', 'orospucocugu',
      'pic', 'pici', 'picler',
      'got', 'gotveren', 'gotlek',
      'ibne', 'ibnelik',
      'pust', 'pustluk',
      'kahpe', 'kahpelik',
      'kancik',
      'pezevenk', 'pezevenklik',
      'serefsiz', 'serefsizlik',
      'haysiyetsiz', 'karaktersiz',
      'salak', 'aptal', 'gerizekali', 'ahmak', 'dangalak', 'yavsak', 'beyinsiz', 'embesil', 'moron',
      'taciz', 'tacizci', 'tecavuz', 'tecavuzcu',
      'surtuk', 'fahise',
      'geber', 'gebertirim', 'oldururum', 'katil',
      'anani', 'anana', 'bacini', 'bacina', 'sulaleni',
      'fuck', 'fucking', 'motherfucker', 'bitch', 'bastard', 'asshole', 'cunt', 'dick', 'pussy', 'retard', 'slut', 'whore',
    ];

    // Kelime bazlı tam eşleşme kontrolü
    final words = deduplicated.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.isEmpty) continue;
      for (final banned in bannedWords) {
        if (word == banned) return true;
        // Uzun kelimelerde kök kontrolü
        if (word.length >= 4 && word.startsWith(banned) && banned.length >= 3) {
          return true;
        }
      }
    }

    // Cümle içi kalıp kontrolü
    for (final banned in bannedWords) {
      if (banned.length >= 3) {
        final regex = RegExp(r'\b' + RegExp.escape(banned) + r'\b');
        if (regex.hasMatch(deduplicated)) {
          return true;
        }
      }
    }

    return false;
  }

  void _onAvatarTapped() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 3)) {
      _secretTaps = 1;
    } else {
      _secretTaps++;
    }
    _lastTapTime = now;

    if (_secretTaps >= 5) {
      _secretTaps = 0;
      _showAdminConsoleDialog();
    }
  }

  void _showAdminConsoleDialog() {
    final adminController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191428),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
        ),
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFFFD700), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Yönetici Konsolu',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Özel Yönetici & Geliştirici VIP Kodunu Giriniz:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: adminController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Aktivasyon Kodu',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.vpn_key_rounded, color: Color(0xFFFFD700), size: 18),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final code = adminController.text.trim();
              final success = await StorageService.activateVipCode(code);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                if (success) {
                  setState(() => _isVip = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Tebrikler! Özel VIP statüsü sınırsız olarak aktif edildi.'),
                      backgroundColor: Color(0xFF6C5CE7),
                      duration: Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Geçersiz yönetici kodu.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text('Doğrula & Aktif Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackModal() {
    String selectedCategory = 'Öneri / Tavsiye';
    final messageController = TextEditingController();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF161224),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: Color(0xFF6C5CE7), width: 1.5)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.rate_review_rounded, color: Color(0xFFFFD700), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'İstek ve Öneri Bildirimi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Güvenlik & Topluluk Kuralları Uyarısı
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0392B).withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE74C3C).withAlpha(120), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.gpp_maybe_rounded, color: Color(0xFFE74C3C), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Topluluk İlkeleri & Saygı Bildirimi:\nGeri bildirimlerinizde küfür, hakaret, argo, taciz, tehdit veya rencide edici ifadelere kesinlikle izin verilmemektedir. Gönderilen tüm mesajlar otomatik güvenlik filtrelerinden geçmektedir.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFFCCCC),
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kategori Seçimi
                  const Text(
                    'Bildirim Kategorisi:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Öneri / Tavsiye',
                      'Yeni Özellik Talebi',
                      'Astroloji Analiz Talebi',
                      'Hata Bildirimi',
                      'Genel Görüş',
                    ].map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6C5CE7),
                        backgroundColor: Colors.white.withAlpha(12),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() => selectedCategory = cat);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Mesaj Alanı
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Uygulamamızla ilgili istek, öneri veya düşüncelerinizi detaylıca buraya yazabilirsiniz...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.black26,
                      counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                      ),
                    ),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setModalState(() => errorMessage = null);
                      }
                    },
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withAlpha(120)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11.5, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('İsteği / Öneriyi İlet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: () async {
                      final rawText = messageController.text.trim();

                      if (rawText.isEmpty) {
                        setModalState(() {
                          errorMessage = 'Lütfen iletmek istediğiniz mesajınızı yazınız.';
                        });
                        return;
                      }

                      if (rawText.length < 5) {
                        setModalState(() {
                          errorMessage = 'Mesajınız en az 5 karakter uzunluğunda olmalıdır.';
                        });
                        return;
                      }

                      // Küfür, hakaret ve taciz denetimi
                      if (_containsInappropriateContent(rawText)) {
                        setModalState(() {
                          errorMessage =
                              '⚠️ Mesajınızda topluluk kurallarımıza aykırı (küfür, hakaret, taciz veya rencide edici) ifadeler tespit edildi. Lütfen saygılı ve yapıcı bir üslup kullanınız.';
                        });
                        return;
                      }

                      // Başarılı kayıt
                      final sender = widget.profile.name.isNotEmpty ? widget.profile.name : 'Misafir Kullanıcı';
                      await StorageService.saveFeedback(
                        category: selectedCategory,
                        message: rawText,
                        senderName: sender,
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                      await _loadState();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Teşekkürler! İstek ve öneriniz başarıyla ekibimize iletildi.'),
                            backgroundColor: Color(0xFF2E7D32),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openLegalDoc(LegalDocType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil & Üyelik İşlemleri',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PROFİL ÖZET KARTI (Gizli 5 dokunuş ile Yönetici VIP Konsolu açılır)
            _buildProfileSummaryCard(),
            const SizedBox(height: 16),

            // 2. ÜYELİK VE HESAP BİLGİSİ KARTI
            _buildAccountDetailsCard(),
            const SizedBox(height: 16),

            // 3. İSTEK & ÖNERİ BİLDİRİMİ KARTI
            _buildFeedbackCard(),
            const SizedBox(height: 16),

            // 4. YASAL BİLGİLENDİRME & SÖZLEŞMELER
            _buildLegalDocumentsCard(),
            const SizedBox(height: 16),

            // 5. HESAP & VERİ SİLME (APPLE 5.1.1 & KVKK UYUMLU)
            _buildDeleteAccountCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withAlpha(210),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isVip ? const Color(0xFFFFD700).withAlpha(160) : AppColors.cardBorder,
          width: _isVip ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _onAvatarTapped,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: _isVip ? const Color(0xFFFFD700) : AppColors.primaryViolet,
                  child: Text(
                    widget.profile.name.isNotEmpty ? widget.profile.name[0].toUpperCase() : 'G',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.profile.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isVip
                                ? const Color(0xFFFFD700).withAlpha(45)
                                : Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isVip ? const Color(0xFFFFD700) : Colors.white30,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isVip ? Icons.stars : Icons.person_outline,
                                size: 12,
                                color: _isVip ? const Color(0xFFFFD700) : Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isVip ? 'VIP ÜYE' : 'STANDART',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _isVip ? const Color(0xFFFFD700) : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.profile.birthCity}, ${widget.profile.birthCountry} • ${widget.profile.birthDate} ${widget.profile.birthTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_savedAccount != null && _savedAccount!['email'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📧 ${_savedAccount!['email']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSignMiniBadge('Güneş', widget.profile.sunSign, Icons.wb_sunny_rounded, Colors.amber),
              _buildSignMiniBadge('Ay', widget.profile.moonSign, Icons.nightlight_round, Colors.lightBlueAccent),
              _buildSignMiniBadge('Yükselen', widget.profile.risingSign, Icons.arrow_upward_rounded, const Color(0xFFE056FD)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignMiniBadge(String label, String sign, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          sign,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // 2. HESAP VE ÜYELİK DETAY KARTI
  Widget _buildAccountDetailsCard() {
    final registeredEmail = _savedAccount?['email'] ?? 'Kayıtlı e-posta adresi';
    final fullName = _savedAccount != null
        ? '${_savedAccount!['name'] ?? ''} ${_savedAccount!['surname'] ?? ''}'.trim()
        : widget.profile.name;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withAlpha(210),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.badge_rounded, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'Hesap & Üyelik Bilgileri',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            title: 'Kullanıcı:',
            value: fullName.isNotEmpty ? fullName : widget.profile.name,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.email_outlined,
            title: 'E-Posta:',
            value: registeredEmail,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_city_rounded,
            title: 'Doğum Yeri & Tarihi:',
            value: '${widget.profile.birthCity} • ${widget.profile.birthDate}',
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isVip ? Icons.workspace_premium_rounded : Icons.star_border_rounded,
                    color: _isVip ? const Color(0xFFFFD700) : Colors.white60,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isVip ? 'VIP Ayrıcalıklı Statü Aktif' : 'Standart Kullanıcı',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: _isVip ? const Color(0xFFFFD700) : Colors.white70,
                    ),
                  ),
                ],
              ),
              if (_isVip)
                TextButton.icon(
                  onPressed: () async {
                    await StorageService.deactivateVip();
                    setState(() => _isVip = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Standart Kullanıcı Moduna geçildi (VIP kilitlendi). Müşteri deneyimini test edebilirsiniz.'),
                          backgroundColor: Colors.blueGrey,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_reset_rounded, size: 14, color: Colors.white60),
                  label: const Text(
                    'Standart Mod (Test)',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    backgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _showAdminConsoleDialog,
                  icon: const Icon(Icons.key_rounded, size: 14, color: Color(0xFFFFD700)),
                  label: const Text(
                    'VIP Kod Gir',
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    backgroundColor: const Color(0xFFFFD700).withAlpha(25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 3. İSTEK & ÖNERİ BİLDİRİMİ KARTI
  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withAlpha(210),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6C5CE7).withAlpha(120), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.rate_review_rounded, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'İstek & Öneri Bildirimi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Uygulamamızı geliştirmek için görüş, öneri ve deneyimleriniz bizim için çok kıymetlidir.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 12),

          // Güvenlik & Topluluk İlkeleri Uyarı Notu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC0392B).withAlpha(35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE74C3C).withAlpha(120), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.gpp_maybe_rounded, color: Color(0xFFE74C3C), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Topluluk İlkeleri & Saygı Bildirimi:\nGeri bildirimlerinizde küfür, hakaret, argo, taciz, tehdit veya rencide edici söz ve eylemlere kesinlikle izin verilmemektedir. Gönderilen tüm istek ve öneriler sistem güvenliği kapsamında otomatik filtrelenmektedir.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFCCCC),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // İstek ve Öneri Gönder Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showFeedbackModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text(
                'İstek veya Öneri Bildir',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),

          // Kullanıcının Daha Önce Gönderdiği İstekler
          if (_feedbackList.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gönderilen Bildirimleriniz:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                Text(
                  '${_feedbackList.length} adet',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._feedbackList.take(3).map((fb) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withAlpha(50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            fb['category'] ?? 'Öneri',
                            style: const TextStyle(fontSize: 10, color: Color(0xFFB3A7FF), fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            fb['status'] ?? 'İnceleniyor',
                            style: const TextStyle(fontSize: 9.5, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fb['message'] ?? '',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // 4. YASAL BİLGİLENDİRME & SÖZLEŞMELER KARTI
  Widget _buildLegalDocumentsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withAlpha(210),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.gavel_rounded, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'Yasal Prosedürler & Aydınlatma',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Türkiye Cumhuriyeti 6698 sayılı KVKK mevzuatına tam uyumlu yasal haklarınızı ve sözleşmeleri aşağıdan inceleyebilirsiniz:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildLegalTile(
            title: 'KVKK Aydınlatma Metni',
            subtitle: '6698 sayılı kanun kapsamında veri işleme ve haklarınız',
            icon: Icons.shield_outlined,
            onTap: () => _openLegalDoc(LegalDocType.kvkk),
          ),
          _buildLegalTile(
            title: 'Gizlilik Politikası',
            subtitle: 'Kişisel verilerinizin korunması ve güvenliği',
            icon: Icons.lock_outline,
            onTap: () => _openLegalDoc(LegalDocType.privacy),
          ),
          _buildLegalTile(
            title: 'Kullanım Koşulları & Sözleşme',
            subtitle: 'Uygulama şartları, fikri mülkiyet ve sorumluluk reddi',
            icon: Icons.description_outlined,
            onTap: () => _openLegalDoc(LegalDocType.terms),
          ),
          _buildLegalTile(
            title: 'Reklam & Çerez Politikası',
            subtitle: 'Ödüllü sponsorlu reklamlar ve veri tercihleri',
            icon: Icons.campaign_outlined,
            onTap: () => _openLegalDoc(LegalDocType.advertising),
          ),
          _buildLegalTile(
            title: 'Mesafeli Satış & İptal İade',
            subtitle: '6502 sayılı kanun kapsamında cayma hakkı ve abonelik şartları',
            icon: Icons.receipt_long_outlined,
            onTap: () => _openLegalDoc(LegalDocType.salesAndRefund),
          ),
          _buildLegalTile(
            title: 'Yasal Sorumluluk Reddi (Disclaimer)',
            subtitle: 'Öz farkındalık ve eğlence bildirimi, tıbbi/hukuki feragatname',
            icon: Icons.warning_amber_rounded,
            onTap: () => _openLegalDoc(LegalDocType.disclaimer),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6C5CE7), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 13),
          ],
        ),
      ),
    );
  }

  // 5. HESAP VE VERİ SİLME KARTI (APPLE 5.1.1 & KVKK UYUMLU)
  Widget _buildDeleteAccountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC0392B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE74C3C).withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.delete_forever_rounded, color: Color(0xFFE74C3C), size: 20),
              SizedBox(width: 8),
              Text(
                'Hesabı & Tüm Verileri Kalıcı Olarak Sil',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB3C1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Apple App Store 5.1.1 kuralı ve 6698 sayılı KVKK gereğince; hesabınızı, kayıtlı tüm doğum haritalarınızı, notlarınızı ve arşivinizi cihazınızdan kalıcı olarak silebilirsiniz. Bu işlem geri alınamaz.',
            style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.35),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _showDeleteAccountDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE74C3C),
                side: const BorderSide(color: Color(0xFFE74C3C), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text(
                'Hesabımı ve Verilerimi Kalıcı Olarak Sil',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191428),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE74C3C), width: 1.2),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hesabı Kalıcı Olarak Sil?',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '⚠️ DİKKAT: Hesabınızı ve tüm doğum haritası verilerinizi silmek üzeresiniz.\n\n'
              '• Kayıtlı tüm profiller, rektifikasyon notları ve yerel ayarlar kalıcı olarak yok edilir.\n'
              '• Apple App Store veya Google Play üzerinden devam eden bir VIP aboneliğiniz varsa, aboneliği cihaz ayarlarınızdan ayrıca iptal etmelisiniz (hesabı silmek mağaza aboneliğini otomatik iptal etmez).\n\n'
              'Bu işlemi onaylıyor musunuz?',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.clearAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hesabınız ve tüm doğum verileriniz kalıcı olarak silindi.'),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 4),
                  ),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Evet, Kalıcı Olarak Sil', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
