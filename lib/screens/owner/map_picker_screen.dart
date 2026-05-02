import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PickedLocation {
  final String address;
  final double latitude;
  final double longitude;

  const PickedLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  Offset _pinPosition = const Offset(0.58, 0.42);
  PickedLocation _selectedLocation = const PickedLocation(
    address: 'New Cairo, Cairo',
    latitude: 30.0074,
    longitude: 31.4913,
  );

  final List<PickedLocation> _quickLocations = const [
    PickedLocation(
      address: 'New Cairo, Cairo',
      latitude: 30.0074,
      longitude: 31.4913,
    ),
    PickedLocation(
      address: 'Nasr City, Cairo',
      latitude: 30.0561,
      longitude: 31.3300,
    ),
    PickedLocation(
      address: 'Maadi, Cairo',
      latitude: 29.9602,
      longitude: 31.2569,
    ),
    PickedLocation(
      address: 'Sheikh Zayed, Giza',
      latitude: 30.0131,
      longitude: 30.9765,
    ),
    PickedLocation(
      address: '6 October, Giza',
      latitude: 29.9285,
      longitude: 30.9188,
    ),
  ];

  void _pickFromMap(TapDownDetails details, BoxConstraints constraints) {
    final local = details.localPosition;
    final dx = (local.dx / constraints.maxWidth).clamp(0.0, 1.0).toDouble();
    final dy = (local.dy / constraints.maxHeight).clamp(0.0, 1.0).toDouble();

    final latitude = 30.18 - (dy * 0.35);
    final longitude = 30.85 + (dx * 0.75);

    setState(() {
      _pinPosition = Offset(dx, dy);
      _selectedLocation = PickedLocation(
        address:
            'Selected point (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
        latitude: latitude,
        longitude: longitude,
      );
    });
  }

  void _selectQuickLocation(PickedLocation location) {
    final dx = ((location.longitude - 30.85) / 0.75).clamp(0.0, 1.0).toDouble();
    final dy = ((30.18 - location.latitude) / 0.35).clamp(0.0, 1.0).toDouble();

    setState(() {
      _selectedLocation = location;
      _pinPosition = Offset(dx, dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tap on the map or choose a common area.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) =>
                          _pickFromMap(details, constraints),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F2EF),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Stack(
                          children: [
                            const Positioned.fill(child: _SimpleMapPaint()),
                            Positioned(
                              left:
                                  (_pinPosition.dx * constraints.maxWidth) - 18,
                              top:
                                  (_pinPosition.dy * constraints.maxHeight) -
                                  38,
                              child: const Icon(
                                Icons.location_pin,
                                color: AppTheme.error,
                                size: 42,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickLocations.map((location) {
                  final isSelected =
                      location.address == _selectedLocation.address;
                  return ChoiceChip(
                    label: Text(location.address),
                    selected: isSelected,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.14),
                    onSelected: (_) => _selectQuickLocation(location),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedLocation.address,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Use This Location'),
                onPressed: () => Navigator.pop(context, _selectedLocation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleMapPaint extends StatelessWidget {
  const _SimpleMapPaint();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SimpleMapPainter());
  }
}

class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final minorRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.74)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final parkPaint = Paint()..color = const Color(0xFFCFE8D7);
    final waterPaint = Paint()..color = const Color(0xFFBFE0E6);

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.22),
      size.width * 0.18,
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.08,
          size.width * 0.26,
          size.height * 0.22,
        ),
        const Radius.circular(28),
      ),
      waterPaint,
    );

    final mainPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.42,
        size.width * 0.88,
        size.height * 0.30,
      );
    canvas.drawPath(mainPath, roadPaint);

    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.10),
      Offset(size.width * 0.72, size.height * 0.86),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.48),
      Offset(size.width * 0.92, size.height * 0.62),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.10),
      Offset(size.width * 0.32, size.height * 0.88),
      minorRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
