import 'package:buss_app/core/database/local_database.dart';

class StationLocalDatasource {
  final LocalDatabase database;

  StationLocalDatasource(this.database);

  Future<List<Map<String, dynamic>>> getStations() => database.getEstaciones();
}
