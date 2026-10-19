import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'storage_service.dart';
import 'predictive_astrology_service.dart';
import 'eclipses_service.dart';
import 'astrology_engine.dart';
import '../models/birth_chart_model.dart';

/// Gökyüzü Doktoru Profesyonel 10 Sayfalık Doğum Haritası ve Yaşam Rehberi Raporu (Word Formatı)
class PdfReportService {
  /// Font yükleme: Önce yerel assets/fonts/Arial, sonra sistem Arial, fallback Helvetica
  static Future<pw.Font> _loadFont(String assetPath, String systemPath, {bool isBold = false}) async {
    try {
      final file = File(assetPath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.Font.ttf(bytes.buffer.asByteData());
      }
    } catch (_) {}

    try {
      final sysFile = File(systemPath);
      if (await sysFile.exists()) {
        final bytes = await sysFile.readAsBytes();
        return pw.Font.ttf(bytes.buffer.asByteData());
      }
    } catch (_) {}

    try {
      final data = await rootBundle.load(assetPath);
      return pw.Font.ttf(data);
    } catch (_) {}

    return isBold ? pw.Font.helveticaBold() : pw.Font.helvetica();
  }

  /// 10 Sayfalık Word Tarzı Yalın, Temiz ve Türkçe Karakter Uyumlu PDF Raporu Üretir
  static Future<File> generate10PageBooklet({
    required UserProfile profile,
    bool autoOpen = false,
  }) async {
    final regularFont = await _loadFont(
      'assets/fonts/Arial-Regular.ttf',
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      isBold: false,
    );
    final boldFont = await _loadFont(
      'assets/fonts/Arial-Bold.ttf',
      '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
      isBold: true,
    );
    final italicFont = await _loadFont(
      'assets/fonts/Arial-Italic.ttf',
      '/System/Library/Fonts/Supplemental/Arial Italic.ttf',
      isBold: false,
    );
    final boldItalicFont = await _loadFont(
      'assets/fonts/Arial-BoldItalic.ttf',
      '/System/Library/Fonts/Supplemental/Arial Bold Italic.ttf',
      isBold: true,
    );

    final pdfTheme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
      boldItalic: boldItalicFont,
    );

    final pdf = pw.Document(
      theme: pdfTheme,
      title: 'Gökyüzü Doktoru - 10 Sayfalık Doğum Haritası ve Yaşam Rehberi Raporu',
      author: 'Gökyüzü Doktoru Astroloji ve Astronomi Sistemi',
    );

    final String birthDate = profile.birthDate.isNotEmpty ? profile.birthDate : '01.01.2000';
    final String birthTime = profile.birthTime.isNotEmpty ? profile.birthTime : '12:00';
    final String birthCity = profile.birthCity.isNotEmpty ? profile.birthCity : 'İstanbul';
    final String birthCountry = profile.birthCountry.isNotEmpty ? profile.birthCountry : 'Türkiye';
    final String name = profile.name.isNotEmpty ? profile.name : 'Danışan';

    // Gerçek Uygulama Motorundan Doğum Haritasını Hesapla (360° Çark & Ephemeris ile Tam Senkronizasyon)
    final realChart = AstrologyEngine.calculateChart(
      name: name,
      dateStr: birthDate,
      timeStr: birthTime,
      city: birthCity,
      country: birthCountry,
    );

    final String sun = realChart.sunSign.isNotEmpty ? realChart.sunSign : (profile.sunSign.isNotEmpty ? profile.sunSign : 'Koç');
    final String moon = realChart.moonSign.isNotEmpty ? realChart.moonSign : (profile.moonSign.isNotEmpty ? profile.moonSign : 'Boğa');
    final String rising = realChart.risingSign.isNotEmpty ? realChart.risingSign : (profile.risingSign.isNotEmpty ? profile.risingSign : 'İkizler');

    final syncedRawChart = <String, dynamic>{
      ...profile.rawChart,
      ...realChart.rawChart,
    };
    syncedRawChart['sun'] = realChart.sunFormatted;
    syncedRawChart['moon'] = realChart.moonFormatted;
    syncedRawChart['ascendant'] = realChart.risingFormatted;
    syncedRawChart['rising'] = realChart.risingFormatted;
    if (realChart.rawChart['mc'] != null) {
      syncedRawChart['mc'] = realChart.rawChart['mc'];
    }

    final effectiveProfile = UserProfile(
      name: name,
      birthDate: birthDate,
      birthTime: birthTime,
      birthCountry: birthCountry,
      birthCity: birthCity,
      sunSign: sun,
      moonSign: moon,
      risingSign: rising,
      gender: profile.gender,
      language: profile.language,
      isVip: profile.isVip,
      rawChart: syncedRawChart,
    );

    final placidusData = PredictiveAstrologyService.calculatePlacidusHouses(profile: effectiveProfile);
    final rawCusps = Map<int, String>.from(placidusData['cuspFormatted'] as Map);
    final cusps = rawCusps.map((k, v) => MapEntry(k, v.replaceAll(RegExp(r'[\u2648-\u2653\u2600-\u26FF]'), '').replaceAll('  ', ' ').trim()));
    final isDay = placidusData['isDayChart'] as bool;
    final interceptedList = List<Map<String, dynamic>>.from(placidusData['interceptedSigns']);

