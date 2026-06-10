// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PinPoint';

  @override
  String get tagline => 'Drop a Pin. Rule the World.';

  @override
  String get appDescription =>
      'Challenge friends, pinpoint famous landmarks, earn points, and prove your geography skills worldwide.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get playAsGuest => 'Play as Guest';

  @override
  String get joinAParty => 'Join a Party';

  @override
  String get createAParty => 'Create a Party';

  @override
  String get or => 'OR';
}
