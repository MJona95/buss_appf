import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  // In-memory fallback data for Web
  List<Map<String, dynamic>> _webStations = [];
  List<Map<String, dynamic>> _webBuses = [];
  final List<Map<String, dynamic>> _webBookings = [];

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('buss_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE stations (
        id TEXT PRIMARY KEY,
        name $textType,
        address $textType,
        distance $realType,
        next_route $textType,
        next_time_mins $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE buses (
        id TEXT PRIMARY KEY,
        number $textType,
        model $textType,
        capacity $integerType,
        operating_hours $textType,
        current_location $textType,
        phone_number $textType,
        status $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        pickup_location $textType,
        dropoff_location $textType,
        departure_date $textType,
        pickup_time $textType,
        status $textType
      )
    ''');

    // Seed initial data
    await _seedInitialData(db);
  }

  Future _seedInitialData(Database db) async {
    // Seed stations
    await db.insert('stations', {
      'id': 'st_1',
      'name': 'Central Station',
      'address': '422 Grand Ave, Downtown',
      'distance': 0.4,
      'next_route': 'Route 42',
      'next_time_mins': 3,
    });
    await db.insert('stations', {
      'id': 'st_2',
      'name': 'North Terminal',
      'address': '88 Skyway Blvd, North Park',
      'distance': 1.2,
      'next_route': 'Route 101',
      'next_time_mins': 8,
    });
    await db.insert('stations', {
      'id': 'st_3',
      'name': 'Market Square',
      'address': '15 Trade St, West End',
      'distance': 1.8,
      'next_route': 'Route 15',
      'next_time_mins': 12,
    });

    // Seed buses
    await db.insert('buses', {
      'id': 'bus_1',
      'number': '#42',
      'model': 'Mercedes-Benz Sprinter 2024',
      'capacity': 18,
      'operating_hours': '06:00 AM - 10:00 PM',
      'current_location': 'Terminal Central del Norte',
      'phone_number': '+521234567890',
      'status': 'En Servicio',
    });
    await db.insert('buses', {
      'id': 'bus_2',
      'number': '#15',
      'model': 'Irizar i8 Executive',
      'capacity': 44,
      'operating_hours': 'Próxima Salida: Mañana 08:30 AM',
      'current_location': 'Talleres Centrales',
      'phone_number': '+521987654321',
      'status': 'En Mantenimiento',
    });
    await db.insert('buses', {
      'id': 'bus_3',
      'number': '#88',
      'model': 'Volkswagen Crafter 2023',
      'capacity': 21,
      'operating_hours': '05:00 AM - 11:00 PM',
      'current_location': 'Terminal Central del Norte',
      'phone_number': '+521234567890',
      'status': 'En Servicio',
    });
  }

  // Fallback seeding for Web
  void _seedWebDataIfEmpty() {
    if (_webStations.isEmpty) {
      _webStations = [
        {
          'id': 'st_1',
          'name': 'Central Station',
          'address': '422 Grand Ave, Downtown',
          'distance': 0.4,
          'next_route': 'Route 42',
          'next_time_mins': 3,
        },
        {
          'id': 'st_2',
          'name': 'North Terminal',
          'address': '88 Skyway Blvd, North Park',
          'distance': 1.2,
          'next_route': 'Route 101',
          'next_time_mins': 8,
        },
        {
          'id': 'st_3',
          'name': 'Market Square',
          'address': '15 Trade St, West End',
          'distance': 1.8,
          'next_route': 'Route 15',
          'next_time_mins': 12,
        }
      ];
    }

    if (_webBuses.isEmpty) {
      _webBuses = [
        {
          'id': 'bus_1',
          'number': '#42',
          'model': 'Mercedes-Benz Sprinter 2024',
          'capacity': 18,
          'operating_hours': '06:00 AM - 10:00 PM',
          'current_location': 'Terminal Central del Norte',
          'phone_number': '+521234567890',
          'status': 'En Servicio',
        },
        {
          'id': 'bus_2',
          'number': '#15',
          'model': 'Irizar i8 Executive',
          'capacity': 44,
          'operating_hours': 'Próxima Salida: Mañana 08:30 AM',
          'current_location': 'Talleres Centrales',
          'phone_number': '+521987654321',
          'status': 'En Mantenimiento',
        },
        {
          'id': 'bus_3',
          'number': '#88',
          'model': 'Volkswagen Crafter 2023',
          'capacity': 21,
          'operating_hours': '05:00 AM - 11:00 PM',
          'current_location': 'Terminal Central del Norte',
          'phone_number': '+521234567890',
          'status': 'En Servicio',
        }
      ];
    }
  }

  // --- CRUD API ---

  Future<List<Map<String, dynamic>>> getStations() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      return _webStations;
    }
    final db = await database;
    return await db!.query('stations');
  }

  Future<List<Map<String, dynamic>>> getBuses() async {
    if (kIsWeb) {
      _seedWebDataIfEmpty();
      return _webBuses;
    }
    final db = await database;
    return await db!.query('buses');
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    if (kIsWeb) {
      return _webBookings;
    }
    final db = await database;
    return await db!.query('bookings', orderBy: 'departure_date DESC');
  }

  Future<int> insertBooking(Map<String, dynamic> booking) async {
    if (kIsWeb) {
      _webBookings.insert(0, booking);
      return 1;
    }
    final db = await database;
    return await db!.insert('bookings', booking);
  }
}
