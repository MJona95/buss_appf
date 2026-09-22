import 'package:buss_app/features/buses/domain/entities/bus.dart';
import 'package:buss_app/features/buses/domain/usecases/bus_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const buses = [
    Bus(
      id: '1',
      name: 'Unidad 42',
      plate: '42',
      vehicleType: 'Autobús',
      transportType: 'public',
      capacity: 18,
      active: true,
    ),
    Bus(
      id: '2',
      name: 'Unidad 15',
      plate: '15',
      vehicleType: 'Irizar',
      transportType: 'public',
      capacity: 44,
      active: false,
    ),
  ];

  final filter = FilterBuses();

  test('Todas las Unidades returns all', () {
    final result = filter(
      all: buses,
      query: '',
      filter: 'Todas las Unidades',
    );
    expect(result.length, 2);
  });

  test('Disponibles only in-service buses', () {
    final result = filter(all: buses, query: '', filter: 'Disponibles');
    expect(result.map((b) => b.id), ['1']);
  });

  test('En Mantenimiento only out-of-service buses', () {
    final result = filter(all: buses, query: '', filter: 'En Mantenimiento');
    expect(result.map((b) => b.id), ['2']);
  });

  test('search matches number or model', () {
    expect(
      filter(all: buses, query: '42', filter: 'Todas las Unidades')
          .map((b) => b.id),
      ['1'],
    );
    expect(
      filter(all: buses, query: 'irizar', filter: 'Todas las Unidades')
          .map((b) => b.id),
      ['2'],
    );
  });
}
