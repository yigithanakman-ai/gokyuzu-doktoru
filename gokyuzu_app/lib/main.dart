import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_theme.dart';
import 'data/services/app_translation_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTranslationService.init();
  try {
    await NotificationService.init();
  } catch (_) {}
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await MobileAds.instance.initialize();
    } catch (_) {}
  }
  try {
    await initializeDateFormatting('tr_TR', null);
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('ja_JP', null);
  } catch (_) {}
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GokyuzuDoktoruApp());
}

class GokyuzuDoktoruApp extends StatelessWidget {
  const GokyuzuDoktoruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslationService.currentLangNotifier,
      builder: (context, currentLang, _) {
        final locale = currentLang == 'en'
            ? const Locale('en', 'US')
            : (currentLang == 'ja'
                ? const Locale('ja', 'JP')
                : const Locale('tr', 'TR'));

        return MaterialApp(
          key: ValueKey(currentLang),
          title: AppTranslationService.tr('app_title'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: locale,
          supportedLocales: const [
            Locale('tr', 'TR'),
            Locale('en', 'US'),
            Locale('ja', 'JP'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
