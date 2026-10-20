import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/planetary_hours_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/world_cities_service.dart';
import '../../data/services/app_location_service.dart';

class PlanetaryHoursModal extends StatefulWidget {
  final UserProfile profile;

  const PlanetaryHoursModal({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlanetaryHoursModal(profile: profile),
    );
  }

  @override
  State<PlanetaryHoursModal> createState() => _PlanetaryHoursModalState();
}

class _PlanetaryHoursModalState extends State<PlanetaryHoursModal> {
  late PlanetaryDayInfo _dayInfo;
  late CityLocation _currentCity;
  int _selectedTab = 0; // 0: Tümü (24), 1: Gündüz (12), 2: Gece (12)
  int? _expandedIndex;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    // Güvenli varsayılan olarak Datça ile başlat
    _currentCity = WorldCitiesService.findCity('Datça');
    _recalculate();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // 1. Önbellekte kayıtlı gerçek GPS konumu varsa hemen uygula
    final cached = await AppLocationService.getCachedLocation();
    if (cached != null && mounted) {
      setState(() {
        _currentCity = cached;
        _recalculate();
      });
      return;
    }
    // 2. İzin zaten verilmişse güncel GPS koordinatını al
    if (await AppLocationService.hasLocationPermission()) {
      final gpsLoc = await AppLocationService.getCurrentLocation(requestPermission: false);
      if (gpsLoc != null && mounted) {
        setState(() {
          _currentCity = gpsLoc;
          _recalculate();
        });
      }
    }
  }

  Future<void> _getCurrentLocationGps() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final loc = await AppLocationService.getCurrentLocation(requestPermission: true);
      if (loc != null) {
        if (mounted) {
          setState(() {
            _currentCity = loc;
            _recalculate();
            _isLocating = false;
          });
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.starlightGold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📍 GPS Konumu Ayarlandı: ${loc.city} (${loc.latitude.toStringAsFixed(2)}°, ${loc.longitude.toStringAsFixed(2)}°)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1D5A3A),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLocating = false);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('⚠️ Konum bilgisi alınamadı. Lütfen cihazınızın GPS servisini ve izinlerini kontrol ediniz.'),
              backgroundColor: AppColors.savageRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _recalculate() {
    setState(() {
      _dayInfo = PlanetaryHoursService.calculatePlanetaryHours(
        latitude: _currentCity.latitude,
        longitude: _currentCity.longitude,
        timezoneOffset: _currentCity.timezoneOffset,
        cityName: _currentCity.city,
      );
    });
  }

  void _selectCity() async {
    final searchController = TextEditingController();
    List<CityLocation> filtered = List.from(WorldCitiesService.allCities);

    final selected = await showModalBottomSheet<CityLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF130F26),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📍 Konum / Şehir Seç',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // GPS Hızlı Algılama Butonu
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _getCurrentLocationGps();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.starlightGold.withValues(alpha: 0.22),
                            const Color(0xFF6B4EE8).withValues(alpha: 0.25),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location_rounded, color: AppColors.starlightGold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '📍 Anlık GPS Konumumu Algıla (Otomatik)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Şehir veya ilçe ara (örn: Datça, İstanbul)...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.starlightGold),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        if (val.trim().isEmpty) {
                          filtered = List.from(WorldCitiesService.allCities);
                        } else {
                          final query = val.toLowerCase();
                          filtered = WorldCitiesService.allCities.where((c) {
                            return c.city.toLowerCase().contains(query) ||
                                c.country.toLowerCase().contains(query);
                          }).toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withValues(alpha: 0.05),
                        height: 1,
                      ),
                      itemBuilder: (ctx, idx) {
                        final city = filtered[idx];
                        final isSel = city.city == _currentCity.city;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Text(
                            city.city,
                            style: TextStyle(
                              color: isSel ? AppColors.starlightGold : Colors.white,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${city.country} • Lat: ${city.latitude.toStringAsFixed(2)}°, Lng: ${city.longitude.toStringAsFixed(2)}°',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                          trailing: isSel
                              ? const Icon(Icons.check_circle, color: AppColors.starlightGold)
                              : null,
                          onTap: () => Navigator.of(context).pop(city),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _currentCity = selected;
      });
      _recalculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cur = _dayInfo.currentHour;
    final prev = _dayInfo.previousHour;
    final next = _dayInfo.nextHour;

    List<PlanetaryHour> displayedHours;
    if (_selectedTab == 1) {
      displayedHours = _dayInfo.dayHours;
    } else if (_selectedTab == 2) {
      displayedHours = _dayInfo.nightHours;
    } else {
      displayedHours = _dayInfo.allHours;
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF130F26),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with City & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.starlightGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(_dayInfo.dayRulerSymbol, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_dayInfo.dayName} • ${_dayInfo.dayRulerPlanet} Günü',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '☀️ ${_dayInfo.sunriseFormatted} | 🌙 ${_dayInfo.sunsetFormatted}',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _selectCity,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.starlightGold.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.starlightGold.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: AppColors.starlightGold),
                                      const SizedBox(width: 2),
                                      Text(
                                        _dayInfo.cityName,
                                        style: const TextStyle(
                                          color: AppColors.starlightGold,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.arrow_drop_down, size: 12, color: AppColors.starlightGold),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: _isLocating ? null : _getCurrentLocationGps,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelMint.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.pastelMint.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _isLocating
                                          ? const SizedBox(
                                              width: 10,
                                              height: 10,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: AppColors.pastelMint,
                                              ),
                                            )
                                          : const Icon(Icons.my_location_rounded, size: 10, color: AppColors.pastelMint),
                                      const SizedBox(width: 3),
                                      const Text(
                                        'GPS',
                                        style: TextStyle(
                                          color: AppColors.pastelMint,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Önceki - ŞİMDİ - Sonraki Üçlü Hızlı Gezinme Çubuğu (Görsel 1 Tarzı)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    // Önceki
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ÖNCEKİ',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${prev.planetSymbol} ${prev.planetName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${prev.startFormatted}-${prev.endFormatted}',
                            style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.white12),
                    // ŞİMDİ
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ŞİMDİ AKTİF 🟢',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${cur.planetSymbol} ${cur.planetName} Saati',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${cur.startFormatted} - ${cur.endFormatted} • ${_dayInfo.minutesRemainingInCurrentHour} dk kaldı',
                              style: const TextStyle(
                                color: AppColors.starlightGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.white12),
                    // Sonraki
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'SONRAKİ',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${next.planetSymbol} ${next.planetName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${next.startFormatted}-${next.endFormatted}',
                            style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Aktif Saat Canlı Kartı (Glowing Card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.starlightGold.withValues(alpha: 0.22),
                      const Color(0xFF8A70FF).withValues(alpha: 0.20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.starlightGold.withValues(alpha: 0.65),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.starlightGold.withValues(alpha: 0.18),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cur.planetSymbol,
                          style: const TextStyle(
                            fontSize: 26,
                            fontFamilyFallback: ['sans-serif', 'Roboto'],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cur.planetName} Saati • ${cur.title}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cur.isDayHour ? "Gündüz" : "Gece"} ${cur.isDayHour ? cur.hourNumber : cur.hourNumber - 12}. Saati • ${cur.startFormatted} - ${cur.endFormatted}',
                                style: const TextStyle(color: AppColors.starlightGold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cur.energyDescription,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎯 ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              'En Uygun Eylemler: ${cur.suitableActivities}',
                              style: const TextStyle(
                                color: AppColors.pastelMint,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Sekme Seçici (Tümü 24, Gündüz 12, Gece 12)
              Row(
                children: [
                  _buildTabButton(0, 'Tümü (24)'),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Gündüz (12)'),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Gece (12)'),
                ],
              ),
              const SizedBox(height: 12),

              // Saat Listesi
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedHours.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final h = displayedHours[index];
                  final isCurrent = h.isCurrent;
                  final isExpanded = _expandedIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.starlightGold.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.starlightGold
                              : (isExpanded ? AppColors.starlightGold.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08)),
                          width: isCurrent ? 1.4 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                alignment: Alignment.center,
                                child: Text(
                                  h.planetSymbol,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamilyFallback: const ['sans-serif', 'Roboto'],
                                    color: isCurrent ? AppColors.starlightGold : Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${h.planetName} (${h.isDayHour ? 'Gündüz ${h.hourNumber}. Saat' : 'Gece ${h.hourNumber - 12}. Saat'})',
                                            style: TextStyle(
                                              color: isCurrent ? AppColors.starlightGold : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCurrent) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.starlightGold,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'AKTİF',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      h.title,
                                      style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${h.startFormatted} - ${h.endFormatted}',
                                style: TextStyle(
                                  color: isCurrent ? AppColors.starlightGold : Colors.white70,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                            const SizedBox(height: 8),
                            Text(
                              h.energyDescription,
                              style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.35),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '🎯 En Uygun: ${h.suitableActivities}',
                              style: const TextStyle(color: AppColors.pastelMint, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starlightGold : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
