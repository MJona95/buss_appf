import '../entities/ruta_mapa.dart';
import '../repositories/ruta_mapa_repository.dart';

class GetRutasMapa {
  final RutaMapaRepository repository;

  GetRutasMapa(this.repository);

  Future<List<RutaMapa>> call() => repository.getRutasMapa();
}