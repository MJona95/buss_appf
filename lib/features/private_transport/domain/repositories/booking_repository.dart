import '../entities/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<void> createLocal(Booking booking);
  Future<bool> syncRemote(Booking booking);
  Future<void> markSynced(Booking booking);
}
