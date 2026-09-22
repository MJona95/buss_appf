import 'package:buss_app/core/database/local_database.dart';

class MapRoutesLocalDatasource {
  final LocalDatabase database;

  MapRoutesLocalDatasource(this.database);

  Future<List<Map<String, dynamic>>> getRutas() => database.getRutasMapa();

  Future<List<Map<String, dynamic>>> getPuntos() => database.getPuntosRuta();
}