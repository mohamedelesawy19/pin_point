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

  @override
  String get partyName => 'Party Name';

  @override
  String get fast => 'Fast';

  @override
  String get standard => 'Standard';

  @override
  String get roundDuration => 'Round Duration';

  @override
  String get numberOfRounds => 'Number of Rounds';

  @override
  String get creatingParty => 'Creating…';

  @override
  String get createParty => 'Create Party';

  @override
  String get partyNameEmpty => 'Please enter a party name';

  @override
  String get partyNameTooShort => 'Name must be at least 2 characters';

  @override
  String get estimatedGameTime => 'Estimated game time';

  @override
  String get partyCopied => 'Party code copied to clipboard';

  @override
  String get leaveParty => 'Leave Party';

  @override
  String get leavePartyConfirm => 'Are you sure you want to leave the party?';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

  @override
  String get players => 'Players';

  @override
  String waitingForPlayers(int minPlayersToStart) {
    return 'Waiting for at least $minPlayersToStart players to start';
  }

  @override
  String get startingGame => 'Starting game...';

  @override
  String get startGame => 'Start Game';

  @override
  String get kickPlayer => 'Kick Player';

  @override
  String get connectingToLobby => 'Connecting to lobby...';
}
