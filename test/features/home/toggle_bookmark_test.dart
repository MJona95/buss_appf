import 'package:buss_app/features/home/domain/entities/trip.dart';
import 'package:buss_app/features/home/domain/repositories/trip_repository.dart';
import 'package:buss_app/features/home/domain/usecases/trip_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTripRepository implements TripRepository {
  String? lastId;
  bool? lastValue;

  @override
  Future<List<Trip>> getTrips() async => [];

  @override
  Future<void> updateBookmark(String id, bool isBookmarked) async {
    lastId = id;
    lastValue = isBookmarked;
  }
}

void main() {
  test('toggles bookmark on the matching trip and persists it', () async {
    final repo = _FakeTripRepository();
    final useCase = ToggleBookmark(repo);
    const trips = [
      Trip(
        id: 'trip_1',
        name: 'Somoto - Estelí',
        originName: 'Somoto',
        destinationName: 'Estelí',
        price: 45,
        isBookmarked: true,
      ),
      Trip(
        id: 'trip_2',
        name: 'Estelí - Managua',
        originName: 'Estelí',
        destinationName: 'Managua',
        price: 90,
        isBookmarked: false,
      ),
    ];

    final updated = await useCase(trips, 'trip_1');

    expect(updated.first.isBookmarked, isFalse);
    expect(updated.last.isBookmarked, isFalse);
    expect(repo.lastId, 'trip_1');
    expect(repo.lastValue, isFalse);
  });
}
