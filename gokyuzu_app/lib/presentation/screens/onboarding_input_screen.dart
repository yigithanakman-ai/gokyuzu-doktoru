import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/world_cities_service.dart';
import '../widgets/glass_card.dart';
import 'brutal_truths_screen.dart';

class OnboardingInputScreen extends StatefulWidget {
  const OnboardingInputScreen({super.key});

  @override
  State<OnboardingInputScreen> createState() => _OnboardingInputScreenState();
}

class _OnboardingInputScreenState extends State<OnboardingInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController(text: 'Türkiye');
  final _cityController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedGender = 'Erkek';
  bool _isLoading = false;
  String? _errorMessage;

  // Search suggestions for cities worldwide
  List<CityLocation> _filteredCities = [];

  static const List<String> _popularCountries = [
    'Türkiye',
    'Almanya',
    'İngiltere',
    'Hollanda',
    'ABD',
    'Azerbaycan',
    'Fransa',
    'Japonya',
  ];

  static const List<String> _turkishMonths = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  @override
  void initState() {
    super.initState();
    _cityController.addListener(_onCityChanged);
  }

  @override
  void dispose() {
    _cityController.removeListener(_onCityChanged);
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onCityChanged() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) {
      if (_filteredCities.isNotEmpty) {
        setState(() => _filteredCities = []);
      }
      return;
    }

    final matches = WorldCitiesService.search(query, limit: 8);

    setState(() {
      _filteredCities = matches;
    });

    if (matches.length < 4 && query.length >= 3) {
      final globalMatches = await WorldCitiesService.searchGlobal(query, limit: 8);
      if (mounted && _cityController.text.trim() == query) {
        setState(() {
          _filteredCities = globalMatches;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      helpText: 'DOĞUM TARİHİNİZİ SEÇİN',
      cancelText: 'İPTAL',
      confirmText: 'SEÇ',
      fieldLabelText: 'Doğum Tarihi',
      fieldHintText: 'GG.AA.YYYY',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.starlightGold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: 'DOĞUM SAATİNİZİ SEÇİN',
      cancelText: 'İPTAL',
      confirmText: 'SEÇ',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.starlightGold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _errorMessage = null;
      });
    }
  }

  String _formatTurkishName(String raw) {
    if (raw.trim().isEmpty) return '';
    return raw.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      String first;
      String rest = word.length > 1 ? word.substring(1).toLowerCase() : '';
      if (word.startsWith('i') || word.startsWith('İ')) {
        first = 'İ';
      } else if (word.startsWith('ı') || word.startsWith('I')) {
        first = 'I';
      } else {
        first = word[0].toUpperCase();
      }
      return '$first$rest';
    }).join(' ');
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Lütfen doğum tarihinizi seçiniz.';
      });
      return;
    }

    if (_selectedTime == null) {
      setState(() {
        _errorMessage = 'Lütfen doğum saatinizi seçiniz.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _filteredCities = [];
    });

    final name = _formatTurkishName(_nameController.text);
    final birthDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final birthTime =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    final scanController =
        ValueNotifier<String>('Lütfen bekleyiniz, gökyüzüne bağlanıyor...');
    final progressController = ValueNotifier<double>(0.2);

    // Show cosmic scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pastelLavender.withValues(alpha: 0.15),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.pastelLavender,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'KOZMİK TARAMA',
                  style: TextStyle(
                    color: AppColors.pastelLavender,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 14),
                ValueListenableBuilder<String>(
                  valueListenable: scanController,
                  builder: (_, message, child) => Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<double>(
                  valueListenable: progressController,
                  builder: (_, progress, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.pastelLavender),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Astrolojik koordinatların ve gölge yönlerin taranıyor...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      scanController.value = '✨ Doğum anındaki yıldız koordinatları taranıyor...';
      progressController.value = 0.5;

      // Offline calculation from embedded astrology archive
      final chart = await ApiService.calculateChart(
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        city: city,
        country: country,
      );

      await Future.delayed(const Duration(milliseconds: 700));
      scanController.value = '🪐 Güneş, Ay ve Yükselen konumları hizalanıyor...';
      progressController.value = 0.8;

      final truths = await ApiService.getBrutalTruths(
        name: name,
        sun: chart.sunSign,
        moon: chart.moonSign,
        ascendant: chart.risingSign,
        northNode: chart.planets['north_node']?.sign,
        gender: _selectedGender,
        mars: chart.planets['mars']?.sign,
        venus: chart.planets['venus']?.sign,
      );

      final profile = UserProfile(
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        birthCountry: country,
        birthCity: city,
        sunSign: chart.sunSign,
        moonSign: chart.moonSign,
        risingSign: chart.risingSign,
        gender: _selectedGender,
        isVip: false,
        rawChart: chart.rawChart,
      );

      await StorageService.saveProfile(profile);

      await Future.delayed(const Duration(milliseconds: 700));
      scanController.value = '🔮 Maskeler indiriliyor, gerçeklerle yüzleş...';
      progressController.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss cosmic scanning dialog

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BrutalTruthsScreen(
            profile: profile,
            chart: chart,
            truths: truths,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss dialog on error
        setState(() {
          _errorMessage =
              'Hesaplama yapılırken beklenmeyen bir durum oluştu: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.day} ${_turkishMonths[_selectedDate!.month]} ${_selectedDate!.year}'
        : 'Doğum Tarihinizi Seçiniz (GG.AA.YYYY)';

    final timeStr = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : 'Doğum Saatinizi Seçiniz (SS:DD)';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pastelPink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flare_rounded,
                        color: AppColors.pastelPink,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GÖKYÜZÜ DOKTORU',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.pastelPink,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Doğum Haritası\nHesaplama',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        height: 1.15,
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Doğum anınızdaki gezegen konumları, Placidus ev sistemi ve açı kalıplarıyla hazırlanan derin profesyonel astroloji analizi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 28),

                // Name Input
                Text(
                  'ADINIZ VEYA RUMUZUNUZ',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Örn: Yiğithan',
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.pastelLavender),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lütfen bir isim girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Gender Selection (Cinsiyet)
                Text(
                  'CİNSİYET (İLİŞKİ & PROJEKSİYON DİNAMİĞİ)',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildGenderChip('Erkek', 'Erkek (♂)'),
                    const SizedBox(width: 8),
                    _buildGenderChip('Kadın', 'Kadın (♀)'),
                    const SizedBox(width: 8),
                    _buildGenderChip('Diğer', 'Diğer (⚥)'),
                  ],
                ),
                const SizedBox(height: 20),

                // Date Picker Card
                Text(
                  'DOĞUM TARİHİN',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: AppColors.pastelPink, size: 20),
                            const SizedBox(width: 14),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _selectedDate == null
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                color: _selectedDate == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: AppColors.pastelLavender),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Picker Card
                Text(
                  'DOĞUM SAATİN',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(16),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_outlined,
                                color: AppColors.pastelMint, size: 20),
                            const SizedBox(width: 14),
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _selectedTime == null
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                color: _selectedTime == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: AppColors.pastelLavender),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Country Input & Quick Chips
                Text(
                  'DOĞDUĞUN ÜLKE',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _countryController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Örn: Türkiye',
                    prefixIcon: Icon(Icons.public,
                        color: AppColors.pastelBlue),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lütfen doğum ülkenizi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularCountries.map((country) {
                    final isSelected =
                        _countryController.text.trim().toLowerCase() ==
                            country.toLowerCase();
                    return InkWell(
                      onTap: () {
                        setState(() => _countryController.text = country);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.pastelBlue
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.pastelBlue
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          country,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.textDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // City Input with Live Autocomplete Suggestions
                Text(
                  'DOĞDUĞUN ŞEHİR',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Şehir adı yazın (Örn: Bolu, Bartın, Bursa...)',
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: AppColors.pastelPeach),
                    suffixIcon: _cityController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _cityController.clear();
                              setState(() => _filteredCities = []);
                            },
                          )
                        : null,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lütfen doğum şehrinizi girin';
                    }
                    return null;
                  },
                ),

                // Dynamic city suggestions appearing as the user types
                if (_filteredCities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.pastelLavender.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _filteredCities.map((loc) {
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: const Icon(Icons.location_city,
                              color: AppColors.pastelPeach, size: 18),
                          title: Text(
                            '${loc.city}, ${loc.country}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: Text(
                            'Enlem: ${loc.latitude.toStringAsFixed(2)}° • Boylam: ${loc.longitude.toStringAsFixed(2)}° • UTC+${loc.timezoneOffset.toInt()}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                          onTap: () {
                            _cityController.text = loc.city;
                            _countryController.text = loc.country;
                            setState(() => _filteredCities = []);
                            FocusScope.of(context).unfocus();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.savageRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.savageRed.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.savageRed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.savageRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pastelLavender,
                      disabledBackgroundColor:
                          AppColors.pastelLavender.withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(width: 14),
                              Text(
                                'Maskeler İndiriliyor...',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Gerçeklerle Yüzleşmeye Hazır mısın?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.textDark, size: 20),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.pastelLavender.withValues(alpha: 0.25)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.pastelLavender
                  : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
