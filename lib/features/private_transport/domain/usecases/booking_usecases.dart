import 'dart:math';

import 'package:buss_app/core/services/quote_service.dart';

import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookings {
  final BookingRepository repository;

  GetBookings(this.repository);

  Future<List<Booking>> call() => repository.getBookings();
}

class CreateBooking {
  final BookingRepository repository;
  final QuoteService quoteService;

  CreateBooking({
    required this.repository,
    required this.quoteService,
  });

  Future<Booking> call({
    required String pickup,
    required String dropoff,
    required String date,
    required String time,
  }) async {
    final quote = quoteService.calculate(pickup: pickup, dropoff: dropoff);
    var booking = Booking(
      id: _newUuid(),
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      departureDate: date,
      pickupTime: time,
      status: 'Pending',
      quoteAmount: quote,
      syncStatus: 'pending',
    );

    await repository.createLocal(booking);

    final synced = await repository.syncRemote(booking);
    if (synced) {
      booking = booking.copyWith(
        status: 'Confirmed',
        syncStatus: 'synced',
      );
      await repository.markSynced(booking);
    }

    return booking;
  }
}

String _newUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
