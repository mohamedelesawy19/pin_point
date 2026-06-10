// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'PinPoint';

  @override
  String get tagline => 'ضع دبوسك... وسيطر على العالم.';

  @override
  String get appDescription =>
      'نافس أصدقاءك، وحدد مواقع أشهر المعالم، واجمع النقاط، وأثبت مهاراتك الجغرافية.';

  @override
  String get continueWithGoogle => 'متابعة مع جوجل';

  @override
  String get playAsGuest => 'العب كضيف';

  @override
  String get joinAParty => 'انضم إلى بارتي';

  @override
  String get createAParty => 'أنشئ بارتي';

  @override
  String get or => 'أو';
}
