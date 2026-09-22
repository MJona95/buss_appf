import '../../domain/entities/ruta_mapa.dart';
import '../../domain/repositories/ruta_mapa_repository.dart';
import '../datasources/map_routes_datasources.dart';
import '../models/ruta_mapa_mapper.dart';

class RutaMapaRepositoryImpl implements RutaMapaRepository {
  final MapRoutesLocalDatasource local;

  RutaMapaRepositoryImpl({required this.local});

  @override
  Future<List<RutaMapa>> getRutasMapa() async {
    final rutas = await local.getRutas();
    final puntos = await local.getPuntos();
    return RutaMapaMapper.fromRows(rutas: rutas, puntos: puntos);
  }
}