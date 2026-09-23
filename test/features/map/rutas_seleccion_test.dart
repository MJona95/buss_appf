import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/domain/entities/ruta_mapa.dart';
import 'package:buss_app/features/map/domain/usecases/rutas_seleccion.dart';

void main() {
  final rutas = [
    _ruta('r1'),
    _ruta('r2'),
    _ruta('r3'),
  ];

  test('sin selección (null) muestra todas las rutas', () {
    expect(RutasPorSeleccion.ejecutar(rutas, null).length, 3);
  });

  test('con id muestra solo esa ruta', () {
    final visibles = RutasPorSeleccion.ejecutar(rutas, 'r2');
    expect(visibles.length, 1);
    expect(visibles.single.id, 'r2');
  });

  test('con id inexistente devuelve todas las rutas', () {
    expect(RutasPorSeleccion.ejecutar(rutas, 'r99').length, 3);
  });
}

RutaMapa _ruta(String id) {
  return RutaMapa(
    id: id,
    nombre: 'Ruta $id',
    origenNombre: 'Origen',
    destinoNombre: 'Destino',
    puntos: const [],
  );
}