import '../../domain/entities/trip.dart';

class TripMapper {
  static Trip fromDbMap(
    Map<String, dynamic> map, {
    required bool isBookmarked,
  }) {
    return Trip(
      id: '${map['id']}',
      name: map['nombre'] as String? ?? '',
      originName: map['origen_nombre'] as String? ?? '',
      destinationName: map['destino_nombre'] as String? ?? '',
      price: (map['monto'] as num?)?.toDouble() ?? 0,
      currency: map['moneda'] as String? ?? 'NIO',
      transportType: map['tipo_transporte'] as String? ?? 'public',
      horaSalida: map['hora_salida']?.toString(),
      horaLlegada: map['hora_llegada']?.toString(),
      isBookmarked: isBookmarked,
      isAvailable: _asBool(map['activo']),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }
}
