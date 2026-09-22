import '../entities/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<void> updateBookmark(String id, bool isBookmarked);
}
