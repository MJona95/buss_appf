import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/data/models/ruta_mapa_mapper.dart';

void main() {
  test('fromRows agrupa rutas, vehículos y ordena puntos por ruta', () {
    final rutas = [
      {
        'ruta_id': 'r1',
        'ruta_nombre': 'A - B',
        'origen_nombre': 'A',
        'destino_nombre': 'B',
        'vehiculo_id': 'v1',
        'vehiculo_nombre': 'Unidad 1',
        'placa': '42',
        'tipo_codigo': 'bus',
        'velocidad_maxima': 80,
        'hora_salida': '06:00',
        'hora_llegada': '08:15',
      },
      {
        'ruta_id': 'r1',
        'ruta_nombre': 'A - B',
        'origen_nombre': 'A',
        'destino_nombre': 'B',
        'vehiculo_id': 'v2',
        'vehiculo_nombre': 'Unidad 2',
        'placa': '15',
        'tipo_codigo': 'van',
        'velocidad_maxima': 90,
        'hora_salida': '07:00',
        'hora_llegada': '10:31',
      },
      {
        'ruta_id': 'r2',
        'ruta_nombre': 'C - D',
        'origen_nombre': 'C',
        'destino_nombre': 'D',
        'vehiculo_id': 'v3',
        'vehiculo_nombre': 'Unidad 3',
        'placa': '88',
        'tipo_codigo': 'microbus',
        'velocidad_maxima': 80,
        'hora_salida': '06:30',
        'hora_llegada': '09:00',
      },
    ];

    final puntos = [
      {'ruta_id': 'r2', 'orden': 1, 'latitud': 2.0, 'longitud': -1.0},
      {'ruta_id': 'r1', 'orden': 1, 'latitud': 1.0, 'longitud': 0.0},
      {'ruta_id': 'r1', 'orden': 2, 'latitud': 3.0, 'longitud': 4.0},
    ];

    final rutasMapa = RutaMapaMapper.fromRows(rutas: rutas, puntos: puntos);

    expect(rutasMapa.length, 2);

    final ruta1 = rutasMapa.firstWhere((r) => r.id == 'r1');
    expect(ruta1.nombre, 'A - B');
    expect(ruta1.origenNombre, 'A');
    expect(ruta1.destinoNombre, 'B');
    expect(ruta1.puntos.length, 2);
    expect(ruta1.puntos.first.latitud, 1.0);
    expect(ruta1.puntos.last.longitud, 4.0);
    expect(ruta1.vehiculos.length, 2);
    expect(ruta1.vehiculos.map((v) => v.placa), ['42', '15']);
    expect(ruta1.vehiculos.first.velocidadMaxima, 80);
    expect(ruta1.vehiculos.first.horaSalida, '06:00');
    expect(ruta1.vehiculos.first.horaLlegada, '08:15');
    expect(ruta1.vehiculos.last.tipoCodigo, 'van');
    expect(ruta1.vehiculos.last.horaLlegada, '10:31');

    final ruta2 = rutasMapa.firstWhere((r) => r.id == 'r2');
    expect(ruta2.vehiculos.single.placa, '88');
    expect(ruta2.puntos.single.longitud, -1.0);
  });

  test('fromRows con filas vacías devuelve lista vacía', () {
    expect(RutaMapaMapper.fromRows(rutas: [], puntos: []), isEmpty);
  });
}