    final progData = PredictiveAstrologyService.calculateSecondaryProgressions(profile: effectiveProfile);
    final arcData = PredictiveAstrologyService.calculateSolarArc(profile: effectiveProfile);
    final zrData = PredictiveAstrologyService.calculateZodiacalReleasing(profile: effectiveProfile);
    final srData = PredictiveAstrologyService.calculateSolarReturn(profile: effectiveProfile, selectedCity: birthCity);
    final lrData = PredictiveAstrologyService.calculateLunarReturn(profile: effectiveProfile, selectedCity: birthCity);
    final eclipseAnalyses = EclipsesService.analyzePersonalEclipses(profile: effectiveProfile);
    final nextEclipse = eclipseAnalyses.isNotEmpty ? eclipseAnalyses.first : null;

    // Dinamik Gezegen Haritası ve Element Puanlaması (Standart: ASC, Güneş, Ay: 3 | Merkür, Venüs, Mars, Jüpiter, Satürn, MC: 1 | Toplam 15)
    final planetsMap = Map<String, PlanetPosition>.from(realChart.planets);
    effectiveProfile.rawChart.forEach((k, v) {
      if (v != null && !planetsMap.containsKey(k)) {
        final rawStr = v.toString();
        final sign = rawStr.replaceAll('(r)', '').trim().split(' ').last;
        planetsMap[k] = PlanetPosition(name: k, sign: sign, formatted: rawStr);
      }
    });

    final elemScores = BirthChartModel.calculateElementScores(planetsMap);
    final modScores = BirthChartModel.calculateModalityScores(planetsMap);

    final fireScore = elemScores['Ateş'] ?? 0;
    final earthScore = elemScores['Toprak'] ?? 0;
    final airScore = elemScores['Hava'] ?? 0;
    final waterScore = elemScores['Su'] ?? 0;

    final cardinalScore = modScores['Öncü'] ?? 0;
    final fixedScore = modScores['Sabit'] ?? 0;
    final mutableScore = modScores['Değişken'] ?? 0;

    // Word Stili Renk Paleti (Sade, Temiz, Resmi Belge Formatı)
    final textDark = PdfColor.fromHex('#1A202C'); // Ana metin: Koyu Grafit
    final textMuted = PdfColor.fromHex('#4A5568'); // İkincil metin: Nötr Gri
    final primaryNavy = PdfColor.fromHex('#1E3A8A'); // Başlıklar: Resmi Koyu Lacivert
    final borderGrey = PdfColor.fromHex('#CBD5E1'); // Çizgiler: Açık Gri
    final bgLight = PdfColor.fromHex('#F8FAFC'); // Kutu arka planı: Mat Beyaz / Gri
    final tableHeaderBg = PdfColor.fromHex('#E2E8F0'); // Tablo başlığı gri

