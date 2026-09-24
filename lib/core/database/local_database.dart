import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'catalog_seed.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  List<Map<String, dynamic>> _tiposVehiculo = [];
  List<Map<String, dynamic>> _vehiculos = [];
  List<Map<String, dynamic>> _rutas = [];
  List<Map<String, dynamic>> _vehiculoRutas = [];
  List<Map<String, dynamic>> _estaciones = [];
  List<Map<String, dynamic>> _rutaEstaciones = [];
  List<Map<String, dynamic>> _tarifas = [];
  List<Map<String, dynamic>> _rutaPuntos = [];
  List<Map<String, dynamic>> _horarios = [];
  final List<Map<String, dynamic>> _reservas = [];
  final Set<String> _favoritos = {};
  int _catalogVersion = 0;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('buss_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 8,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDB,
      onOpen: (db) => _ensureEstacionesPoblado(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await _dropLegacy(db);
          await _createCatalog(db);
          await _seedCatalog(db);
          return;
        }
        if (oldVersion < 5) {
          await _addVehicleSpeedColumns(db);
          await _createRutaPuntosTable(db);
        }
        if (oldVersion < 6) {
          await _createHorariosTable(db);
          await _seedHorarios(db);
        }
        if (oldVersion < 7) {
          await _ensureEstacionesPoblado(db);
        }
        if (oldVersion < 8) {
          await _addTipoServicioColumns(db);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createCatalog(db);
    await _seedCatalog(db);
  }

  Future<void> _dropLegacy(Database db) async {
    await db.execute('DROP TABLE IF EXISTS stations');
    await db.execute('DROP TABLE IF EXISTS buses');
    await db.execute('DROP TABLE IF EXISTS bookings');
    await db.execute('DROP TABLE IF EXISTS trips');
  }

  Future<void> _createCatalog(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tipos_vehiculo (
        id TEXT PRIMARY KEY,
        codigo TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vehiculos (
        id TEXT PRIMARY KEY,
        nombre TEXT,
        placa TEXT UNIQUE,
        tipo_vehiculo_id TEXT NOT NULL,
        tipo_transporte TEXT NOT NULL,
        capacidad INTEGER,
        velocidad_maxima INTEGER NOT NULL DEFAULT 80,
        hora_salida TEXT NOT NULL DEFAULT '06:00',
        tipo_servicio TEXT NOT NULL DEFAULT 'ruteado',
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT,
        FOREIGN KEY (tipo_vehiculo_id) REFERENCES tipos_vehiculo(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rutas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        origen_nombre TEXT NOT NULL,
        destino_nombre TEXT NOT NULL,
        origen_lat REAL NOT NULL,
        origen_lng REAL NOT NULL,
        destino_lat REAL NOT NULL,
        destino_lng REAL NOT NULL,
        tipo_servicio TEXT NOT NULL DEFAULT 'ruteado',
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vehiculo_rutas (
        id TEXT PRIMARY KEY,
        vehiculo_id TEXT NOT NULL,
        ruta_id TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT,
        UNIQUE (vehiculo_id, ruta_id),
        FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id) ON DELETE CASCADE,
        FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS estaciones (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        poblado INTEGER NOT NULL DEFAULT 0,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT
      )
    ''');
    await _ensureEstacionesPoblado(db);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ruta_estaciones (
        id TEXT PRIMARY KEY,
        ruta_id TEXT NOT NULL,
        estacion_id TEXT NOT NULL,
        orden_parada INTEGER NOT NULL,
        UNIQUE (ruta_id, estacion_id),
        UNIQUE (ruta_id, orden_parada),
        FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE,
        FOREIGN KEY (estacion_id) REFERENCES estaciones(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tarifas (
        id TEXT PRIMARY KEY,
        ruta_id TEXT NOT NULL,
        tipo_vehiculo_id TEXT NOT NULL,
        monto REAL NOT NULL,
        moneda TEXT DEFAULT 'NIO',
        vigente_desde TEXT NOT NULL,
        vigente_hasta TEXT,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT,
        UNIQUE (ruta_id, tipo_vehiculo_id, vigente_desde),
        FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE,
        FOREIGN KEY (tipo_vehiculo_id) REFERENCES tipos_vehiculo(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS configuracion (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        version INTEGER NOT NULL DEFAULT 0,
        actualizado_en TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reservas (
        id TEXT PRIMARY KEY,
        origen TEXT NOT NULL,
        destino TEXT NOT NULL,
        fecha_salida TEXT NOT NULL,
        hora_recogida TEXT NOT NULL,
        estado TEXT NOT NULL,
        monto_cotizacion REAL NOT NULL,
        estado_sync TEXT NOT NULL,
        creado_en TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favoritos (
        ruta_id TEXT PRIMARY KEY
      )
    ''');
    await _createRutaPuntosTable(db);
    await _createHorariosTable(db);
  }

  Future<void> _ensureEstacionesPoblado(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE estaciones ADD COLUMN poblado INTEGER NOT NULL DEFAULT 0',
      );
    } catch (_) {
      // Columna ya existe en bases previas.
    }
  }

  Future<void> _createHorariosTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS horarios (
        id TEXT PRIMARY KEY,
        ruta_id TEXT NOT NULL,
        vehiculo_id TEXT NOT NULL,
        hora_salida TEXT NOT NULL,
        hora_llegada TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        creado_en TEXT,
        UNIQUE (ruta_id, vehiculo_id, hora_salida),
        FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE,
        FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _seedHorarios(Database db) async {
    for (final row in horariosSeed) {
      await db.insert('horarios', Map<String, dynamic>.from(row));
    }
  }

  Future<void> _createRutaPuntosTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ruta_puntos (
        id TEXT PRIMARY KEY,
        ruta_id TEXT NOT NULL,
        orden INTEGER NOT NULL,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        UNIQUE (ruta_id, orden),
        FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _addVehicleSpeedColumns(Database db) async {
    await db.execute(
      "ALTER TABLE vehiculos ADD COLUMN velocidad_maxima INTEGER NOT NULL DEFAULT 80",
    );
    await db.execute(
      "ALTER TABLE vehiculos ADD COLUMN hora_salida TEXT NOT NULL DEFAULT '06:00'",
    );
  }

  Future<void> _addTipoServicioColumns(Database db) async {
    try {
      await db.execute(
        "ALTER TABLE vehiculos ADD COLUMN tipo_servicio TEXT NOT NULL DEFAULT 'ruteado'",
      );
    } catch (_) {
      // Columna ya existe en bases previas.
    }
    try {
      await db.execute(
        "ALTER TABLE rutas ADD COLUMN tipo_servicio TEXT NOT NULL DEFAULT 'ruteado'",
      );
    } catch (_) {
      // Columna ya existe en bases previas.
    }
  }

  Future<void> _seedCatalog(Database db) async {
    Future<void> insertAll(String table, List<Map<String, dynamic>> rows) async {
      for (final row in rows) {
        await db.insert(table, Map<String, dynamic>.from(row));
      }
    }

    await insertAll('tipos_vehiculo', tiposVehiculoSeed);
    await insertAll('estaciones', estacionesSeed);
    await insertAll('rutas', rutasSeed);
    await insertAll('vehiculos', vehiculosSeed);
    await insertAll('vehiculo_rutas', vehiculoRutasSeed);
    await insertAll('ruta_estaciones', rutaEstacionesSeed);
    await insertAll('tarifas', tarifasSeed);
    await _seedHorarios(db);
    await db.insert('configuracion', {
      'id': 1,
      'version': 0,
      'actualizado_en': DateTime.now().toIso8601String(),
    });
  }

  void _seedWebDataIfEmpty() {
    if (_tiposVehiculo.isNotEmpty) return;
    _tiposVehiculo = _clone(tiposVehiculoSeed);
    _estaciones = _clone(estacionesSeed);
    _rutas = _clone(rutasSeed);
    _vehiculos = _clone(vehiculosSeed);
    _vehiculoRutas = _clone(vehiculoRutasSeed);
    _rutaEstaciones = _clone(rutaEstacionesSeed);
    _tarifas = _clone(tarifasSeed);
    _rutaPuntos = [];
    _horarios = _clone(horariosSeed);
    _catalogVersion = 0;
  }

  Future<int> getCatalogVersion() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      return _catalogVersion;
    }
    final db = await database;
    final rows = await db!.query('configuracion', where: 'id = 1');
    if (rows.isEmpty) return 0;
    return (rows.first['version'] as num?)?.toInt() ?? 0;
  }

  Future<void> setCatalogVersion(int version) async {
    final now = DateTime.now().toIso8601String();
    if (kIsWeb) {
      _catalogVersion = version;
      return;
    }
    final db = await database;
    await db!.update(
      'configuracion',
      {'version': version, 'actualizado_en': now},
      where: 'id = 1',
    );
  }

  Future<void> replaceCatalog({
    required List<Map<String, dynamic>> tiposVehiculo,
    required List<Map<String, dynamic>> vehiculos,
    required List<Map<String, dynamic>> rutas,
    required List<Map<String, dynamic>> vehiculoRutas,
    required List<Map<String, dynamic>> estaciones,
    required List<Map<String, dynamic>> rutaEstaciones,
    required List<Map<String, dynamic>> tarifas,
    required List<Map<String, dynamic>> horarios,
  }) async {
    if (kIsWeb) {
      _tiposVehiculo = _clone(tiposVehiculo.map(_normalizeTipo));
      _vehiculos = _clone(vehiculos.map(_normalizeVehiculo));
      _rutas = _clone(rutas.map(_normalizeRuta));
      _vehiculoRutas = _clone(vehiculoRutas.map(_normalizeVehiculoRuta));
      _estaciones = _clone(estaciones.map(_normalizeEstacion));
      _rutaEstaciones = _clone(rutaEstaciones.map(_normalizeRutaEstacion));
      _tarifas = _clone(tarifas.map(_normalizeTarifa));
      _horarios = _clone(horarios.map(_normalizeHorario));
      return;
    }

    final db = await database;
    await db!.transaction((txn) async {
      await txn.delete('horarios');
      await txn.delete('ruta_estaciones');
      await txn.delete('vehiculo_rutas');
      await txn.delete('tarifas');
      await txn.delete('vehiculos');
      await txn.delete('estaciones');
      await txn.delete('rutas');
      await txn.delete('tipos_vehiculo');

      Future<void> insertAll(
        String table,
        Iterable<Map<String, dynamic>> rows,
      ) async {
        for (final row in rows) {
          await txn.insert(table, row);
        }
      }

      await insertAll('tipos_vehiculo', tiposVehiculo.map(_normalizeTipo));
      await insertAll('estaciones', estaciones.map(_normalizeEstacion));
      await insertAll('rutas', rutas.map(_normalizeRuta));
      await insertAll('vehiculos', vehiculos.map(_normalizeVehiculo));
      await insertAll(
        'vehiculo_rutas',
        vehiculoRutas.map(_normalizeVehiculoRuta),
      );
      await insertAll(
        'ruta_estaciones',
        rutaEstaciones.map(_normalizeRutaEstacion),
      );
      await insertAll('tarifas', tarifas.map(_normalizeTarifa));
      await insertAll('horarios', horarios.map(_normalizeHorario));
    });
  }

  Future<List<Map<String, dynamic>>> getRutasConTarifa() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      final now = DateTime.now();
      return _rutas.where((ruta) => _asBool(ruta['activo'])).map((ruta) {
        final tarifa = _tarifaVigente(ruta['id'] as String, now);
        final transporte = _tipoTransporteDeRuta(ruta['id'] as String);
        return {
          ...ruta,
          'monto': tarifa?['monto'] ?? 0,
          'moneda': tarifa?['moneda'] ?? 'NIO',
          'tipo_transporte': transporte,
          'hora_salida': _primerHorarioActivo(ruta['id'] as String)?['hora_salida'],
          'hora_llegada': _primerHorarioActivo(ruta['id'] as String)?['hora_llegada'],
        };
      }).toList();
    }

    final db = await database;
    return db!.rawQuery('''
      SELECT
        r.id,
        r.nombre,
        r.origen_nombre,
        r.destino_nombre,
        r.tipo_servicio,
        r.activo,
        (
          SELECT t.monto FROM tarifas t
          WHERE t.ruta_id = r.id
            AND t.activo = 1
            AND datetime(t.vigente_desde) <= datetime('now')
            AND (t.vigente_hasta IS NULL OR datetime(t.vigente_hasta) > datetime('now'))
          ORDER BY t.vigente_desde DESC
          LIMIT 1
        ) AS monto,
        (
          SELECT t.moneda FROM tarifas t
          WHERE t.ruta_id = r.id
            AND t.activo = 1
            AND datetime(t.vigente_desde) <= datetime('now')
            AND (t.vigente_hasta IS NULL OR datetime(t.vigente_hasta) > datetime('now'))
          ORDER BY t.vigente_desde DESC
          LIMIT 1
        ) AS moneda,
        (
          SELECT v.tipo_transporte
          FROM vehiculo_rutas vr
          JOIN vehiculos v ON v.id = vr.vehiculo_id
          WHERE vr.ruta_id = r.id AND vr.activo = 1
          ORDER BY CASE WHEN v.tipo_transporte = 'public' THEN 0 ELSE 1 END
          LIMIT 1
        ) AS tipo_transporte,
        (
          SELECT h.hora_salida
          FROM horarios h
          WHERE h.ruta_id = r.id AND h.activo = 1
          ORDER BY h.hora_salida ASC
          LIMIT 1
        ) AS hora_salida,
        (
          SELECT h.hora_llegada
          FROM horarios h
          WHERE h.ruta_id = r.id AND h.activo = 1
          ORDER BY h.hora_salida ASC
          LIMIT 1
        ) AS hora_llegada
      FROM rutas r
      WHERE r.activo = 1
    ''');
  }

  Future<List<Map<String, dynamic>>> getVehiculos() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      return _vehiculos.map((vehiculo) {
        final tipo = _tiposVehiculo.firstWhere(
          (item) => item['id'] == vehiculo['tipo_vehiculo_id'],
          orElse: () => {'codigo': '', 'nombre': ''},
        );
        final rutas = _vehiculoRutas
            .where(
              (item) =>
                  item['vehiculo_id'] == vehiculo['id'] &&
                  _asBool(item['activo']),
            )
            .map((item) {
              final match = _rutas.where(
                (candidate) => candidate['id'] == item['ruta_id'],
              );
              return match.isEmpty ? '' : match.first['nombre'] as String? ?? '';
            })
            .where((nombre) => nombre.isNotEmpty)
            .join(', ');
        final horario = _horarioDeVehiculo(vehiculo['id'] as String);
        return {
          ...vehiculo,
          'tipo_codigo': tipo['codigo'],
          'tipo_nombre': tipo['nombre'],
          'rutas_asignadas': rutas,
          'hora_salida': horario?['hora_salida'],
          'hora_llegada': horario?['hora_llegada'],
        };
      }).toList();
    }

    final db = await database;
    return db!.rawQuery('''
      SELECT
        v.id,
        v.nombre,
        v.placa,
        v.tipo_transporte,
        v.capacidad,
        v.activo,
        v.tipo_servicio,
        tv.codigo AS tipo_codigo,
        tv.nombre AS tipo_nombre,
        (
          SELECT GROUP_CONCAT(r.nombre, ', ')
          FROM vehiculo_rutas vr
          JOIN rutas r ON r.id = vr.ruta_id
          WHERE vr.vehiculo_id = v.id AND vr.activo = 1
        ) AS rutas_asignadas,
        (
          SELECT MIN(h.hora_salida)
          FROM horarios h
          WHERE h.vehiculo_id = v.id AND h.activo = 1
        ) AS hora_salida,
        (
          SELECT MAX(h.hora_llegada)
          FROM horarios h
          WHERE h.vehiculo_id = v.id AND h.activo = 1
        ) AS hora_llegada
      FROM vehiculos v
      JOIN tipos_vehiculo tv ON tv.id = v.tipo_vehiculo_id
    ''');
  }

  Future<List<Map<String, dynamic>>> getEstaciones() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      return _estaciones.where((estacion) => _asBool(estacion['activo'])).map((
        estacion,
      ) {
        final rutas = _rutaEstaciones
            .where((item) => item['estacion_id'] == estacion['id'])
            .toList()
          ..sort(
            (a, b) => (a['orden_parada'] as int).compareTo(
              b['orden_parada'] as int,
            ),
          );
        String siguiente = '';
        if (rutas.isNotEmpty) {
          final match = _rutas.where(
            (candidate) => candidate['id'] == rutas.first['ruta_id'],
          );
          siguiente =
              match.isEmpty ? '' : match.first['nombre'] as String? ?? '';
        }
        final horario = rutas.isEmpty
            ? null
            : _primerHorarioActivo(rutas.first['ruta_id'] as String);
        return {
          ...estacion,
          'ruta_id': rutas.isEmpty ? null : (rutas.first['ruta_id'] as String?),
          'siguiente_ruta': siguiente,
          'hora_salida': horario?['hora_salida'],
          'hora_llegada': horario?['hora_llegada'],
          'tarifas': _tarifasEstacionWeb(rutas),
        };
      }).toList();
    }

    final db = await database;
    final rows = await db!.rawQuery('''
      SELECT
        e.id,
        e.nombre,
        e.latitud,
        e.longitud,
        e.activo,
        e.poblado,
        (
          SELECT re.ruta_id FROM ruta_estaciones re
          WHERE re.estacion_id = e.id
          ORDER BY re.orden_parada
          LIMIT 1
        ) AS ruta_id,
        (
          SELECT r.nombre
          FROM ruta_estaciones re
          JOIN rutas r ON r.id = re.ruta_id
          WHERE re.estacion_id = e.id
          ORDER BY re.orden_parada
          LIMIT 1
        ) AS siguiente_ruta,
        (
          SELECT h.hora_salida
          FROM horarios h
          WHERE h.activo = 1
            AND h.ruta_id = (
              SELECT re.ruta_id FROM ruta_estaciones re
              WHERE re.estacion_id = e.id
              ORDER BY re.orden_parada
              LIMIT 1
            )
          ORDER BY h.hora_salida ASC
          LIMIT 1
        ) AS hora_salida,
        (
          SELECT h.hora_llegada
          FROM horarios h
          WHERE h.activo = 1
            AND h.ruta_id = (
              SELECT re.ruta_id FROM ruta_estaciones re
              WHERE re.estacion_id = e.id
              ORDER BY re.orden_parada
              LIMIT 1
            )
          ORDER BY h.hora_salida ASC
          LIMIT 1
        ) AS hora_llegada
      FROM estaciones e
      WHERE e.activo = 1
    ''');
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row);
      map['tarifas'] = await _tarifasEstacionSqlite(
        db,
        '${map['id']}',
      );
      result.add(map);
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getRutasMapa() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      final rutas = _rutas.where((ruta) => _asBool(ruta['activo'])).toList();
      final result = <Map<String, dynamic>>[];
      for (final ruta in rutas) {
        final asignaciones = _vehiculoRutas.where(
          (item) => item['ruta_id'] == ruta['id'] && _asBool(item['activo']),
        );
        for (final asignacion in asignaciones) {
          final vehiculo = _vehiculos.firstWhere(
            (candidate) => candidate['id'] == asignacion['vehiculo_id'],
            orElse: () => const {},
          );
          if (vehiculo.isEmpty) continue;
          final tipo = _tiposVehiculo.firstWhere(
            (candidate) => candidate['id'] == vehiculo['tipo_vehiculo_id'],
            orElse: () => const {'codigo': 'bus'},
          );
          final horario = _horarios.where(
            (candidate) =>
                candidate['ruta_id'] == ruta['id'] &&
                candidate['vehiculo_id'] == vehiculo['id'] &&
                _asBool(candidate['activo']),
          );
          String horaSalida =
              vehiculo['hora_salida']?.toString() ?? '06:00';
          String? horaLlegada;
          if (horario.isNotEmpty) {
            final primero = horario.first;
            horaSalida = '${primero['hora_salida']}';
            horaLlegada = '${primero['hora_llegada']}';
          }
          result.add({
            'ruta_id': ruta['id'],
            'ruta_nombre': ruta['nombre'],
            'origen_nombre': ruta['origen_nombre'],
            'destino_nombre': ruta['destino_nombre'],
            'vehiculo_id': vehiculo['id'],
            'vehiculo_nombre': vehiculo['nombre'],
            'placa': vehiculo['placa'],
            'tipo_codigo': tipo['codigo'],
            'velocidad_maxima': vehiculo['velocidad_maxima'] ?? 80,
            'hora_salida': horaSalida,
            'hora_llegada': horaLlegada,
          });
        }
      }
      return result;
    }

    final db = await database;
    return db!.rawQuery('''
      SELECT
        r.id AS ruta_id,
        r.nombre AS ruta_nombre,
        r.origen_nombre,
        r.destino_nombre,
        v.id AS vehiculo_id,
        v.nombre AS vehiculo_nombre,
        v.placa,
        tv.codigo AS tipo_codigo,
        v.velocidad_maxima,
        COALESCE(
          (
            SELECT h.hora_salida FROM horarios h
            WHERE h.vehiculo_id = v.id
              AND h.ruta_id = r.id
              AND h.activo = 1
            ORDER BY h.hora_salida ASC
            LIMIT 1
          ),
          v.hora_salida
        ) AS hora_salida,
        (
          SELECT h.hora_llegada FROM horarios h
          WHERE h.vehiculo_id = v.id
            AND h.ruta_id = r.id
            AND h.activo = 1
          ORDER BY h.hora_salida ASC
          LIMIT 1
        ) AS hora_llegada
      FROM rutas r
      JOIN vehiculo_rutas vr ON vr.ruta_id = r.id AND vr.activo = 1
      JOIN vehiculos v ON v.id = vr.vehiculo_id
      JOIN tipos_vehiculo tv ON tv.id = v.tipo_vehiculo_id
      WHERE r.activo = 1
      ORDER BY r.nombre, v.nombre
    ''');
  }

  Future<List<Map<String, dynamic>>> getPuntosRuta() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      return _rutaPuntos.toList();
    }
    final db = await database;
    return db!.rawQuery('''
      SELECT ruta_id, orden, latitud, longitud
      FROM ruta_puntos
      ORDER BY ruta_id, orden
    ''');
  }

  Future<Map<String, Map<String, dynamic>>> getRutaGeoContext() async {
    final context = <String, Map<String, dynamic>>{};
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      for (final ruta in _rutas) {
        context[ruta['id'] as String] = {
          'origen_lat': ruta['origen_lat'],
          'origen_lng': ruta['origen_lng'],
          'destino_lat': ruta['destino_lat'],
          'destino_lng': ruta['destino_lng'],
          'estaciones': const [],
        };
      }
      for (final re in _rutaEstaciones) {
        final estacion = _estaciones.firstWhere(
          (candidate) => candidate['id'] == re['estacion_id'],
          orElse: () => const {},
        );
        if (estacion.isEmpty) continue;
        final ruta = context[re['ruta_id'] as String];
        if (ruta == null) continue;
        (ruta['estaciones'] as List).add({
          'latitud': estacion['latitud'],
          'longitud': estacion['longitud'],
        });
      }
      return context;
    }

    final db = await database;
    final rutas = await db!.rawQuery('''
      SELECT id, nombre, origen_lat, origen_lng, destino_lat, destino_lng
      FROM rutas
      WHERE activo = 1
    ''');
    for (final ruta in rutas) {
      context['${ruta['id']}'] = {
        'origen_lat': ruta['origen_lat'],
        'origen_lng': ruta['origen_lng'],
        'destino_lat': ruta['destino_lat'],
        'destino_lng': ruta['destino_lng'],
        'estaciones': <Map<String, dynamic>>[],
      };
    }
    final estaciones = await db.rawQuery('''
      SELECT re.ruta_id, e.latitud, e.longitud
      FROM ruta_estaciones re
      JOIN estaciones e ON e.id = re.estacion_id
      WHERE e.activo = 1
      ORDER BY re.ruta_id, re.orden_parada
    ''');
    for (final estacion in estaciones) {
      final ruta = context['${estacion['ruta_id']}'];
      if (ruta == null) continue;
      (ruta['estaciones'] as List).add({
        'latitud': estacion['latitud'],
        'longitud': estacion['longitud'],
      });
    }
    return context;
  }

  Future<void> replacePuntosRuta(
    String rutaId,
    List<Map<String, dynamic>> puntos,
  ) async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      _rutaPuntos.removeWhere((punto) => punto['ruta_id'] == rutaId);
      for (var i = 0; i < puntos.length; i++) {
        _rutaPuntos.add({
          'id': '$rutaId:${i + 1}',
          'ruta_id': rutaId,
          'orden': i + 1,
          'latitud': puntos[i]['latitud'],
          'longitud': puntos[i]['longitud'],
        });
      }
      return;
    }
    final db = await database;
    await db!.transaction((txn) async {
      await txn.delete('ruta_puntos', where: 'ruta_id = ?', whereArgs: [rutaId]);
      for (var i = 0; i < puntos.length; i++) {
        await txn.insert('ruta_puntos', {
          'id': '$rutaId:${i + 1}',
          'ruta_id': rutaId,
          'orden': i + 1,
          'latitud': puntos[i]['latitud'],
          'longitud': puntos[i]['longitud'],
        });
      }
    });
  }

  Future<Set<String>> getFavoritos() async {
    if (kIsWeb) {
      return Set<String>.from(_favoritos);
    }
    final db = await database;
    final rows = await db!.query('favoritos');
    return rows.map((row) => row['ruta_id'] as String).toSet();
  }

  Future<void> updateFavorito(String rutaId, bool isBookmarked) async {
    if (kIsWeb) {
      if (isBookmarked) {
        _favoritos.add(rutaId);
      } else {
        _favoritos.remove(rutaId);
      }
      return;
    }
    final db = await database;
    if (isBookmarked) {
      await db!.insert('favoritos', {
        'ruta_id': rutaId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db!.delete('favoritos', where: 'ruta_id = ?', whereArgs: [rutaId]);
    }
  }

  Future<List<Map<String, dynamic>>> getReservas() async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_reservas);
    }
    final db = await database;
    return db!.query('reservas', orderBy: 'fecha_salida DESC');
  }

  Future<int> insertReserva(Map<String, dynamic> reserva) async {
    if (kIsWeb) {
      _reservas.insert(0, Map<String, dynamic>.from(reserva));
      return 1;
    }
    final db = await database;
    return db!.insert('reservas', reserva);
  }

  Future<int> updateReserva(String id, Map<String, dynamic> values) async {
    if (kIsWeb) {
      final index = _reservas.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _reservas[index] = {..._reservas[index], ...values};
      }
      return 1;
    }
    final db = await database;
    return db!.update('reservas', values, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic>? _tarifaVigente(String rutaId, DateTime now) {
    final vigentes = _tarifas.where((tarifa) {
      if (tarifa['ruta_id'] != rutaId || !_asBool(tarifa['activo'])) {
        return false;
      }
      final desde =
          DateTime.tryParse('${tarifa['vigente_desde']}') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final hastaRaw = tarifa['vigente_hasta'];
      final hasta = hastaRaw == null
          ? null
          : DateTime.tryParse('$hastaRaw');
      if (desde.isAfter(now)) return false;
      if (hasta != null && !hasta.isAfter(now)) return false;
      return true;
    }).toList()..sort((a, b) {
      final aDate = DateTime.tryParse('${a['vigente_desde']}') ?? DateTime(0);
      final bDate = DateTime.tryParse('${b['vigente_desde']}') ?? DateTime(0);
      return bDate.compareTo(aDate);
    });
    return vigentes.isEmpty ? null : vigentes.first;
  }

  List<Map<String, dynamic>> _tarifasVigentesDeRutaWeb(String rutaId) {
    final now = DateTime.now();
    String nombreRuta = '';
    for (final r in _rutas) {
      if (r['id'] == rutaId) {
        nombreRuta = r['nombre'] as String? ?? '';
        break;
      }
    }
    final porTipo = <String, Map<String, dynamic>>{};
    for (final tarifa in _tarifas) {
      if (tarifa['ruta_id'] != rutaId || !_asBool(tarifa['activo'])) {
        continue;
      }
      final desde = DateTime.tryParse('${tarifa['vigente_desde']}') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final hastaRaw = tarifa['vigente_hasta'];
      final hasta =
          hastaRaw == null ? null : DateTime.tryParse('$hastaRaw');
      if (desde.isAfter(now)) continue;
      if (hasta != null && !hasta.isAfter(now)) continue;
      final tipoId = '${tarifa['tipo_vehiculo_id']}';
      final actual = porTipo[tipoId];
      final fechaActual = actual == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.tryParse('${actual['vigente_desde']}') ??
                DateTime.fromMillisecondsSinceEpoch(0);
      if (actual == null || desde.isAfter(fechaActual)) {
        porTipo[tipoId] = tarifa;
      }
    }
    final result = <Map<String, dynamic>>[];
    for (final tarifa in porTipo.values) {
      String tipoNombre = '';
      for (final tipo in _tiposVehiculo) {
        if (tipo['id'] == tarifa['tipo_vehiculo_id']) {
          tipoNombre = tipo['nombre'] as String? ?? '';
          break;
        }
      }
      result.add({
        'ruta': nombreRuta,
        'tipo': tipoNombre,
        'monto': (tarifa['monto'] as num).toDouble(),
        'moneda': tarifa['moneda']?.toString() ?? 'NIO',
      });
    }
    result.sort((a, b) => (a['monto'] as num).compareTo(b['monto'] as num));
    return result;
  }

  List<Map<String, dynamic>> _tarifasEstacionWeb(
    List<Map<String, dynamic>> rutasDeEstacion,
  ) {
    final tarifas = <Map<String, dynamic>>[];
    for (final item in rutasDeEstacion) {
      tarifas.addAll(_tarifasVigentesDeRutaWeb(item['ruta_id'] as String));
    }
    tarifas.sort((a, b) => (a['monto'] as num).compareTo(b['monto'] as num));
    return tarifas;
  }

  Future<List<Map<String, dynamic>>> _tarifasVigentesDeRutaSqlite(
    Database db,
    String rutaId,
  ) async {
    final now = DateTime.now().toIso8601String();
    final rows = await db.rawQuery('''
      SELECT t.monto, t.moneda, r.nombre AS ruta_nombre, tv.nombre AS tipo_nombre
      FROM tarifas t
      JOIN rutas r ON r.id = t.ruta_id
      JOIN tipos_vehiculo tv ON tv.id = t.tipo_vehiculo_id
      WHERE t.ruta_id = ?
        AND t.activo = 1
        AND t.vigente_hasta IS NULL
        AND t.vigente_desde <= ?
      ORDER BY t.monto ASC
    ''', [rutaId, now]);
    return rows.map((row) {
      return {
        'ruta': '${row['ruta_nombre']}',
        'tipo': '${row['tipo_nombre']}',
        'monto': (row['monto'] as num).toDouble(),
        'moneda': row['moneda']?.toString() ?? 'NIO',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _tarifasEstacionSqlite(
    Database db,
    String estacionId,
  ) async {
    final rutasDeEstacion = await db.rawQuery('''
      SELECT re.ruta_id
      FROM ruta_estaciones re
      JOIN rutas r ON r.id = re.ruta_id
      WHERE re.estacion_id = ?
      ORDER BY re.orden_parada
    ''', [estacionId]);
    final tarifas = <Map<String, dynamic>>[];
    for (final item in rutasDeEstacion) {
      tarifas.addAll(
        await _tarifasVigentesDeRutaSqlite(db, item['ruta_id'] as String),
      );
    }
    tarifas.sort((a, b) => (a['monto'] as num).compareTo(b['monto'] as num));
    return tarifas;
  }

  String _tipoTransporteDeRuta(String rutaId) {
    final vehiculoIds = _vehiculoRutas
        .where(
          (item) => item['ruta_id'] == rutaId && _asBool(item['activo']),
        )
        .map((item) => item['vehiculo_id'])
        .toSet();
    final vehiculos = _vehiculos.where(
      (vehiculo) => vehiculoIds.contains(vehiculo['id']),
    );
    if (vehiculos.any((vehiculo) => vehiculo['tipo_transporte'] == 'public')) {
      return 'public';
    }
    if (vehiculos.any((vehiculo) => vehiculo['tipo_transporte'] == 'private')) {
      return 'private';
    }
    return 'public';
  }

  Map<String, dynamic> _normalizeTipo(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'codigo': row['codigo'],
      'nombre': row['nombre'],
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeVehiculo(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'nombre': row['nombre'],
      'placa': row['placa'],
      'tipo_vehiculo_id': '${row['tipo_vehiculo_id']}',
      'tipo_transporte': row['tipo_transporte'],
      'capacidad': (row['capacidad'] as num?)?.toInt(),
      'velocidad_maxima': (row['velocidad_maxima'] as num?)?.toInt() ?? 80,
      'hora_salida': row['hora_salida']?.toString() ?? '06:00',
      'tipo_servicio': row['tipo_servicio']?.toString() ?? 'ruteado',
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeRuta(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'nombre': row['nombre'],
      'origen_nombre': row['origen_nombre'],
      'destino_nombre': row['destino_nombre'],
      'origen_lat': (row['origen_lat'] as num).toDouble(),
      'origen_lng': (row['origen_lng'] as num).toDouble(),
      'destino_lat': (row['destino_lat'] as num).toDouble(),
      'destino_lng': (row['destino_lng'] as num).toDouble(),
      'tipo_servicio': row['tipo_servicio']?.toString() ?? 'ruteado',
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeVehiculoRuta(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'vehiculo_id': '${row['vehiculo_id']}',
      'ruta_id': '${row['ruta_id']}',
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeEstacion(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'nombre': row['nombre'],
      'latitud': (row['latitud'] as num).toDouble(),
      'longitud': (row['longitud'] as num).toDouble(),
      'poblado': _asSqliteBool(row['poblado']),
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeRutaEstacion(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'ruta_id': '${row['ruta_id']}',
      'estacion_id': '${row['estacion_id']}',
      'orden_parada': (row['orden_parada'] as num).toInt(),
    };
  }

  Map<String, dynamic> _normalizeTarifa(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'ruta_id': '${row['ruta_id']}',
      'tipo_vehiculo_id': '${row['tipo_vehiculo_id']}',
      'monto': (row['monto'] as num).toDouble(),
      'moneda': row['moneda'] ?? 'NIO',
      'vigente_desde': row['vigente_desde']?.toString(),
      'vigente_hasta': row['vigente_hasta']?.toString(),
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeHorario(Map<String, dynamic> row) {
    return {
      'id': '${row['id']}',
      'ruta_id': '${row['ruta_id']}',
      'vehiculo_id': '${row['vehiculo_id']}',
      'hora_salida': row['hora_salida']?.toString() ?? '06:00',
      'hora_llegada': row['hora_llegada']?.toString() ?? '06:00',
      'activo': _asSqliteBool(row['activo']),
      'creado_en': row['creado_en']?.toString(),
    };
  }

  Map<String, dynamic>? _primerHorarioActivo(String rutaId) {
    final horarios = _horarios
        .where(
          (item) => item['ruta_id'] == rutaId && _asBool(item['activo']),
        )
        .toList()
      ..sort(
        (a, b) => '${a['hora_salida']}'.compareTo('${b['hora_salida']}'),
      );
    return horarios.isEmpty ? null : horarios.first;
  }

  Map<String, dynamic>? _horarioDeVehiculo(String vehiculoId) {
    final horarios = _horarios.where(
      (item) =>
          item['vehiculo_id'] == vehiculoId && _asBool(item['activo']),
    );
    final salidas = horarios
        .map((item) => '${item['hora_salida']}'.toString())
        .toList()
      ..sort();
    if (salidas.isEmpty) return null;
    final llegadas = horarios
        .map((item) => '${item['hora_llegada']}'.toString())
        .toList()
      ..sort();
    return {'hora_salida': salidas.first, 'hora_llegada': llegadas.last};
  }

  List<Map<String, dynamic>> _clone(Iterable<Map<String, dynamic>> rows) {
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  int _asSqliteBool(dynamic value) {
    if (value == true || value == 1 || value == '1' || value == 'true') {
      return 1;
    }
    return 0;
  }

  bool _asBool(dynamic value) => _asSqliteBool(value) == 1;
}
