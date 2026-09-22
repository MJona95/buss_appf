import 'package:buss_app/features/home/domain/entities/trip.dart';
import 'package:buss_app/features/home/domain/usecases/trip_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const trips = [
    Trip(
      id: '1',
      name: 'Somoto - Estelí',
      originName: 'Somoto',
      destinationName: 'Estelí',
      price: 45,
      transportType: 'public',
      isBookmarked: true,
    ),
    Trip(
      id: '2',
      name: 'Somoto - Managua Ejecutivo',
      originName: 'Somoto',
      destinationName: 'Managua',
      price: 220,
      transportType: 'private',
      isBookmarked: false,
    ),
  ];

  final filter = FilterTrips();

  test('Todos returns all trips', () {
    final result = filter(all: trips, query: '', category: 'Todos');
    expect(result.length, 2);
  });

  test('Público filters public routes', () {
    final result = filter(all: trips, query: '', category: 'Público');
    expect(result.map((t) => t.id), ['1']);
  });

  test('Privado filters private routes', () {
    final result = filter(all: trips, query: '', category: 'Privado');
    expect(result.map((t) => t.id), ['2']);
  });

  test('search is case insensitive and stacks with category', () {
    final result = filter(all: trips, query: 'estel', category: 'Todos');
    expect(result.map((t) => t.id), ['1']);
  });

  test('search plus category can yield empty', () {
    final result = filter(all: trips, query: 'estel', category: 'Privado');
    expect(result, isEmpty);
  });
}
