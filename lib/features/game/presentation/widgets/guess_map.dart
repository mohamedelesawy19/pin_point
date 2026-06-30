import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Dumb, stateful map widget used both for guessing (enabled) and for
/// reviewing results (disabled, with the actual location shown).
///
/// It owns only transient interaction state (the marker the user is
/// currently looking at); it does not know anything about rounds, scoring,
/// or blocs.
class GuessMap extends StatefulWidget {
  const GuessMap({
    super.key,
    this.initialGuess,
    this.actualLocation,
    this.enabled = true,
    this.onGuessChanged,
  });

  final LatLng? initialGuess;
  final LatLng? actualLocation;
  final bool enabled;
  final ValueChanged<LatLng>? onGuessChanged;

  @override
  State<GuessMap> createState() => _GuessMapState();
}

class _GuessMapState extends State<GuessMap> {
  late final MapController _mapController;
  LatLng? _guess;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _guess = widget.initialGuess;
  }

  @override
  void didUpdateWidget(covariant GuessMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialGuess != widget.initialGuess) {
      _guess = widget.initialGuess;
      _recenterOnGuess();
    }
  }

  void _recenterOnGuess() {
    final guess = _guess;
    if (guess == null) return;
    // The MapController is only attached after the first frame, so make
    // sure we don't try to move it before that.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(guess, _mapController.camera.zoom);
    });
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (!widget.enabled) return;
    setState(() => _guess = point);
    widget.onGuessChanged?.call(point);
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (_guess != null)
        Marker(
          point: _guess!,
          width: 36,
          height: 36,
          child: const Icon(
            Icons.location_pin,
            color: Colors.redAccent,
            size: 36,
          ),
        ),
      if (widget.actualLocation != null)
        Marker(
          point: widget.actualLocation!,
          width: 34,
          height: 34,
          child: Icon(
            Icons.flag_circle_rounded,
            color: Colors.green.shade600,
            size: 32,
          ),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter:
              widget.initialGuess ??
              widget.actualLocation ??
              const LatLng(20, 0),
          initialZoom:
              (widget.initialGuess != null || widget.actualLocation != null)
              ? 3.5
              : 1.4,
          minZoom: 1.4,
          maxZoom: 18,
          interactionOptions: const InteractionOptions(
            flags:
                InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.scrollWheelZoom,
          ),
          onTap: _handleTap,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://a.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.pin_point',
          ),
          if (_guess != null && widget.actualLocation != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [_guess!, widget.actualLocation!],
                  strokeWidth: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
