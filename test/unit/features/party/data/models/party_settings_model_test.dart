import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/party/data/models/party_settings_model.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';

void main() {
  group('PartySettingsModel', () {
    const model = PartySettingsModel(roundDurationSeconds: 60, totalRounds: 5);

    const entity = PartySettings(roundDurationSeconds: 60, totalRounds: 5);

    test('supports value equality', () {
      expect(
        model,
        const PartySettingsModel(roundDurationSeconds: 60, totalRounds: 5),
      );
    });

    test('fromJson should return a valid model', () {
      // Arrange
      final json = <String, dynamic>{
        'roundDurationSeconds': 60,
        'totalRounds': 5,
      };

      // Act
      final result = PartySettingsModel.fromJson(json);

      // Assert
      expect(result, model);
    });

    test('toJson should return a valid json map', () {
      // Act
      final result = model.toJson();

      // Assert
      expect(result, <String, dynamic>{
        'roundDurationSeconds': 60,
        'totalRounds': 5,
      });
    });

    test('fromEntity should create model from entity', () {
      // Act
      final result = PartySettingsModel.fromEntity(entity);

      // Assert
      expect(result, model);
    });

    test('toEntity should return domain entity', () {
      // Act
      final result = model.toEntity();

      // Assert
      expect(result, entity);
    });
  });
}
