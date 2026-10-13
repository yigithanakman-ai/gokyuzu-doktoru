import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/predictive_astrology_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/world_cities_service.dart';

class SolarReturnModalContent extends StatefulWidget {
  final UserProfile profile;

  const SolarReturnModalContent({super.key, required this.profile});

  @override
  State<SolarReturnModalContent> createState() => _SolarReturnModalContentState();
}

class _SolarReturnModalContentState extends State<SolarReturnModalContent> {
  late String _selectedCity;
  late String _selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  List<CityLocation> _citySuggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.profile.birthCity.isNotEmpty ? widget.profile.birthCity : 'İstanbul';
    _selectedCountry = widget.profile.birthCountry.isNotEmpty ? widget.profile.birthCountry : 'Türkiye';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _citySuggestions = [];
        _isSearching = false;
      });
      return;
    }
    final results = WorldCitiesService.search(query, limit: 6);
    setState(() {
      _citySuggestions = results;
      _isSearching = true;
    });
  }

  void _selectCity(String city, String country) {
    setState(() {
      _selectedCity = city;
      _selectedCountry = country;
      _citySuggestions = [];
      _isSearching = false;
      _searchController.clear();
    });
  }

  Map<String, dynamic> _calculateSolarReturn(String city) {
    return PredictiveAstrologyService.calculateSolarReturn(
      profile: widget.profile,
      selectedCity: city,
      selectedCountry: _selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final solarData = _calculateSolarReturn(_selectedCity);
    final List<Map<String, dynamic>> aspects = List<Map<String, dynamic>>.from(solarData['aspects']);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF13111C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFD166), width: 1.2),
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
                    color: AppColors.starlightGold.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: AppColors.starlightGold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        () {
                          final returnYear = (solarData['returnYear'] as int?) ?? DateTime.now().year;
                          return 'Solar Return (Yıllık Öngörü) $returnYear - ${returnYear + 1}';
                        }(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starlightGold,
                        ),
                      ),
                      const Text(
                        'Doğum gününün geçirildiği şehre göre dinamik relokasyon analizi',
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
                // RELOCATION LOCATION SELECTOR
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A2B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.starlightGold.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: AppColors.starlightGold, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Doğum Gününün Geçirildiği Konum:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.starlightGold.withAlpha(35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedCity,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.starlightGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Doğum gününüzde bulunduğunuz enlem ve boylam Solar Yükselen burcunuzu ve Güneş\'in evini tamamen değiştirir.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),

                      // City Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchQueryChanged,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Farklı bir dünya şehri ara (örn: Osaka, Tokyo, Berlin, Tokat)...',
                          hintStyle: TextStyle(color: Colors.white.withAlpha(90), fontSize: 12),
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.starlightGold),
                          filled: true,
                          fillColor: Colors.black38,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                        ),
                      ),

                      // City suggestions list if searching
                      if (_isSearching && _citySuggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: _citySuggestions.map((c) {
                              return ListTile(
                                dense: true,
                                title: Text('${c.city}, ${c.country}',
                                    style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                                trailing: const Icon(Icons.north_west_rounded, size: 14, color: Colors.white54),
                                onTap: () => _selectCity(c.city, c.country),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      // Quick relocation chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickCityChip('Osaka', 'Japonya', '🇯🇵 Osaka'),
                            _buildQuickCityChip('Tokyo', 'Japonya', '🇯🇵 Tokyo'),
                            _buildQuickCityChip('İstanbul', 'Türkiye', '🇹🇷 İstanbul'),
                            _buildQuickCityChip('Berlin', 'Almanya', '🇩🇪 Berlin'),
                            _buildQuickCityChip('New York', 'ABD', '🇺🇸 New York'),
                            _buildQuickCityChip('Tokat', 'Türkiye', '🇹🇷 Tokat'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SOLAR RETURN RESULT CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.starlightGold.withAlpha(50),
                        const Color(0xFF1E1A2B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.starlightGold.withAlpha(120), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yıllık Yükselen (Solar ASC)',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                solarData['ascSign'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.starlightGold.withAlpha(80)),
                            ),
                            child: Text(
                              solarData['cityLabel'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 10),
                      Text(
                        solarData['themeTitle'],
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        solarData['sunHouseDesc'],
                        style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.explore_rounded, size: 16, color: AppColors.pastelMint),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                solarData['relocationNote'],
                                style: const TextStyle(fontSize: 11, color: AppColors.pastelMint),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Validation Assurance Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.pastelMint.withAlpha(90)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_outlined, size: 16, color: AppColors.pastelMint),
                          SizedBox(width: 8),
                          Text(
                            'Solar Return Doğruluğu Nasıl Teyit Edilir?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pastelMint,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Güneş Dönüşü haritası; Güneş\'in doğum anındaki tam boylam derecesine ulaştığı milisaniyelik anın ilgili şehrin enlem/boylam koordinatlarına göre hesaplanmasıdır. Swiss Ephemeris ve Astro.com standartlarıyla tam uyumludur.',
                        style: TextStyle(fontSize: 11.5, height: 1.45, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Note for full chart reference
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: AppColors.starlightGold),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '📌 Not: Burçlar, evler, açılar ve gezegenlerle ilgili detaylı açıklamalar "Tam Doğum Haritası" bölümünde yer almaktadır.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Text(
                  'Yılın Kilit Yaşam Alanları & Ev Yerleşimleri:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                ...aspects.map((asp) => _buildAspectItem(
                      aspect: asp['title'],
                      tag: asp['tag'],
                      desc: asp['desc'],
                      color: AppColors.starlightGold,
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCityChip(String city, String country, String label) {
    final isSelected = _selectedCity.toLowerCase() == city.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.black87 : Colors.white)),
        selected: isSelected,
        selectedColor: AppColors.starlightGold,
        backgroundColor: Colors.black26,
        onSelected: (val) {
          if (val) _selectCity(city, country);
        },
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
              Text(
                aspect,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
