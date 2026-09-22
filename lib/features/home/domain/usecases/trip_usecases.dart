import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTrips {
  final TripRepository repository;

  GetTrips(this.repository);

  Future<List<Trip>> call() => repository.getTrips();
}

class FilterTrips {
  List<Trip> call({
    required List<Trip> all,
    required String query,
    required String category,
  }) {
    var result = all;

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where(
            (trip) =>
                trip.name.toLowerCase().contains(q) ||
                trip.originName.toLowerCase().contains(q) ||
                trip.destinationName.toLowerCase().contains(q),
          )
          .toList();
    }

    switch (category) {
      case 'Público':
        result = result.where((trip) => trip.transportType == 'public').toList();
        break;
      case 'Privado':
        result =
            result.where((trip) => trip.transportType == 'private').toList();
        break;
    }

    return result;
  }
}

class ToggleBookmark {
  final TripRepository repository;

  ToggleBookmark(this.repository);

  Future<List<Trip>> call(List<Trip> all, String id) async {
    final updated = all
        .map(
          (trip) => trip.id == id
              ? trip.copyWith(isBookmarked: !trip.isBookmarked)
              : trip,
        )
        .toList();
    final trip = updated.firstWhere((item) => item.id == id);
    await repository.updateBookmark(id, trip.isBookmarked);
    return updated;
  }
}
