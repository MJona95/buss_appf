import 'package:buss_app/core/database/local_database.dart';

class TripLocalDatasource {
  final LocalDatabase database;

  TripLocalDatasource(this.database);

  Future<List<Map<String, dynamic>>> getRutas() => database.getRutasConTarifa();

  Future<Set<String>> getFavoritos() => database.getFavoritos();

  Future<void> updateFavorito(String id, bool isBookmarked) {
    return database.updateFavorito(id, isBookmarked);
  }
}
