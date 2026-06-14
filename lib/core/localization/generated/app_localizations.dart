import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'PinPoint'**
  String get appName;

  /// The tagline of the application, displayed on the login screen
  ///
  /// In en, this message translates to:
  /// **'Drop a Pin. Rule the World.'**
  String get tagline;

  /// A brief description of the application, used for app store listings and promotional materials
  ///
  /// In en, this message translates to:
  /// **'Challenge friends, pinpoint famous landmarks, earn points, and prove your geography skills worldwide.'**
  String get appDescription;

  /// Text for the button that allows users to sign in with their Google account
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Text for the button that allows users to play without signing in
  ///
  /// In en, this message translates to:
  /// **'Play as Guest'**
  String get playAsGuest;

  /// Text for the button that allows users to join an existing game party
  ///
  /// In en, this message translates to:
  /// **'Join a Party'**
  String get joinAParty;

  /// Text for the button that allows users to create a new game party
  ///
  /// In en, this message translates to:
  /// **'Create a Party'**
  String get createAParty;

  /// Text displayed between the 'Join a Party' and 'Create a Party' buttons on the home screen
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Label for the party name input field in the create party screen
  ///
  /// In en, this message translates to:
  /// **'Party Name'**
  String get partyName;

  /// Label for the fast round duration option in the create party screen
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// Label for the standard round duration option in the create party screen
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// Label for the round duration selection in the create party screen
  ///
  /// In en, this message translates to:
  /// **'Round Duration'**
  String get roundDuration;

  /// Label for the number of rounds selection in the create party screen
  ///
  /// In en, this message translates to:
  /// **'Number of Rounds'**
  String get numberOfRounds;

  /// Text displayed on the create party button when the party is being created
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get creatingParty;

  /// Text displayed on the create party button
  ///
  /// In en, this message translates to:
  /// **'Create Party'**
  String get createParty;

  /// Error message displayed when the party name input field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a party name'**
  String get partyNameEmpty;

  /// Error message displayed when the party name input field is less than 2 characters
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get partyNameTooShort;

  /// Label for the estimated game time displayed in the game summary banner
  ///
  /// In en, this message translates to:
  /// **'Estimated game time'**
  String get estimatedGameTime;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
