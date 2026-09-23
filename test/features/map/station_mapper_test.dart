import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/data/models/station_mapper.dart';

void main() {
  test('mapea poblado y tarifas', () {
    final station = StationMapper.fromDbMap({
      'id': 's1',
      'nombre': 'Terminal',
      'latitud': 13.4,
      'longitud': -86.5,
      'poblado': 1,
      'tarifas': [
        {'ruta': 'Somoto - Estelí', 'tipo': 'Autobús', 'monto': 45.0, 'moneda': 'NIO'},
        {'ruta': 'Somoto - Managua', 'tipo': 'Van', 'monto': 220.0, 'moneda': 'NIO'},
      ],
    });

    expect(station.poblado, isTrue);
    expect(station.tarifas, hasLength(2));
    expect(station.tarifas.first.tipo, 'Autobús');
    expect(station.tarifas.first.monto, 45.0);
  });

  test('poblado false con 0', () {
    final station = StationMapper.fromDbMap({
      'id': 's2',
      'nombre': 'Poblado menor',
      'latitud': 13.1,
      'longitud': -86.3,
      'poblado': 0,
    });
    expect(station.poblado, isFalse);
    expect(station.tarifas, isEmpty);
  });

  test('poblado por defecto false cuando falta', () {
    final station = StationMapper.fromDbMap({
      'id': 's3',
      'nombre': 'Sin campo',
      'latitud': 13.1,
      'longitud': -86.3,
    });
    expect(station.poblado, isFalse);
  });
}