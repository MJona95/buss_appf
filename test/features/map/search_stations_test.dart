import 'package:buss_app/features/map/domain/entities/station.dart';
import 'package:buss_app/features/map/domain/usecases/station_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stations = [
    Station(
      id: 'st_1',
      name: 'Terminal de Buses de Somoto',
      distance: 0,
      nextRoute: 'Somoto - Estelí',
      latitude: 13.48,
      longitude: -86.58,
    ),
    Station(
      id: 'st_4',
      name: 'Terminal El Mayoreo (Managua)',
      distance: 0,
      nextRoute: 'Estelí - Managua',
      latitude: 12.13,
      longitude: -86.19,
    ),
  ];

  final search = SearchStations();

  test('empty query returns all', () {
    expect(search(all: stations, query: '').length, 2);
  });

  test('matches name or address', () {
    expect(
      search(all: stations, query: 'somoto').map((s) => s.id),
      ['st_1'],
    );
    expect(
      search(all: stations, query: 'mayoreo').map((s) => s.id),
      ['st_4'],
    );
  });
}
