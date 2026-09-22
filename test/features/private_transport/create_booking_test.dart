import 'package:buss_app/core/services/quote_service.dart';
import 'package:buss_app/features/private_transport/domain/entities/booking.dart';
import 'package:buss_app/features/private_transport/domain/repositories/booking_repository.dart';
import 'package:buss_app/features/private_transport/domain/usecases/booking_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  Booking? stored;
  bool remoteSucceeds;
  Booking? marked;

  _FakeBookingRepository({this.remoteSucceeds = true});

  @override
  Future<void> createLocal(Booking booking) async {
    stored = booking;
  }

  @override
  Future<List<Booking>> getBookings() async => stored == null ? [] : [stored!];

  @override
  Future<void> markSynced(Booking booking) async {
    marked = booking;
    stored = booking;
  }

  @override
  Future<bool> syncRemote(Booking booking) async => remoteSucceeds;
}

void main() {
  test('confirms booking when remote sync succeeds', () async {
    final repo = _FakeBookingRepository(remoteSucceeds: true);
    final useCase = CreateBooking(
      repository: repo,
      quoteService: QuoteService(),
    );

    final booking = await useCase(
      pickup: 'Somoto',
      dropoff: 'Managua',
      date: '2026-09-22',
      time: '08:00',
    );

    expect(booking.status, 'Confirmed');
    expect(booking.syncStatus, 'synced');
    expect(booking.quoteAmount, QuoteService.baseFare + QuoteService.perHop * 3);
    expect(repo.marked?.syncStatus, 'synced');
  });

  test('keeps pending when remote sync fails', () async {
    final repo = _FakeBookingRepository(remoteSucceeds: false);
    final useCase = CreateBooking(
      repository: repo,
      quoteService: QuoteService(),
    );

    final booking = await useCase(
      pickup: 'Somoto',
      dropoff: 'Estelí',
      date: '2026-09-22',
      time: '08:00',
    );

    expect(booking.status, 'Pending');
    expect(booking.syncStatus, 'pending');
    expect(repo.stored?.syncStatus, 'pending');
    expect(repo.marked, isNull);
  });
}
