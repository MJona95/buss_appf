import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/ruta_mapa.dart';

class OsrmGeometryDatasource {
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<GeoPunto>?> fetchRoute(List<GeoPunto> waypoints) async {
    if (waypoints.length < 2) return null;
    final coordinates = waypoints
        .map((p) => '${p.longitud},${p.latitud}')
        .join(';');
    final uri = Uri.parse(
      '$_baseUrl/$coordinates?overview=full&geometries=geojson',
    );
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return parseGeometry(json);
    } catch (_) {
      return null;
    }
  }

  static List<GeoPunto>? parseGeometry(Map<String, dynamic> json) {
    try {
      final routes = json['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;
      final geometry = routes.first['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>?;
      if (coordinates == null || coordinates.length < 2) return null;
      return coordinates.map((pair) {
        final values = pair as List<dynamic>;
        return GeoPunto(
          latitud: (values[1] as num).toDouble(),
          longitud: (values[0] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }
}