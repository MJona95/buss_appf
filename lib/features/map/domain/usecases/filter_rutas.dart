import '../entities/ruta_mapa.dart';

class FilterRutasPorDestino {
  FilterRutasPorDestino._();

  static const String todos = 'Todas';
  static const List<String> destinos = ['Estelí', 'Ocotal', 'Managua'];

  static List<RutaMapa> ejecutar(List<RutaMapa> rutas, String destino) {
    if (destino == todos) return rutas;
    final target = destino.trim().toLowerCase();
    return rutas.where((ruta) {
      final destinoRuta = ruta.destinoNombre.toLowerCase();
      final origenRuta = ruta.origenNombre.toLowerCase();
      if (destinoRuta == target) return true;
      if (target == 'ocotal' && origenRuta == target) return true;
      return false;
    }).toList();
  }
}