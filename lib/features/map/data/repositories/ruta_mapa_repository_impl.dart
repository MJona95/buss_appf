import '../../domain/entities/ruta_mapa.dart';
import '../../domain/repositories/ruta_mapa_repository.dart';
import '../../domain/usecases/ruta_waypoints.dart';
import '../datasources/map_routes_datasources.dart';
import '../datasources/osrm_geometry_datasource.dart';
import '../models/ruta_mapa_mapper.dart';

class RutaMapaRepositoryImpl implements RutaMapaRepository {
  final MapRoutesLocalDatasource local;
  final OsrmGeometryDatasource osrm;

  static const Duration _osrmDelay = Duration(milliseconds: 400);

  RutaMapaRepositoryImpl({required this.local, required this.osrm});

  @override
  Future<List<RutaMapa>> getRutasMapa() async {
    final rutas = await local.getRutas();
    var puntos = await local.getPuntos();

    final idsRuta = {for (final ruta in rutas) '${ruta['ruta_id']}'}.toSet();
    final conPuntos = {
      for (final punto in puntos) '${punto['ruta_id']}',
    }.toSet();
    final faltantes = idsRuta.difference(conPuntos);

    Map<String, Map<String, dynamic>>? context;
    if (faltantes.isNotEmpty) {
      context = await local.getRutaGeoContext();
      var primero = true;
      for (final rutaId in faltantes) {
        if (!primero) await Future<void>.delayed(_osrmDelay);
        primero = false;
        final geo = context[rutaId];
        if (geo == null) continue;
        final geometry = await osrm.fetchRoute(
          RutaWaypoints.build(
            origenLat: (geo['origen_lat'] as num).toDouble(),
            origenLng: (geo['origen_lng'] as num).toDouble(),
            destinoLat: (geo['destino_lat'] as num).toDouble(),
            destinoLng: (geo['destino_lng'] as num).toDouble(),
            estaciones: (geo['estaciones'] as List)
                .cast<Map<String, dynamic>>(),
          ),
        );
        if (geometry != null && geometry.length >= 2) {
          await local.replacePuntosRuta(
            rutaId,
            [
              for (final p in geometry)
                {'latitud': p.latitud, 'longitud': p.longitud},
            ],
          );
        }
      }
      puntos = await local.getPuntos();
    }

    final sinPuntos = idsRuta.difference({
      for (final punto in puntos) '${punto['ruta_id']}',
    }.toSet());
    final fallback = <Map<String, dynamic>>[];
    if (sinPuntos.isNotEmpty) {
      context ??= await local.getRutaGeoContext();
      for (final rutaId in sinPuntos) {
        final geo = context[rutaId];
        if (geo == null) continue;
        fallback.add({
          'ruta_id': rutaId,
          'orden': 1,
          'latitud': geo['origen_lat'],
          'longitud': geo['origen_lng'],
        });
        fallback.add({
          'ruta_id': rutaId,
          'orden': 2,
          'latitud': geo['destino_lat'],
          'longitud': geo['destino_lng'],
        });
      }
    }

    return RutaMapaMapper.fromRows(rutas: rutas, puntos: [...puntos, ...fallback]);
  }
}