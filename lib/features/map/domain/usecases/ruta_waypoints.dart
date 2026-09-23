import '../entities/ruta_mapa.dart';

class RutaWaypoints {
  RutaWaypoints._();

  static const double _eps = 1e-5;

  static List<GeoPunto> build({
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    required List<Map<String, dynamic>> estaciones,
  }) {
    final waypoints = <GeoPunto>[
      GeoPunto(latitud: origenLat, longitud: origenLng),
    ];
    for (final estacion in estaciones) {
      final punto = GeoPunto(
        latitud: (estacion['latitud'] as num).toDouble(),
        longitud: (estacion['longitud'] as num).toDouble(),
      );
      if (_mismaCoordenada(waypoints.last, punto)) continue;
      waypoints.add(punto);
    }
    final destino = GeoPunto(latitud: destinoLat, longitud: destinoLng);
    if (!_mismaCoordenada(waypoints.last, destino)) {
      waypoints.add(destino);
    }
    return waypoints;
  }

  static bool _mismaCoordenada(GeoPunto a, GeoPunto b) {
    return (a.latitud - b.latitud).abs() < _eps &&
        (a.longitud - b.longitud).abs() < _eps;
  }
}