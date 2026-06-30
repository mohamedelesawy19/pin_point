import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pin_point/features/game/presentation/widgets/guess_map.dart';

void main() {
  Widget createWidget({
    LatLng? initialGuess,
    LatLng? actualLocation,
    bool enabled = true,
    ValueChanged<LatLng>? onGuessChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GuessMap(
          initialGuess: initialGuess,
          actualLocation: actualLocation,
          enabled: enabled,
          onGuessChanged: onGuessChanged,
        ),
      ),
    );
  }

  group('GuessMap', () {
    testWidgets('renders FlutterMap', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('does not render MarkerLayer when there are no markers', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(MarkerLayer), findsNothing);
    });

    testWidgets('renders guess marker', (tester) async {
      await tester.pumpWidget(createWidget(initialGuess: const LatLng(30, 31)));

      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byIcon(Icons.location_pin), findsOneWidget);
    });

    testWidgets('renders actual location marker', (tester) async {
      await tester.pumpWidget(
        createWidget(actualLocation: const LatLng(40, 20)),
      );

      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byIcon(Icons.flag_circle_rounded), findsOneWidget);
    });

    testWidgets('renders both markers and polyline', (tester) async {
      await tester.pumpWidget(
        createWidget(
          initialGuess: const LatLng(30, 31),
          actualLocation: const LatLng(35, 20),
        ),
      );

      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);

      expect(find.byIcon(Icons.location_pin), findsOneWidget);
      expect(find.byIcon(Icons.flag_circle_rounded), findsOneWidget);
    });

    testWidgets('updates guess marker when initialGuess changes', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(initialGuess: const LatLng(10, 10)));

      expect(find.byIcon(Icons.location_pin), findsOneWidget);

      await tester.pumpWidget(createWidget(initialGuess: const LatLng(50, 50)));

      await tester.pump();

      expect(find.byIcon(Icons.location_pin), findsOneWidget);
    });

    testWidgets('does not render PolylineLayer unless both locations exist', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(initialGuess: const LatLng(10, 10)));

      expect(find.byType(PolylineLayer), findsNothing);

      await tester.pumpWidget(
        createWidget(actualLocation: const LatLng(20, 20)),
      );

      expect(find.byType(PolylineLayer), findsNothing);
    });
  });
}
