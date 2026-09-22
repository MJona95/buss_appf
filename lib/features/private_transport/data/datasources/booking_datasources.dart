import 'package:buss_app/core/api/supabase_client.dart';
import 'package:buss_app/core/database/local_database.dart';

class BookingLocalDatasource {
  final LocalDatabase database;

  BookingLocalDatasource(this.database);

  Future<List<Map<String, dynamic>>> getBookings() => database.getReservas();

  Future<void> insertBooking(Map<String, dynamic> booking) {
    return database.insertReserva(booking);
  }

  Future<void> updateBooking(String id, Map<String, dynamic> values) {
    return database.updateReserva(id, values);
  }
}

class BookingRemoteDatasource {
  Future<bool> uploadBooking(Map<String, dynamic> booking) {
    return SupabaseManager.uploadReserva(booking);
  }
}
