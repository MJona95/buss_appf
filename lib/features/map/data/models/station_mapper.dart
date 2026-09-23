import '../../domain/entities/station.dart';

class StationMapper {
  static bool _bool(Object? v) {
    return v == true || v == 1 || v == 'true';
  }

  static Station fromDbMap(Map<String, dynamic> map) {
    final tarifas = (map['tarifas'] as List?) ?? const [];
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
      poblado: _bool(map['poblado']),
      tarifas: tarifas.map<TarifaOpcion>((item) {
        final t = (item as Map).cast<String, dynamic>();
        return TarifaOpcion(
          ruta: t['ruta']?.toString() ?? '',
          tipo: t['tipo']?.toString() ?? '',
          monto: (t['monto'] as num?)?.toDouble() ?? 0,
          moneda: t['moneda']?.toString() ?? 'NIO',
        );
      }).toList(),
    );
  }
}
