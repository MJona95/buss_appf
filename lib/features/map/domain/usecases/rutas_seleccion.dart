import '../entities/ruta_mapa.dart';

class RutasPorSeleccion {
  RutasPorSeleccion._();

  static List<RutaMapa> ejecutar(List<RutaMapa> rutas, String? rutaId) {
    if (rutaId == null) return rutas;
    final match = rutas.where((ruta) => ruta.id == rutaId).toList();
    return match.isEmpty ? rutas : match;
  }
}