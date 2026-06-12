import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/party/domain/entities/party_settings.dart';

void main() {
  group('PartySettings', () {
    test('supports value equality', () {
      expect(
        const PartySettings(roundDurationSeconds: 30, totalRounds: 5),
        equals(const PartySettings(roundDurationSeconds: 30, totalRounds: 5)),
      );
    });

    test('props are correct', () {
      const settings = PartySettings(roundDurationSeconds: 30, totalRounds: 5);

      expect(settings.props, [30, 5]);
    });
  });
}
