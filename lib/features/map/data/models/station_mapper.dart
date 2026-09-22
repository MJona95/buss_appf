import '../../domain/entities/station.dart';

class StationMapper {
  static Station fromDbMap(Map<String, dynamic> map) {
    return Station(
      id: '${map['id']}',
      name: map['nombre'] as String? ?? '',
      distance: 0,
      nextRoute: map['siguiente_ruta'] as String? ?? '',
      latitude: (map['latitud'] as num?)?.toDouble() ?? 12.865416,
      longitude: (map['longitud'] as num?)?.toDouble() ?? -86.273062,
      rutaId: map['ruta_id']?.toString(),
      horaSalida: map['hora_salida']?.toString(),
      horaLlegada: map['hora_llegada']?.toString(),
    );
  }
}
