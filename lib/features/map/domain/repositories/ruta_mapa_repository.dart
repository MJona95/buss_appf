import '../entities/ruta_mapa.dart';

abstract class RutaMapaRepository {
  Future<List<RutaMapa>> getRutasMapa();
}