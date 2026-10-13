import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/predictive_astrology_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/world_cities_service.dart';

class LunarReturnModalContent extends StatefulWidget {
  final UserProfile profile;

  const LunarReturnModalContent({super.key, required this.profile});

  @override
  State<LunarReturnModalContent> createState() => _LunarReturnModalContentState();
}

class _LunarReturnModalContentState extends State<LunarReturnModalContent> {
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

  Map<String, dynamic> _calculateLunarReturn(String city) {
    return PredictiveAstrologyService.calculateLunarReturn(
      profile: widget.profile,
      selectedCity: city,
      selectedCountry: _selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lunarData = _calculateLunarReturn(_selectedCity);
    final List<Map<String, dynamic>> aspects = List<Map<String, dynamic>>.from(lunarData['aspects']);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF13111C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33A0C4FF), width: 1.2),
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
                    color: AppColors.pastelBlue.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.nightlight_round, color: AppColors.pastelBlue, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lunar Return (Aylık Ay Dönüşü)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pastelBlue,
                        ),
                      ),
                      Text(
                        '27.3 günlük mikro-döngünün seçilen şehre göre hesaplanması',
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
                    border: Border.all(color: AppColors.pastelBlue.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: AppColors.pastelBlue, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Döngü Başlangıç Konumu:',
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
                              color: AppColors.pastelBlue.withAlpha(35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedCity,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pastelBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ay\'ın doğum derecesine kavuştuğu anda bulunduğunuz konum duygusal hava durumunuzu belirler.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),

                      // City Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchQueryChanged,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Şehir ara (örn: Osaka, Tokyo, Berlin, İstanbul)...',
                          hintStyle: TextStyle(color: Colors.white.withAlpha(90), fontSize: 12),
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.pastelBlue),
                          filled: true,
                          fillColor: Colors.black38,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                        ),
                      ),

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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickCityChip('Osaka', 'Japonya', '🇯🇵 Osaka'),
                            _buildQuickCityChip('Tokyo', 'Japonya', '🇯🇵 Tokyo'),
                            _buildQuickCityChip('İstanbul', 'Türkiye', '🇹🇷 İstanbul'),
                            _buildQuickCityChip('Berlin', 'Almanya', '🇩🇪 Berlin'),
                            _buildQuickCityChip('Tokat', 'Türkiye', '🇹🇷 Tokat'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // LUNAR RETURN RESULT CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pastelBlue.withAlpha(45),
                        const Color(0xFF1E1A2B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.pastelBlue.withAlpha(120), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.starlightGold.withAlpha(90)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, size: 14, color: AppColors.starlightGold),
                            const SizedBox(width: 6),
                            Text(
                              'Sabit Doğum Ayı: ${lunarData['natalMoonLabel']}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.starlightGold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.starlightGold.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lunarData['moonHouse'] as String,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.starlightGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Aylık Yükselen (Lunar ASC)',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.pastelMint.withAlpha(35),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.pastelMint.withAlpha(100), width: 0.8),
                                    ),
                                    child: Text(
                                      'Döngü: ${lunarData['returnDate']}',
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.pastelMint),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lunarData['ascSign'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pastelBlue,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.pastelBlue.withAlpha(80)),
                            ),
                            child: Text(
                              lunarData['cityLabel'],
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
                        lunarData['themeTitle'],
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lunarData['moonHouseDesc'],
                        style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
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
                      Icon(Icons.info_outline_rounded, size: 18, color: AppColors.pastelBlue),
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
                  'Bu Ayın Duygusal Odak Alanları & Transit Açılar:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                ...aspects.map((asp) => _buildAspectItem(
                      aspect: asp['title'],
                      tag: asp['tag'],
                      desc: asp['desc'],
                      color: AppColors.pastelBlue,
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
        selectedColor: AppColors.pastelBlue,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  aspect,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
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
