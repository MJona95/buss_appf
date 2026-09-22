import '../../domain/entities/booking.dart';

class BookingMapper {
  static Booking fromDbMap(Map<String, dynamic> map) {
    return Booking(
      id: '${map['id']}',
      pickupLocation: map['origen'] as String,
      dropoffLocation: map['destino'] as String,
      departureDate: map['fecha_salida'] as String,
      pickupTime: map['hora_recogida'] as String,
      status: map['estado'] as String,
      quoteAmount: (map['monto_cotizacion'] as num?)?.toDouble() ?? 0,
      syncStatus: map['estado_sync'] as String? ?? 'pending',
    );
  }

  static Map<String, dynamic> toDbMap(Booking booking) {
    return {
      'id': booking.id,
      'origen': booking.pickupLocation,
      'destino': booking.dropoffLocation,
      'fecha_salida': booking.departureDate,
      'hora_recogida': booking.pickupTime,
      'estado': booking.status,
      'monto_cotizacion': booking.quoteAmount,
      'estado_sync': booking.syncStatus,
      'creado_en': DateTime.now().toIso8601String(),
    };
  }
}
