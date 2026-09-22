import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_datasources.dart';
import '../models/booking_mapper.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDatasource local;
  final BookingRemoteDatasource remote;

  BookingRepositoryImpl({
    required this.local,
    required this.remote,
  });

  @override
  Future<List<Booking>> getBookings() async {
    final rows = await local.getBookings();
    return rows.map(BookingMapper.fromDbMap).toList();
  }

  @override
  Future<void> createLocal(Booking booking) {
    return local.insertBooking(BookingMapper.toDbMap(booking));
  }

  @override
  Future<bool> syncRemote(Booking booking) {
    return remote.uploadBooking(BookingMapper.toDbMap(booking));
  }

  @override
  Future<void> markSynced(Booking booking) {
    return local.updateBooking(booking.id, {
      'estado': booking.status,
      'estado_sync': booking.syncStatus,
      'monto_cotizacion': booking.quoteAmount,
    });
  }
}
