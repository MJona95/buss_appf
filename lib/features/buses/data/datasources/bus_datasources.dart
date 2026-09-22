import 'package:buss_app/core/database/local_database.dart';

class BusLocalDatasource {
  final LocalDatabase database;

  BusLocalDatasource(this.database);

  Future<List<Map<String, dynamic>>> getBuses() => database.getVehiculos();
}
