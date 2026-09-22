import '../../domain/entities/ruta_mapa.dart';

class RutaMapaMapper {
  static List<RutaMapa> fromRows({
    required List<Map<String, dynamic>> rutas,
    required List<Map<String, dynamic>> puntos,
  }) {
    final agrupadas = <String, List<Map<String, dynamic>>>{};
    for (final ruta in rutas) {
      final id = '${ruta['ruta_id']}';
      agrupadas.putIfAbsent(id, () => []).add(ruta);
    }

    final puntosPorRuta = <String, List<GeoPunto>>{};
    for (final punto in puntos) {
      final id = '${punto['ruta_id']}';
      final lat = (punto['latitud'] as num).toDouble();
      final lng = (punto['longitud'] as num).toDouble();
      puntosPorRuta.putIfAbsent(id, () => []).add(
        GeoPunto(latitud: lat, longitud: lng),
      );
    }

    return agrupadas.entries.map((entry) {
      final filas = entry.value;
      final primera = filas.first;
      final vehiculos = filas.map((fila) {
        return VehiculoEnRuta(
          id: '${fila['vehiculo_id']}',
          nombre: '${fila['vehiculo_nombre'] ?? 'Unidad'}',
          placa: fila['placa']?.toString(),
          tipoCodigo: '${fila['tipo_codigo'] ?? 'bus'}',
          velocidadMaxima: (fila['velocidad_maxima'] as num?)?.toInt() ?? 80,
          horaSalida: '${fila['hora_salida'] ?? '06:00'}',
          horaLlegada: fila['hora_llegada']?.toString(),
          rutaId: entry.key,
        );
      }).toList();

      final puntosOrdenados = (puntosPorRuta[entry.key] ?? const <GeoPunto>[])
          .toList();

      return RutaMapa(
        id: entry.key,
        nombre: '${primera['ruta_nombre'] ?? 'Ruta'}',
        origenNombre: '${primera['origen_nombre'] ?? ''}',
        destinoNombre: '${primera['destino_nombre'] ?? ''}',
        puntos: puntosOrdenados,
        vehiculos: vehiculos,
      );
    }).toList();
  }
}