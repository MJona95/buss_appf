import '../../domain/entities/bus.dart';

class BusMapper {
  static Bus fromDbMap(Map<String, dynamic> map) {
    return Bus(
      id: '${map['id']}',
      name: map['nombre'] as String? ?? '',
      plate: map['placa'] as String?,
      vehicleType: map['tipo_nombre'] as String? ??
          map['tipo_codigo'] as String? ??
          '',
      transportType: map['tipo_transporte'] as String? ?? 'public',
      serviceType: map['tipo_servicio']?.toString(),
      capacity: (map['capacidad'] as num?)?.toInt() ?? 0,
      active: _asBool(map['activo']),
      assignedRoutes: map['rutas_asignadas'] as String? ?? '',
      horaSalida: map['hora_salida']?.toString(),
      horaLlegada: map['hora_llegada']?.toString(),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }
}
