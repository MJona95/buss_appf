import 'dart:math' as math;

import '../entities/ruta_mapa.dart';

class RouteGeometry {
  static const earthRadiusKm = 6371.0;

  static double haversineKm(GeoPunto a, GeoPunto b) {
    const toRad = math.pi / 180;
    final dLat = (b.latitud - a.latitud) * toRad;
    final dLng = (b.longitud - a.longitud) * toRad;
    final lat1 = a.latitud * toRad;
    final lat2 = b.latitud * toRad;
    final h = _sin2(dLat / 2) + _cos(lat1) * _cos(lat2) * _sin2(dLng / 2);
    return 2 * earthRadiusKm * _asin(_sqrt(h).clamp(0, 1));
  }

  static double totalKm(List<GeoPunto> puntos) {
    if (puntos.length < 2) return 0;
    var sum = 0.0;
    for (var i = 1; i < puntos.length; i++) {
      sum += haversineKm(puntos[i - 1], puntos[i]);
    }
    return sum;
  }

  static GeoPunto interpolate(List<GeoPunto> puntos, double distanceKm) {
    if (puntos.isEmpty) return const GeoPunto(latitud: 0, longitud: 0);
    if (puntos.length == 1 || distanceKm <= 0) return puntos.first;

    var remaining = distanceKm;
    for (var i = 1; i < puntos.length; i++) {
      final segment = haversineKm(puntos[i - 1], puntos[i]);
      if (segment <= 0) continue;
      if (remaining <= segment) {
        final t = remaining / segment;
        return GeoPunto(
          latitud: puntos[i - 1].latitud +
              (puntos[i].latitud - puntos[i - 1].latitud) * t,
          longitud: puntos[i - 1].longitud +
              (puntos[i].longitud - puntos[i - 1].longitud) * t,
        );
      }
      remaining -= segment;
    }
    return puntos.last;
  }

  static int indiceTruncado(List<GeoPunto> puntos, double distanceKm) {
    if (puntos.length < 2 || distanceKm <= 0) return 0;
    var remaining = distanceKm;
    for (var i = 1; i < puntos.length; i++) {
      final segment = haversineKm(puntos[i - 1], puntos[i]);
      if (segment <= 0) continue;
      if (remaining <= segment) return i;
      remaining -= segment;
    }
    return puntos.length;
  }

  static DateTime? departureToday(String horaSalida, DateTime now) {
    final parts = horaSalida.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static double distanceTraveledKm({
    required DateTime now,
    required String horaSalida,
    required int velocidadMaxima,
    required bool simulation,
    required DateTime simulationStartedAt,
    required double totalKm,
  }) {
    final speed = velocidadMaxima <= 0 ? 80 : velocidadMaxima.toDouble();
    if (simulation) {
      final hours =
          now.difference(simulationStartedAt).inMilliseconds / 3600000 * 10;
      if (hours <= 0 || totalKm <= 0) return 0;
      return hours * speed % totalKm;
    }

    final departure = departureToday(horaSalida, now);
    if (departure == null) return 0;
    final hours = now.difference(departure).inMilliseconds / 3600000;
    if (hours <= 0) return 0;
    return hours * speed;
  }

  static double _sin2(double x) {
    final s = _sin(x);
    return s * s;
  }

  static int duracionMin(double km, int velocidadMaxima) {
    final speed = velocidadMaxima <= 0 ? 80 : velocidadMaxima.toDouble();
    final media = speed * 0.6;
    if (km <= 0 || media <= 0) return 0;
    return (km / media * 60).round();
  }

  static String? estimarLlegada(String horaSalida, int duracionMin) {
    final parts = horaSalida.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].split(' ').first);
    if (hour == null || minute == null) return null;
    final total = hour * 60 + minute + duracionMin;
    final hh = (total ~/ 60) % 24;
    final mm = total % 60;
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
  }

  static String? estimarLlegadaEnEstacion({
    required String horaSalida,
    required double kmOrigenEstacion,
    required double kmRuta,
    required int duracionTotalMin,
  }) {
    if (kmRuta <= 0) return estimarLlegada(horaSalida, duracionTotalMin);
    final fraccion = (kmOrigenEstacion / kmRuta).clamp(0.0, 1.0);
    final minutos = (duracionTotalMin * fraccion).round();
    return estimarLlegada(horaSalida, minutos);
  }

  static double _sin(double x) => math.sin(x);
  static double _cos(double x) => math.cos(x);
  static double _asin(double x) => math.asin(x);
  static double _sqrt(double x) => x <= 0 ? 0 : math.sqrt(x);
}