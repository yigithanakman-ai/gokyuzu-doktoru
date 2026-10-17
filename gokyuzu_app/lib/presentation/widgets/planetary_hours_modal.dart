import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/planetary_hours_service.dart';
import '../../data/services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _dayInfo = PlanetaryHoursService.calculatePlanetaryHours();
  }

  @override
  Widget build(BuildContext context) {
    final cur = _dayInfo.currentHour;

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
              // Header Row
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
                          Text(
                            '☀️ Doğuş: ${_dayInfo.sunriseFormatted} | 🌙 Batış: ${_dayInfo.sunsetFormatted}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.starlightGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ŞU ANDA AKTİF SAAT 🟢',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${cur.startFormatted} - ${cur.endFormatted}',
                          style: const TextStyle(
                            color: AppColors.starlightGold,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          cur.planetSymbol,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${cur.planetName} Saati • ${cur.title}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
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
              const SizedBox(height: 20),

              // 24 Saatlik Akış Başlığı
              const Text(
                'Günün 24 Gezegen Saati Zaman Çizelgesi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Antik Keldani gökyüzü dizilimine göre gün doğumundan ertesi gün doğumuna kadar olan saatler',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 12),

              // Saat Listesi (Gündüz & Gece)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dayInfo.allHours.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final h = _dayInfo.allHours[index];
                  final isCurrent = h.isCurrent;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.starlightGold.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.starlightGold
                            : Colors.white.withValues(alpha: 0.08),
                        width: isCurrent ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text(
                            h.planetSymbol,
                            style: TextStyle(
                              fontSize: 18,
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
                                  Text(
                                    '${h.planetName} (${h.isDayHour ? 'Gündüz ${h.hourNumber}. Saat' : 'Gece ${h.hourNumber - 12}. Saat'})',
                                    style: TextStyle(
                                      color: isCurrent ? AppColors.starlightGold : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
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
                              ),
                            ],
                          ),
                        ),
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
}
