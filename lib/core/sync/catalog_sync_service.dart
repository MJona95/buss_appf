import 'package:flutter/foundation.dart';

import '../api/supabase_client.dart';
import '../database/local_database.dart';

class CatalogSyncService {
  CatalogSyncService(this._database);

  final LocalDatabase _database;

  Future<bool> syncIfNeeded() async {
    final remoteVersion = await SupabaseManager.fetchCatalogVersion();
    if (remoteVersion == null) return false;

    final localVersion = await _database.getCatalogVersion();
    if (remoteVersion == localVersion) return false;

    final catalog = await SupabaseManager.fetchCatalog();
    if (catalog == null) return false;

    await _database.replaceCatalog(
      tiposVehiculo: catalog['tipos_vehiculo'] ?? const [],
      vehiculos: catalog['vehiculos'] ?? const [],
      rutas: catalog['rutas'] ?? const [],
      vehiculoRutas: catalog['vehiculo_rutas'] ?? const [],
      estaciones: catalog['estaciones'] ?? const [],
      rutaEstaciones: catalog['ruta_estaciones'] ?? const [],
      tarifas: catalog['tarifas'] ?? const [],
      rutaPuntos: catalog['ruta_puntos'] ?? const [],
      horarios: catalog['horarios'] ?? const [],
    );
    await _database.setCatalogVersion(remoteVersion);
    debugPrint('Catalog synced to version $remoteVersion');
    return true;
  }
}
