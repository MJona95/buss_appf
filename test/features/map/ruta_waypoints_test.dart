import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/domain/entities/ruta_mapa.dart';
import 'package:buss_app/features/map/domain/usecases/ruta_waypoints.dart';

void main() {
  test('arma partida + estaciones + llegada en orden', () {
    final waypoints = RutaWaypoints.build(
      origenLat: 13.48858,
      origenLng: -86.58185,
      destinoLat: 12.13422,
      destinoLng: -86.19338,
      estaciones: [
        {'latitud': 13.48858, 'longitud': -86.58185},
        {'latitud': 13.07620, 'longitud': -86.35200},
        {'latitud': 12.13422, 'longitud': -86.19338},
      ],
    );
    expect(waypoints.length, 3);
    _esperaPunto(waypoints[0], 13.48858, -86.58185);
    _esperaPunto(waypoints[1], 13.07620, -86.35200);
    _esperaPunto(waypoints[2], 12.13422, -86.19338);
  });

  test('deduplica estaciones repetidas y evita duplicar extremos', () {
    final waypoints = RutaWaypoints.build(
      origenLat: 13.48858,
      origenLng: -86.58185,
      destinoLat: 12.13422,
      destinoLng: -86.19338,
      estaciones: [
        {'latitud': 13.48858, 'longitud': -86.58185},
        {'latitud': 13.48858, 'longitud': -86.58185},
        {'latitud': 13.07620, 'longitud': -86.35200},
        {'latitud': 12.13422, 'longitud': -86.19338},
      ],
    );
    expect(waypoints.length, 3);
    expect(waypoints.map((p) => p.latitud), [13.48858, 13.07620, 12.13422]);
  });

  test('sin estaciones usa solo origen y destino', () {
    final waypoints = RutaWaypoints.build(
      origenLat: 13.48858,
      origenLng: -86.58185,
      destinoLat: 12.13422,
      destinoLng: -86.19338,
      estaciones: const [],
    );
    expect(waypoints.length, 2);
    _esperaPunto(waypoints.first, 13.48858, -86.58185);
    _esperaPunto(waypoints.last, 12.13422, -86.19338);
  });

  test('agrega destino al final aunque las estaciones no lo incluyan', () {
    final waypoints = RutaWaypoints.build(
      origenLat: 13.48858,
      origenLng: -86.58185,
      destinoLat: 12.13422,
      destinoLng: -86.19338,
      estaciones: [
        {'latitud': 13.07620, 'longitud': -86.35200},
      ],
    );
    expect(waypoints.length, 3);
    _esperaPunto(waypoints.last, 12.13422, -86.19338);
  });
}

void _esperaPunto(GeoPunto punto, double lat, double lng) {
  expect(punto.latitud, lat);
  expect(punto.longitud, lng);
}