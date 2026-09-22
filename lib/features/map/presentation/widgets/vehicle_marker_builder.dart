import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleMarkerBuilder {
  VehicleMarkerBuilder._();

  static const Color busColor = Color(0xFF1E6FF2);
  static const Color privateColor = Color(0xFFFB8C00);

  static final Map<String, Future<BitmapDescriptor>> _cache = {};

  static const List<String> tipos = ['bus', 'microbus', 'taxi', 'car', 'van'];

  static Future<BitmapDescriptor> markerFor(String tipoCodigo) {
    return _cache.putIfAbsent(tipoCodigo, () => _build(tipoCodigo));
  }

  static Future<void> preload() async {
    await Future.wait(tipos.map(markerFor));
  }

  static bool isParticular(String tipoCodigo) {
    switch (tipoCodigo) {
      case 'taxi':
      case 'car':
      case 'van':
        return true;
      default:
        return false;
    }
  }

  static String classification(String tipoCodigo) =>
      isParticular(tipoCodigo) ? 'car' : 'bus';

  static IconData _iconFor(String tipoCodigo) {
    switch (tipoCodigo) {
      case 'van':
        return Icons.airport_shuttle_rounded;
      case 'taxi':
        return Icons.local_taxi_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_bus_rounded;
    }
  }

  static Future<BitmapDescriptor> _build(String tipoCodigo) async {
    const size = 60.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final color = isParticular(tipoCodigo) ? privateColor : busColor;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, fill);

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, border);

    final icon = _iconFor(tipoCodigo);
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 30,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        (size - painter.width) / 2,
        (size - painter.height) / 2 + 1,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}