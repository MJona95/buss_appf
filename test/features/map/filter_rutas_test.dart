import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/domain/entities/ruta_mapa.dart';
import 'package:buss_app/features/map/domain/usecases/filter_rutas.dart';

void main() {
  final todas = [
    _ruta('r1', 'Somoto - Estelí', 'Somoto', 'Estelí'),
    _ruta('r2', 'Estelí - Managua', 'Estelí', 'Managua'),
    _ruta('r3', 'Ocotal - Managua', 'Ocotal', 'Managua'),
    _ruta('r4', 'Somoto - Managua', 'Somoto', 'Managua'),
  ];

  test('Todas devuelve todas las rutas', () {
    expect(
      FilterRutasPorDestino.ejecutar(todas, FilterRutasPorDestino.todos).length,
      4,
    );
  });

  test('Estelí filtra solo rutas cuyo destino es Estelí', () {
    final visibles = FilterRutasPorDestino.ejecutar(todas, 'Estelí');
    expect(visibles.length, 1);
    expect(visibles.single.destinoNombre, 'Estelí');
  });

  test('Managua devuelve las tres rutas que llegan a Managua', () {
    final visibles = FilterRutasPorDestino.ejecutar(todas, 'Managua');
    expect(visibles.length, 3);
    expect(
      visibles.every((r) => r.destinoNombre == 'Managua'),
      isTrue,
    );
  });

  test('Ocotal cae a la ruta con origen Ocotal cuando nadie llega allí', () {
    final visibles = FilterRutasPorDestino.ejecutar(todas, 'Ocotal');
    expect(visibles.length, 1);
    expect(visibles.single.origenNombre, 'Ocotal');
  });

  test('es insensible a mayúsculas', () {
    final visibles = FilterRutasPorDestino.ejecutar(todas, 'ESTELÍ');
    expect(visibles.length, 1);
    expect(visibles.single.destinoNombre, 'Estelí');
  });
}

RutaMapa _ruta(String id, String nombre, String origen, String destino) {
  return RutaMapa(
    id: id,
    nombre: nombre,
    origenNombre: origen,
    destinoNombre: destino,
    puntos: const [],
  );
}