    // Word Üst Bilgi (Header)
    pw.Widget buildHeader(String pageTitle, int pageNum) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: borderGrey, width: 0.8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'GÖKYÜZÜ DOKTORU | $pageTitle',
              style: pw.TextStyle(color: primaryNavy, fontSize: 9.5, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Sayfa $pageNum / 10',
              style: pw.TextStyle(color: textMuted, fontSize: 9),
            ),
          ],
        ),
      );
    }

    // Word Alt Bilgi (Footer)
    pw.Widget buildFooter(int pageNum) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 14),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: borderGrey, width: 0.8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Gökyüzü Doktoru Astroloji ve Astronomi Sistemi | Bolu, Türkiye',
              style: pw.TextStyle(color: textMuted, fontSize: 8),
            ),
            pw.Text(
              '$birthDate | $name',
              style: pw.TextStyle(color: textMuted, fontSize: 8),
            ),
          ],
        ),
      );
    }

    // Word Tarzı İçerik Bölüm Kutusu
    pw.Widget buildSectionCard(String title, String content, {String? englishSubtitle}) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: bgLight,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: borderGrey, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      color: primaryNavy,
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                if (englishSubtitle != null)
                  pw.Text(
                    englishSubtitle,
                    style: pw.TextStyle(color: textMuted, fontSize: 8.5, fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              content,
              style: pw.TextStyle(color: textDark, fontSize: 9, height: 1.4),
            ),
          ],
        ),
      );
    }

    // ==========================================
    // SAYFA 1: KAPAK & HARİTA KÜNYESİ (WORD FORMATI)
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final sunFormatted = realChart.sunFormatted;
          final moonFormatted = realChart.moonFormatted;
          final ascFormatted = realChart.risingFormatted.isNotEmpty ? realChart.risingFormatted : (cusps[1] ?? '$rising (Yükselen)');
          final mcFormatted = cusps[10] ?? realChart.rawChart['mc']?.toString() ?? 'MC 10. Ev';

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text(
                'GÖKYÜZÜ DOKTORU',
                style: pw.TextStyle(
                  color: primaryNavy,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Kişiselleştirilmiş Doğum Haritası ve Yaşam Rehberi Raporu',
                style: pw.TextStyle(color: textMuted, fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Personalized Natal Chart & Astronomical Life Navigation Report',
                style: pw.TextStyle(color: textMuted, fontSize: 9.5, fontStyle: pw.FontStyle.italic),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: primaryNavy, thickness: 1.5),
              pw.SizedBox(height: 16),

              pw.Text(
                '1. DANIŞAN KÜNYESİ & HARİTA TEKNİK PARAMETRELERİ',
                style: pw.TextStyle(color: primaryNavy, fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.8),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(3.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: tableHeaderBg),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Parametre (Parameter)', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Kişisel Değer (Value)', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy))),
                    ],
                  ),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Danışan Adı / Client Name', style: pw.TextStyle(fontSize: 9, color: textMuted))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(name, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Doğum Tarihi / Date of Birth', style: pw.TextStyle(fontSize: 9, color: textMuted))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(birthDate, style: pw.TextStyle(fontSize: 9, color: textDark))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Doğum Saati / Exact Birth Time', style: pw.TextStyle(fontSize: 9, color: textMuted))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$birthTime (Placidus Trigonometrik Kalibrasyon)', style: pw.TextStyle(fontSize: 9, color: textDark))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Doğum Konumu / Location', style: pw.TextStyle(fontSize: 9, color: textMuted))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$birthCity, $birthCountry', style: pw.TextStyle(fontSize: 9, color: textDark))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Harita Mezhebi / Diurnal-Nocturnal Sect', style: pw.TextStyle(fontSize: 9, color: textMuted))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(isDay ? 'Gündüz Haritası (Diurnal Sect - Güneş Ufkun Üstünde)' : 'Gece Haritası (Nocturnal Sect - Güneş Ufkun Altında)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryNavy))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Zodyak ve Ev Modeli / System', style: pw.TextStyle(fontSize: 9, color: textMuted))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(interceptedList.isNotEmpty ? 'Tropikal Placidus 360° (Kıstırılmış Burçlar: ${interceptedList.map((i) => i['sign']).join(", ")})' : 'Tropikal Placidus 360° (Tüm Ev Girişleri Açık)', style: pw.TextStyle(fontSize: 9, color: textDark))),
                  ]),
                ],
              ),

              pw.SizedBox(height: 18),
              pw.Text(
                '2. BÜYÜK ÜÇLÜ VE KİLİT AKS ÖZETİ',
                style: pw.TextStyle(color: primaryNavy, fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(color: bgLight, border: pw.Border.all(color: borderGrey, width: 0.8)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('GÜNEŞ (Sun)', style: pw.TextStyle(fontSize: 8.5, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(sunFormatted, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          pw.Text('Bilinçli Ego, İrade & Vizyon', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(color: bgLight, border: pw.Border.all(color: borderGrey, width: 0.8)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('AY (Moon)', style: pw.TextStyle(fontSize: 8.5, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(moonFormatted, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          pw.Text('Bilinçaltı, Duygu & Ruhsal Güvenlik', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(color: bgLight, border: pw.Border.all(color: borderGrey, width: 0.8)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('YÜKSELEN (ASC)', style: pw.TextStyle(fontSize: 8.5, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(ascFormatted, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          pw.Text('1. Ev Aksı | Yaşam Yolu', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(color: bgLight, border: pw.Border.all(color: borderGrey, width: 0.8)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('TEPE NOKTASI (MC)', style: pw.TextStyle(fontSize: 8.5, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(mcFormatted, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          pw.Text('10. Ev | Kariyer & Statü', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.8)),
                child: pw.Text(
                  'Bu rapor; Swiss Ephemeris ve Jean Meeus periyodik pertürbasyon algoritmaları kullanılarak, danışanın kesin doğum verileri doğrultusunda matematiksel ve astronomik olarak hesaplanmıştır.',
                  style: pw.TextStyle(fontSize: 8, color: textMuted, fontStyle: pw.FontStyle.italic),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              buildFooter(1),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 2: BÜYÜK ÜÇLÜ & MİZAÇ DERİN ANALİZİ
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final elementTable = 'Ateş: $fireScore / 15 Puan | Toprak: $earthScore / 15 Puan | Hava: $airScore / 15 Puan | Su: $waterScore / 15 Puan\n'
              'Nitelikler: Öncü: $cardinalScore / 15 Puan | Sabit: $fixedScore / 15 Puan | Değişken: $mutableScore / 15 Puan\n'
              '(Standart Puanlama: ASC: 3, Güneş: 3, Ay: 3 | Merkür: 1, Venüs: 1, Mars: 1, Jüpiter: 1, Satürn: 1, MC: 1 | Toplam 15 Puan. Geri kalan göstergeler ve asteroidler puan almaz.)';

          String elementSummary = 'Haritanızda dengeli bir dağılım görülmektedir.';
          if (waterScore >= 5 && airScore >= 5) {
            elementSummary = 'Haritanızda Su ve Hava elementleri baskındır. Su elementi derin sezgisel idrak, empati ve ruhsal bilgelik sağlarken; Hava elementi tarafsız analiz, iletişim dehası ve entelektüel köprüler kurma kabiliyeti verir.';
          } else if (fireScore >= 5) {
            elementSummary = 'Haritanızda Ateş elementi baskındır. Ateş elementi yüksek yaşam enerjisi, cesaret, liderlik ruhu ve engelleri aşma iradesi aşılar.';
          } else if (earthScore >= 5) {
            elementSummary = 'Haritanızda Toprak elementi baskındır. Toprak elementi somut sonuç alma disiplini, finansal sağduyu, sabır ve kalıcı başarı üretme gücü sağlar.';
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('BÜYÜK ÜÇLÜ & MİZAÇ SENTEZİ (THE BIG THREE)', 2),
              buildSectionCard(
                '1. Güneş Burcu ($sun) - Bilinçli Ego, Yaşam Enerjisi & İrade',
                'Güneş, ruhun bu dünyada gerçekleştirmek istediği bilinçli idealleri temsil eder. $sun burcundaki Güneş yerleşiminiz merhamet, yaratıcı vizyon ve derin sezgisel güçlerle donatılmıştır. Dünyevi yanılsamaların ötesine geçip evrensel birlik bilincini hayata aktarma kabiliyetine sahipsiniz. Ruhsal sınırlarınızı net çizmek ve enerjinizi odaklamak başarınızın anahtarıdır.',
                englishSubtitle: 'Sun in $sun | Core Identity',
              ),
              buildSectionCard(
                '2. Ay Burcu ($moon) - Duygusal Güvenlik, İçgüdüler & Bilinçaltı',
                'Ay, duygusal doyum ihtiyaçlarınızı ve stres anındaki otomatik psikolojik reflekslerinizi yönetir. $moon burcundaki Ay, güçlü tutkular, sarsılmaz sezgiler ve dönüştürücü bir içsel simya gücü verir. Kolay kolay güvenmezsiniz; ancak bir kez bağ kurduğunuzda sonuna kadar sadık kalırsınız. Krizleri avantaja çevirme ve psikolojik yüklerden arınma kabiliyetiniz çok yüksektir.',
                englishSubtitle: 'Moon in $moon | Emotional Architecture',
              ),
              buildSectionCard(
                '3. Yükselen Burç ($rising) - Dış Dünyaya Açılan Kapı & Yaşam Yolu',
                'Yükselen (ASC), doğum anında doğu ufkunda beliren burçtur ve dünyayı karşılama tarzınızı yönetir. $rising yükseleni, çevik zeka, merak, hızlı iletişim ve yüksek adaptasyon kabiliyeti sağlar. İnsanlar sizi konuşkan, esprili ve her konuda vizyon sahibi olarak tanır. Hayat amacınız, çeşitli bilgileri toplayıp sentezleyerek çevreye ilham vermektir.',
                englishSubtitle: 'Ascendant in $rising | 1st House Horizon',
              ),
              buildSectionCard(
                '4. Element & Nitelik Dengesi (Elements & Modalities)',
                '$elementTable\n\n$elementSummary',
                englishSubtitle: 'Accurate 15-Point Element Balance',
              ),
              pw.Spacer(),
              buildFooter(2),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 3: KİŞİSEL GEZEGENLER (ZİHİN, AŞK & EYLEM)
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final mercSign = planetsMap['mercury']?.sign ?? sun;
          final venusSign = planetsMap['venus']?.sign ?? 'Koç';
          final marsSign = planetsMap['mars']?.sign ?? rising;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('KİŞİSEL GEZEGENLER: ZİHİN, AŞK VE EYLEM MOTORU', 3),
              buildSectionCard(
                'Merkür ($mercSign) - Zihinsel İşleyiş, İletişim & Karar Mekanizması',
                'Merkür iletişim, öğrenme ve veri işleme biçiminizi şekillendirir. Merkür $mercSign burcunda iken mantık salt rasyonel kalıplarla değil, sezgisel ve resimsel düşünmeyle çalışır. Önsezileriniz mantığınızın çok önünde seyreder. Sözlerin arkasındaki gizli duyguları ve niyetleri anında hissedersiniz.',
                englishSubtitle: 'Mercury in $mercSign | Intuitive Intelligence',
              ),
              buildSectionCard(
                'Venüs ($venusSign) - Sevgi Dili, Değer Yargıları & Çekim Yasası',
                'Venüs sevgiyi ifade ediş tarzınızı, estetik tercihlerinizi ve finansal çekim enerjinizi yönetir. $venusSign burcundaki Venüs, ilişkilerde cesur, atılgan, tutkulu ve dobra olmayı gösterir. Peşinden koşulacak hedefleri seversiniz; monotonluktan hoşlanmazsınız. Aşkta doğallık, dinamizm ve bağımsızlık sizin vazgeçilmezinizdir.',
                englishSubtitle: 'Venus in $venusSign | Direct & Passionate Charm',
              ),
              buildSectionCard(
                'Mars ($marsSign) - Mücadele Gücü, Girişimcilik & Aksiyon Tarzı',
                'Mars hayatta ne için savaştığınızı ve enerjinizi nasıl harcadığınızı belirler. Mars $marsSign burcunda konumlandığında aksiyonlarınız hızlı, çok yönlü ve zihinseldir. Aynı anda birden fazla projeyi yürütebilir, engeller karşısında pratik çözümler üretebilir ve fikirlerinizi cesaretle savunabilirsiniz.',
                englishSubtitle: 'Mars in $marsSign | Versatile Strategic Action',
              ),
              pw.Spacer(),
              buildFooter(3),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 4: SOSYAL & JENERASYONEL GEZEGENLER
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final jupSign = planetsMap['jupiter']?.sign ?? 'Aslan';
          final satSign = planetsMap['saturn']?.sign ?? 'Kova';
          final uraSign = planetsMap['uranus']?.sign ?? 'Oğlak';
          final nepSign = planetsMap['neptune']?.sign ?? 'Oğlak';
          final pluSign = planetsMap['pluto']?.sign ?? 'Akrep';

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('SOSYAL & KOLEKTİF GEZEGENLER (BÜYÜME VE DÖNÜŞÜM)', 4),
              buildSectionCard(
                'Jüpiter ($jupSign) - Şans, Bolluk, Genişleme & Yaşam Felsefesi',
                'Jüpiter büyük iyicildir ve hayatta hangi alandan büyük kısmetler alacağınızı gösterir. $jupSign burcundaki Jüpiter; yaratıcılık, vizyoner projeler ve cömert liderlik yoluyla gelen zenginlikleri temsil eder. Kendi ışığınızı cesaretle sergilediğinizde evren size bolluk kapılarını ardına kadar açar.',
                englishSubtitle: 'Jupiter in $jupSign | Abundance & Vision',
              ),
              buildSectionCard(
                'Satürn ($satSign) - Karmik Sorumluluklar, Disiplin & Kalıcı İnşa',
                'Satürn karmik öğretmendir ve hayatta olgunlaşma alanınızı belirler. $satSign burcundaki Satürn; özgün akıl, kolektif sorumluluklar, teknoloji ve toplumsal sistemler inşa etme disiplini verir. Zamanla toplum yararına kalıcı ve sarsılmaz yapılar kurma kabiliyeti kazanırsınız.',
                englishSubtitle: 'Saturn in $satSign | Structured Vision',
              ),
              buildSectionCard(
                'Uranüs, Neptün & Plüton - Jenerasyonel Dönüşüm Güçleri',
                '- Uranüs ($uraSign): Geleneksel mesleki yapıları kökten yenileme ve çığır açan kariyer formatları kurma dehasıdır.\n'
                '- Neptün ($nepSign): Somut dünya ile manevi idealleri birleştirme, vizyoner hedefleri gerçeğe dönüştürme potansiyelidir.\n'
                '- Plüton ($pluSign): Ruhsal krizleri mutlak güç, stratejik otorite ve kişisel simyaya dönüştürme kudretidir.',
                englishSubtitle: 'Outer Planets: Uranus, Neptune & Pluto in Transmutation',
              ),
              pw.Spacer(),
              buildFooter(4),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 5: PLACIDUS EVLER SİSTEMİ (1 - 6. EVLER)
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('PLACIDUS EVLER SİSTEMİ (1. - 6. YAŞAM ALANLARI)', 5),
              buildSectionCard('1. Ev (${cusps[1] ?? 'ASC $rising'})', 'Benlik algısı, bedensel canlılık ve dış dünyayı karşılama enerjisi. Hızlı kavrayış ve meraklı dış aura.', englishSubtitle: '1st House | Self & Vitality'),
              buildSectionCard('2. Ev (${cusps[2] ?? '2. Ev'})', 'Maddi kaynaklar, taşınabilir birikimler ve özdeğer algısı. Güvende hissetme arzusuyla şekillenen finansal sezgiler.', englishSubtitle: '2nd House | Financial Security'),
              buildSectionCard('3. Ev (${cusps[3] ?? '3. Ev'})', 'İletişim trafiği, eğitimler, kardeşler ve yakın çevre. Etkileyici hitabet, yaratıcı yazarlık ve sahnede olma gücü.', englishSubtitle: '3rd House | Intellect & Communication'),
              buildSectionCard('4. Ev (${cusps[4] ?? 'IC 4. Ev'})', 'Kökler, aile, özel alan ve içsel huzur temeli. Ev ortamında düzen, titizlik, çalışma alanı kurma ve güvence.', englishSubtitle: '4th House | Roots & Inner Foundation'),
              buildSectionCard('5. Ev (${cusps[5] ?? '5. Ev'})', 'Yaratıcılık, aşk hayatı, risk alma ve hobiler. İlişkilerde zarafet, estetik zevkler ve romantik denge arayışı.', englishSubtitle: '5th House | Romance & Creativity'),
              buildSectionCard('6. Ev (${cusps[6] ?? '6. Ev'})', 'Günlük iş rutinleri, çalışma ortamı ve beden sağlığı. Derin konsantrasyon, kriz çözümü ve detoks ihtiyacı.', englishSubtitle: '6th House | Work Ethic & Health'),
              pw.Spacer(),
              buildFooter(5),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 6: PLACIDUS EVLER SİSTEMİ (7 - 12. EVLER)
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          String interceptedText = 'Haritanızdaki tüm zodyak evlerinin giriş dereceleri açık olup kıstırılmış burç bulunmamaktadır.';
          if (interceptedList.isNotEmpty) {
            interceptedText = 'Placidus ev sistemine göre haritanızda kıstırılmış burçlar yer almaktadır:\n${interceptedList.map((ic) => '• ${ic['sign']} (Ev ${ic['house']}) ↔ Karşıt: ${ic['oppositeSign']} (Ev ${ic['oppositeHouse']}): ${ic['desc']}').join('\n')}';
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('PLACIDUS EVLER SİSTEMİ (7. - 12. YAŞAM ALANLARI)', 6),
              buildSectionCard('7. Ev (${cusps[7] ?? 'DSC 7. Ev'})', 'Evlilik, ortaklıklar ve ikili sözleşmeler. Partnerde vizyon arayışı, felsefi uyum, özgürlük ve yabancı kültürler.', englishSubtitle: '7th House | Partnerships & Contracts'),
              buildSectionCard('8. Ev (${cusps[8] ?? '8. Ev'})', 'Ortak finans, yatırımlar, dönüşüm ve okült gizemler. Miras ve kriz yönetiminde ciddiyet, disiplinli büyüme.', englishSubtitle: '8th House | Transformation & Shared Wealth'),
              buildSectionCard('9. Ev (${cusps[9] ?? '9. Ev'})', 'Yüksek bilgelik, inanç sistemleri ve dünya görüşü. Sıradışı felsefeler, astroloji, teknoloji ve evrensel adalet.', englishSubtitle: '9th House | Higher Knowledge & Philosophy'),
              buildSectionCard('10. Ev (${cusps[10] ?? 'MC 10. Ev'})', 'Kariyer zirvesi, unvan ve hayat amacı. Topluma yenilikçi vizyonla rehberlik etme, ilham veren mesleki duruş.', englishSubtitle: '10th House | Career Summit & Status'),
              buildSectionCard('11. Ev (${cusps[11] ?? '11. Ev'})', 'Gelecek vizyonları, topluluklar ve sosyal ağlar. Hızlı organize olan dostluklar, kolektif projelerde öncü liderlik.', englishSubtitle: '11th House | Social Networks & Ideals'),
              buildSectionCard('12. Ev (${cusps[12] ?? '12. Ev'})', 'Bilinçaltı, rüyalar, manevi sığınak ve karmik çözülme. İçsel dinginlik, somut meditasyon ve derin ruhsal zenginlik.', englishSubtitle: '12th House | Subconscious & Inner Sanctuary'),
              buildSectionCard('Kıstırılmış Burçlar Analizi (Intercepted Signs)', interceptedText, englishSubtitle: 'Placidus Intercepted Zodiac Signs Architecture'),
              pw.Spacer(),
              buildFooter(6),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 7: GEZEGENLER ARASI AÇILAR & DİNAMİKLER
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('GEZEGENLER ARASI AÇILAR & GEOMETRİK ETKİLEŞİMLER', 7),
              buildSectionCard(
                '1. Güneş - Ay Uyumu (Harmonik Rezonans)',
                'Bilinçli ego ($sun Güneş) ile bilinçaltı duygularınızın ($moon Ay) frekans etkileşimidir. İçsel çatışmalardan uzak, hedefleriyle duyguları çelişmeyen, içsel huzuru ve sezgisel netliği yakalayan bir ruhsal güç sağlar.',
                englishSubtitle: 'Sun - Moon Dynamic • Harmonious Inner Synergy',
              ),
              buildSectionCard(
                '2. Merkür - Mars Etkileşimi (Zihinsel Çeviklik & Strateji)',
                'Fikirleri hemen aksiyona dökebilme kabiliyetidir. Tartışmalarda pratik mantık, espri yeteneği ve stratejik planlama dehasını açığa çıkarır. Zorlu problemleri zihinsel kıvraklıkla çözer.',
                englishSubtitle: 'Mercury - Mars Dynamic • Rapid Tactical Execution',
              ),
              buildSectionCard(
                '3. Venüs - Plüton Etkileşimi (Tutku & Derin Dönüşüm)',
                'İlişkilerde ya hep ya hiç yaklaşımı. Yüzeysel sevgilerden uzak durma, derin ruh bağları kurma ve ikili ilişkiler yoluyla köklü kişisel dönüşümler yaşama potansiyeli.',
                englishSubtitle: 'Venus - Pluto Dynamic • Profound Soul Connections',
              ),
              buildSectionCard(
                '4. Jüpiter - ASC Desteği (Karizma & Koruyucu Aura)',
                'Sosyal çevrede doğal bir güven ve saygı uyandırma yeteneği. Zor durumlardan kıl payı kurtulma ve hayatta ilahi bir koruma altında hissetme etkisi.',
                englishSubtitle: 'Jupiter - Ascendant Aspect • Divine Protection',
              ),
              pw.Spacer(),
              buildFooter(7),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 8: KARMİK DÜĞÜMLER, ŞİRON & TEKÂMÜL
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final nn = realChart.rawChart['north_node']?.toString() ?? effectiveProfile.rawChart['north_node']?.toString() ?? 'KAD Oğlak';
          final sn = realChart.rawChart['south_node']?.toString() ?? effectiveProfile.rawChart['south_node']?.toString() ?? 'GAD Yengeç';
          final chiron = realChart.rawChart['chiron']?.toString() ?? effectiveProfile.rawChart['chiron']?.toString() ?? 'Şiron Yengeç';

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('KARMİK DÜĞÜMLER, ŞİRON VE RUHSAL TEKÂMÜL', 8),
              buildSectionCard(
                'Kuzey Ay Düğümü ($nn) - Bu Yaşamdaki Tekâmül Yönü',
                'Ruhunuzun bu enkarnasyonda öğrenmesi gereken temel ders; sorumluluk almak, duygusal dalgalanmaları aşıp somut hedefler doğrultusunda sabırla ilerlemektir. Kendi ayakları üzerinde durabilme, duygusal bağımlılıkları aşma ve dünyaya kalıcı bir eser bırakma göreviniz vardır.',
                englishSubtitle: 'North Node • Maturity & Worldly Purpose',
              ),
              buildSectionCard(
                'Güney Ay Düğümü ($sn) - Geçmiş Yaşam Bagajı',
                'Geçmişten getirilen aşırı kırılganlık, aşırı korumacı refleksler ve çocuksu konfor alanına sığınma eğilimidir. Bu yaşamda geçmişin duygusal yüklerini serbest bırakıp bilge bir liderlik otoritesine evrilmeniz beklenir.',
                englishSubtitle: 'South Node • Emotional Release',
              ),
              buildSectionCard(
                'Şiron ($chiron) - Yaralı Şifacı & Empati Kapısı',
                'Ait olamama veya duygusal yetersizlik hissi üzerinden açılan manevi yaradır. Bu yarayı kabullenip iyileştirdiğinizde, başkalarının duygusal yaralarını sarabilen muazzam bir rehberlik ve şifa kanalına dönüşürsünüz.',
                englishSubtitle: 'Chiron • The Wounded Healer Channel',
              ),
              buildSectionCard(
                'Lilith (Kara Ay) - Bastırılmamış Güç & Bireysel Hakikat',
                'Toplumsal kalıplara başkaldıran vahşi ve özgür yanınız. Taviz vermeden kendi hakikatinizin arkasında durmanızı sağlayan içsel kadim güç.',
                englishSubtitle: 'Black Moon Lilith • Authentic Autonomy',
              ),
              pw.Spacer(),
              buildFooter(8),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 9: ZAMAN YÖNETİCİLERİ: PROGRESS, SOLAR ARC & RELEASING
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final now = DateTime.now();
          const months = [
            '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
            'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
          ];
          final dateStr = '${now.day} ${months[now.month]} ${now.year}';

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('ÖNGÖRÜ METODLARI: PROGRESS, SOLAR ARC & ZODIACAL RELEASING', 9),
              buildSectionCard(
                '1. İkincil İlerletim (Secondary Progressions - $dateStr / Solar Fire Motoru)',
                '1 Gün = 1 Yıl kuralına göre ruhun içsel psikolojik takvimidir. $birthCity koordinatlarında hesaplanan güncel değerler:\n'
                '- İlerletilmiş Ay (Progressed Moon): ${progData['progMoonFormatted']} (${(progData['currentTheme'] as Map)['desc']})\n'
                '- İlerletilmiş Yükselen (Progressed ASC): ${progData['progAscFormatted']} (Dış dünyaya duruş ve kişisel aura)\n'
                '- İlerletilmiş Tepe Noktası (Progressed MC): ${progData['progMcFormatted']} (Mesleki unvan ve kurumsal statü)\n'
                '- İlerletilmiş Güneş: ${progData['progSunFormatted']} (Karakter olgunlaşması)',
                englishSubtitle: 'Progressed Moon ${progData['progMoonFormatted']} | ASC ${progData['progAscFormatted']}',
              ),
              buildSectionCard(
                '2. Solar Arc Yönelimleri (${arcData['arcFormatted']} Güneş Yayı)',
                'Tüm harita doğumdan itibaren Güneş\'in ilerlediği yay (${arcData['arcFormatted']}) kadar yönlendirilmiştir:\n'
                '- Solar Arc Güneş: ${arcData['dirSunFormatted']} (Yaşam vizyonu ve idealler)\n'
                '- Solar Arc Ay: ${arcData['dirMoonFormatted']} (Duygusal derinlik ve ortaklıklar)\n'
                '- Solar Arc ASC: ${arcData['dirAscFormatted']} (Kişisel aura ve toplum önündeki duruş)\n'
                '- Solar Arc MC: ${arcData['dirMcFormatted']} (Kariyer zirvesi ve unvan)',
                englishSubtitle: 'Solar Arc Directions ${arcData['arcFormatted']} | Major Life Milestone Triggers',
              ),
              buildSectionCard(
                '3. Zodiacal Releasing (Helenistik Burç Salımı - Solar Fire Standartı)',
                'Ruh Noktası (${zrData['spiritSign']} - ${zrData['spiritFormatted']}) baz alınarak hesaplanan evreler:\n'
                '- Aktif Seviye 1 (L1): ${zrData['l1Sign']} (${zrData['l1StartDate']} - ${zrData['l1EndDate']}, ${zrData['l1DurationYears']} Yıllık Majör Döngü)\n'
                '- Aktif Seviye 2 (L2): ${zrData['l2Sign']}${zrData['isL2Loosing'] == true ? " (L - Sıçrama)" : ""} (${zrData['l2StartDate']} - ${zrData['l2EndDate']}, ${zrData['l2DurationMonths']} Ay)\n'
                '- Aktif Seviye 3 (L3): ${zrData['l3Sign']}${zrData['isL3Loosing'] == true ? " (L - Sıçrama)" : ""} (${zrData['l3StartDate']} - ${zrData['l3EndDate']}, ${zrData['l3Days']} Günlük Mikro Döngü)\n'
                '- Pik / Sıçrama Durumu: ${zrData['peakStatusText']} (${zrData['isPeak'] ? "Ruh Noktasına açısal doruk aksı" : "Büyüme ve hazırlık evresi"}).',
                englishSubtitle: 'Zodiacal Releasing L1-L2-L3 | Solar Fire Engine Compatible',
              ),
              buildSectionCard(
                '4. Yıllık Solar Return & Aylık Lunar Return Analizi',
                'Doğum haritasındaki kilit derecelere göre çıkarılan döngüsel geri dönüş haritaları:\n'
                '- Solar Return: Doğum Güneşi derecesine kilitli (${srData['natalSunDegreeLocked']}), Yıllık Yükselen (ASC): ${srData['returnAsc']}\n'
                '- Lunar Return: Doğum Ayı derecesine kilitli (${lrData['natalMoonDegreeLocked']}), Aylık Yükselen (ASC): ${lrData['returnAsc']}, Döngü Tarihi: ${lrData['returnDate']}',
                englishSubtitle: 'Solar & Lunar Return Degrees Locked Analysis',
              ),
              pw.Spacer(),
              buildFooter(9),
            ],
          );
        },
      ),
    );

    // ==========================================
    // SAYFA 10: HERMETİK REHBER, AY MENZİLİ & BÜTÜNSEL REÇETE
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader('KADERSEL TUTULMALAR, HERMETİK REHBER & BÜTÜNSEL SENTEZ', 10),
              if (nextEclipse != null)
                buildSectionCard(
                  '1. Kadersel Tutulma ve Saros Döngüsü (${nextEclipse.eclipse.dateFormatted} • ${nextEclipse.eclipse.fullTypeTitle} • ${nextEclipse.eclipse.degreeSignFormatted})',
                  'Tetiklenen Placidus Yaşam Aksı: ${nextEclipse.houseAxisTitle}\n'
                  '• Bireysel Ev Danışmanlığı: ${nextEclipse.personalHouseCounseling}\n'
                  '• 18 Yıllık Saros Yankısı: ${nextEclipse.sarosEchoMessage}\n'
                  '• Stratejik Yol Haritası: ${nextEclipse.strategicActionPlan}',
                  englishSubtitle: 'Upcoming Eclipse Activation | House ${nextEclipse.activatedHouse}',
                ),
              buildSectionCard(
                '2. Şans Noktası (Pars Fortuna) - Dünyevi Refah & Maddi Doyum Anahtarı',
                'Güneş, Ay ve Yükselen koordinatlarının harmonik bileşkesidir. Hayatta en çok doyum alacağınız ve kısmetin kendiliğinden akacağı alanı temsil eder. Sezgilerinize güvenip bilgelikle adım attığınızda karşınıza beklenmedik kapılar açılacaktır.',
                englishSubtitle: 'Part of Fortune | Worldly Prosperity Harmonic',
              ),
              buildSectionCard(
                '3. Canlı Transit Ay Menzili (28 Lunar Mansions & Hermetik Durak)',
                'Ay\'ın gökyüzündeki gerçek zamanlı derecesine göre belirlenen 28 Hermetik menzil; günlük stratejik kararların, sözleşmelerin ve ruhsal odaklanmanın ideal zamanlamasını sunar. Ay döngülerinize göre aksiyon almak veriminizi katlar.',
                englishSubtitle: '28 Lunar Mansions | Real-time Moon Ingress Timing',
              ),
              buildSectionCard(
                '4. Bütünsel Kozmik Reçete (Doğal Taşlar, Frekanslar & Yaşam Tavsiyeleri)',
                '- Uyumlu Doğal Taşlar: Akuamarin (Zihin berraklığı), Ametist (Ruhsal koruma), Labradorit (Aura kalkanı).\n'
                '- Rezonans Frekansları: 528 Hz (Dönüşüm ve DNA şifası) ve 432 Hz (Evrensel ahenk).\n'
                '- Odak Enerji Merkezleri: Boğaz Çakrası (Doğru ve etkili ifade) ve Üçüncü Göz (Yüksek sezgisel kavrayış).\n'
                '- Altın Kural: Kendi hakikatinizi ifade etmekten asla çekinmeyin; gökyüzü cesur adımları destekler.',
                englishSubtitle: 'Holistic Blueprint: Crystals, Frequencies & Energy Centers',
              ),
              pw.Spacer(),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  border: pw.Border.all(color: borderGrey, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Gökyüzü Doktoru Astroloji ve Astronomi Yazılımı', style: pw.TextStyle(color: textMuted, fontSize: 8.5)),
                    pw.Text('Sertifikalı Bireysel Astrolojik Arşiv Raporu', style: pw.TextStyle(color: primaryNavy, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              buildFooter(10),
            ],
          );
        },
      ),
    );

    // Save PDF to Documents Directory or Android Downloads
    Directory outputDir;
    try {
      if (Platform.isAndroid) {
        // Android için önce doğrudan telefonun genel İndirilenler (Download) klasörünü hedefle
        final publicDownloadDir = Directory('/storage/emulated/0/Download');
        if (publicDownloadDir.existsSync()) {
          outputDir = publicDownloadDir;
        } else {
          final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
          if (extDirs != null && extDirs.isNotEmpty) {
            outputDir = extDirs.first;
          } else {
            outputDir = await getApplicationDocumentsDirectory();
          }
        }
      } else {
        outputDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      outputDir = Directory('${Platform.environment['HOME'] ?? '.'}/Desktop');
    }

    final safeName = name.replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]+'), '').replaceAll(RegExp(r'\s+'), '_');
    final fileName = 'Gokyuzu_Doktoru_${safeName.isEmpty ? "Danisan" : safeName}_10_Sayfalik_Rapor.pdf';
    final file = File('${outputDir.path}/$fileName');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    // Android için yedek kopya: Eğer app-specific alana yazıldıysa, genel Download'a da kopyala
    if (Platform.isAndroid) {
      try {
        final publicFile = File('/storage/emulated/0/Download/$fileName');
        if (publicFile.path != file.path) {
          await publicFile.writeAsBytes(bytes);
        }
      } catch (e) {
        debugPrint('Android public download kopyalama hatası: $e');
      }
    }

    // Masaüstü sistemler (macOS / Windows / Linux) için Masaüstü ve İndirilenler kopyası
    try {
      final homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        final desktopFile = File('$homeDir/Desktop/$fileName');
        await desktopFile.writeAsBytes(bytes);
        final downloadsFile = File('$homeDir/Downloads/$fileName');
        await downloadsFile.writeAsBytes(bytes);

        // Kullanıcı isteğine göre otomatik aç
        if (autoOpen && Platform.isMacOS) {
          Process.run('open', [desktopFile.path]);
        }
      }
    } catch (_) {}

    return file;
  }

  /// PDF raporunu sistem varsayılan PDF görüntüleyicisinde açar (Android/iOS/macOS)
  static Future<bool> openPdf(File file) async {
    try {
      if (Platform.isMacOS) {
        final res = await Process.run('open', [file.path]);
        return res.exitCode == 0;
      } else {
        final result = await OpenFilex.open(file.path);
        if (result.type == ResultType.done) {
          return true;
        } else {
          debugPrint('OpenFilex sonucu: ${result.message}, Paylaşım sayfasına yönlendiriliyor');
          await sharePdf(file);
          return true;
        }
      }
    } catch (e) {
      debugPrint('PDF açma hatası: $e, Paylaşım sayfasına yönlendiriliyor');
      try {
        await sharePdf(file);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// PDF raporunu dışa aktarır / paylaşır (WhatsApp, Google Drive, Dosyalar vb.)
  static Future<void> sharePdf(File file) async {
    try {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Gökyüzü Doktoru 10 Sayfalık Doğum Haritası ve Yaşam Rehberi Raporu',
      );
    } catch (e) {
      debugPrint('PDF paylaşma hatası: $e');
    }
  }
}

