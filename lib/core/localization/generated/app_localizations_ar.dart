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

  @override
  String get partyName => 'اسم البارتي';

  @override
  String get fast => 'سريع';

  @override
  String get standard => 'قياسي';

  @override
  String get roundDuration => 'مدة الجولة';

  @override
  String get numberOfRounds => 'عدد الجولات';

  @override
  String get creatingParty => 'جارٍ الإنشاء...';

  @override
  String get createParty => 'أنشئ البارتي';

  @override
  String get partyNameEmpty => 'يرجى إدخال اسم البارتي';

  @override
  String get partyNameTooShort => 'يجب أن يكون الاسم مكونًا من حرفين على الأقل';

  @override
  String get estimatedGameTime => 'وقت اللعب المقدر';

  @override
  String get partyCopied => 'تم نسخ رمز البارتي';

  @override
  String get leaveParty => 'مغادرة البارتي';

  @override
  String get leavePartyConfirm => 'هل أنت متأكد أنك تريد مغادرة البارتي؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get leave => 'مغادرة';

  @override
  String get players => 'اللاعبون';

  @override
  String waitingForPlayers(int minPlayersToStart) {
    return 'في انتظار $minPlayersToStart لاعبين على الأقل لبدء اللعبة';
  }

  @override
  String get startingGame => 'جارٍ بدء اللعبة...';

  @override
  String get startGame => 'ابدأ اللعبة';

  @override
  String get kickPlayer => 'طرد اللاعب';

  @override
  String get connectingToLobby => 'جارٍ الاتصال بالبارتي...';
}
