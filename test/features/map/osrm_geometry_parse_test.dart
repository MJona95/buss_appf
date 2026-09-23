import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/data/datasources/osrm_geometry_datasource.dart';

void main() {
  test('parseGeometry convierte geojson de OSRM en puntos', () {
    final json = {
      'routes': [
        {
          'geometry': {
            'coordinates': [
              [-86.58185, 13.48858],
              [-86.35200, 13.07620],
              [-86.19338, 12.13422],
            ],
          },
        },
      ],
    };
    final puntos = OsrmGeometryDatasource.parseGeometry(json);
    expect(puntos, isNotNull);
    expect(puntos!.length, 3);
    expect(puntos.first.longitud, -86.58185);
    expect(puntos.first.latitud, 13.48858);
    expect(puntos.last.longitud, -86.19338);
  });

  test('parseGeometry devuelve null si no hay rutas', () {
    expect(
      OsrmGeometryDatasource.parseGeometry({'routes': []}),
      isNull,
    );
    expect(
      OsrmGeometryDatasource.parseGeometry(const {}),
      isNull,
    );
  });

  test('parseGeometry devuelve null con menos de dos coordenadas', () {
    final json = {
      'routes': [
        {'geometry': {'coordinates': [[-86.5, 13.4]]}},
      ],
    };
    expect(OsrmGeometryDatasource.parseGeometry(json), isNull);
  });
}