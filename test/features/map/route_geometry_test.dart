import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/domain/entities/ruta_mapa.dart';
import 'package:buss_app/features/map/domain/usecases/route_geometry.dart';

void main() {
  group('RouteGeometry.haversineKm', () {
    test('distancia entre la misma coordenada es cero', () {
      final a = const GeoPunto(latitud: 12.13422, longitud: -86.19338);
      expect(RouteGeometry.haversineKm(a, a), 0);
    });

    test('distancia aproximada Managua-Estelí esperada', () {
      final managua = const GeoPunto(latitud: 12.13422, longitud: -86.19338);
      final esteli = const GeoPunto(latitud: 13.07620, longitud: -86.35200);
      final km = RouteGeometry.haversineKm(managua, esteli);
      expect(km, closeTo(106.4, 3));
    });
  });

  group('RouteGeometry.totalKm', () {
    test('recorre la suma de los segmentos', () {
      final puntos = [
        const GeoPunto(latitud: 12.13422, longitud: -86.19338),
        const GeoPunto(latitud: 12.14422, longitud: -86.19338),
        const GeoPunto(latitud: 12.15422, longitud: -86.19338),
      ];
      final total = RouteGeometry.totalKm(puntos);
      expect(total, closeTo(2.22, 0.1));
    });

    test('lista con menos de dos puntos retorna cero', () {
      expect(RouteGeometry.totalKm(const []), 0);
      expect(
        RouteGeometry.totalKm(const [GeoPunto(latitud: 1, longitud: 1)]),
        0,
      );
    });
  });

  group('RouteGeometry.interpolate', () {
    test('distancia cero devuelve el primer punto', () {
      final puntos = [
        const GeoPunto(latitud: 0, longitud: 0),
        const GeoPunto(latitud: 1, longitud: 1),
      ];
      final p = RouteGeometry.interpolate(puntos, 0);
      expect(p.latitud, 0);
      expect(p.longitud, 0);
    });

    test('distancia mayor al total devuelve el último punto', () {
      final puntos = [
        const GeoPunto(latitud: 0, longitud: 0),
        const GeoPunto(latitud: 0.001, longitud: 0.001),
      ];
      final p = RouteGeometry.interpolate(puntos, 1000);
      expect(p.latitud, points.last.latitud);
      expect(p.longitud, points.last.longitud);
    });

    test('lista vacía no lanza', () {
      final p = RouteGeometry.interpolate(const [], 5);
      expect(p.latitud, 0);
    });
  });

  group('RouteGeometry.distanceTraveledKm', () {
    test('en simulación recorre y hace loop con el módulo del total', () {
      final start = DateTime(2026, 1, 1, 6, 0);
      final ahora = start.add(const Duration(hours: 1));
      final km = RouteGeometry.distanceTraveledKm(
        now: ahora,
        horaSalida: '06:00',
        velocidadMaxima: 80,
        simulation: true,
        simulationStartedAt: start,
        totalKm: 200,
      );
      expect(km, closeTo(800 % 200, 0.0001));
    });

    test('antes de la hora de salida no se mueve', () {
      final start = DateTime(2026, 1, 1, 6, 0);
      final antes = start.subtract(const Duration(minutes: 10));
      final km = RouteGeometry.distanceTraveledKm(
        now: antes,
        horaSalida: '06:00',
        velocidadMaxima: 80,
        simulation: false,
        simulationStartedAt: start,
        totalKm: 200,
      );
      expect(km, 0);
    });

    test('tiempo real avanza según velocidad máxima', () {
      final start = DateTime(2026, 1, 1, 6, 0);
      final despues = start.add(const Duration(hours: 1));
      final km = RouteGeometry.distanceTraveledKm(
        now: despues,
        horaSalida: '06:00',
        velocidadMaxima: 80,
        simulation: false,
        simulationStartedAt: start,
        totalKm: 200,
      );
      expect(km, closeTo(80, 0.001));
    });
  });

  group('RouteGeometry.departureToday', () {
    test('convierte hora HH:mm en la fecha actual', () {
      final now = DateTime(2026, 3, 10, 9, 0);
      final d = RouteGeometry.departureToday('07:30', now);
      expect(d, DateTime(2026, 3, 10, 7, 30));
    });

    test('hora inválida retorna null', () {
      expect(RouteGeometry.departureToday('malformato', DateTime.now()), isNull);
    });
  });

  group('RouteGeometry.duracionMin', () {
    test('usa el 60% de la velocidad máxima para estimar minutos', () {
      expect(RouteGeometry.duracionMin(70, 80), 88);
    });

    test('retorna cero para distancia inválida', () {
      expect(RouteGeometry.duracionMin(0, 80), 0);
      expect(RouteGeometry.duracionMin(-5, 80), 0);
    });

    test('velocidad inválida usa 80 km/h por defecto', () {
      expect(RouteGeometry.duracionMin(70, 0), 88);
    });
  });

  group('RouteGeometry.estimarLlegada', () {
    test('suma minutos a la hora de salida', () {
      expect(RouteGeometry.estimarLlegada('05:30', 77), '06:47');
    });

    test('cruza de hora con padding', () {
      expect(RouteGeometry.estimarLlegada('23:50', 30), '00:20');
    });

    test('hora malformada retorna null', () {
      expect(RouteGeometry.estimarLlegada('abc', 30), isNull);
    });
  });

  group('RouteGeometry.estimarLlegadaEnEstacion', () {
    test('interpola por fracción de distancia en estación intermedia', () {
      final llegada = RouteGeometry.estimarLlegadaEnEstacion(
        horaSalida: '05:30',
        kmOrigenEstacion: 35,
        kmRuta: 70,
        duracionTotalMin: 77,
      );
      expect(llegada, '06:09');
    });

    test('estación en el origen coincide con la salida', () {
      final llegada = RouteGeometry.estimarLlegadaEnEstacion(
        horaSalida: '05:30',
        kmOrigenEstacion: 0,
        kmRuta: 70,
        duracionTotalMin: 77,
      );
      expect(llegada, '05:30');
    });

    test('estación con ruta sin distancia usa duración total', () {
      final llegada = RouteGeometry.estimarLlegadaEnEstacion(
        horaSalida: '05:30',
        kmOrigenEstacion: 20,
        kmRuta: 0,
        duracionTotalMin: 77,
      );
      expect(llegada, '06:47');
    });
  });
}

final points = const [
  GeoPunto(latitud: 0, longitud: 0),
  GeoPunto(latitud: 0.001, longitud: 0.001),
];