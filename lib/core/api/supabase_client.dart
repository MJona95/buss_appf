import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static const String supabaseUrl = 'https://yxgnienxnvrrdncpbrfq.supabase.co';
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4Z25pZW54bnZycmRuY3BicmZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NTE1OTcsImV4cCI6MjA5MjUyNzU5N30.yaHuWhcTTB4I0tm3qYEG9rMtNsdZ7FRAMmPuohxd1E8',
  );

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (supabaseAnonKey.isEmpty || supabaseAnonKey.contains('placeholder')) {
      debugPrint(
        'Supabase: Missing anon key. Remote sync disabled. '
        'Pass --dart-define=SUPABASE_ANON_KEY=eyJ...',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint(
        'Supabase initialization failed: $e. Running in offline/mock remote mode.',
      );
      _initialized = false;
    }
  }

  static Future<int?> fetchCatalogVersion() async {
    if (!_initialized) return null;
    try {
      final row = await Supabase.instance.client
          .from('configuracion')
          .select('version')
          .eq('id', 1)
          .maybeSingle();
      return (row?['version'] as num?)?.toInt();
    } catch (e) {
      debugPrint('Supabase fetchCatalogVersion error: $e');
      return null;
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>?> fetchCatalog() async {
    if (!_initialized) return null;
    try {
      final client = Supabase.instance.client;
      final results = await Future.wait([
        client.from('tipos_vehiculo').select(),
        client.from('vehiculos').select(),
        client.from('rutas').select(),
        client.from('vehiculo_rutas').select(),
        client.from('estaciones').select(),
        client.from('ruta_estaciones').select(),
        client.from('tarifas').select(),
        client.from('horarios').select(),
      ]);
      return {
        'tipos_vehiculo': _asRows(results[0]),
        'vehiculos': _asRows(results[1]),
        'rutas': _asRows(results[2]),
        'vehiculo_rutas': _asRows(results[3]),
        'estaciones': _asRows(results[4]),
        'ruta_estaciones': _asRows(results[5]),
        'tarifas': _asRows(results[6]),
        'horarios': _asRows(results[7]),
      };
    } catch (e) {
      debugPrint('Supabase fetchCatalog error: $e');
      return null;
    }
  }

  static Future<bool> uploadReserva(Map<String, dynamic> reserva) async {
    if (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('Supabase: Remote sync simulated for reserva: ${reserva['id']}');
      return true;
    }

    try {
      final payload = Map<String, dynamic>.from(reserva)..remove('estado_sync');
      await Supabase.instance.client.from('reservas').insert(payload);
      return true;
    } catch (e) {
      debugPrint('Supabase uploadReserva error: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> _asRows(dynamic response) {
    return List<Map<String, dynamic>>.from(response as List);
  }
}
