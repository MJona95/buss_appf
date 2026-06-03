import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  // Replace these placeholders with your actual Supabase credentials.
  static const String supabaseUrl = 'https://placeholder-project.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder-anon-key';

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    // If the values are still the placeholders, skip native init to avoid crash.
    if (supabaseUrl.contains('placeholder-project')) {
      debugPrint('Supabase: Using placeholder credentials. Remote sync will be mocked.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint('Supabase initialization failed: $e. Running in offline/mock remote mode.');
      _initialized = false;
    }
  }

  // --- Remote database helper methods ---

  /// Mock or upload a private booking to remote
  static Future<bool> uploadBooking(Map<String, dynamic> booking) async {
    if (!_initialized) {
      // Simulate remote network delay
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('Supabase: Remote sync simulated for booking: ${booking['id']}');
      return true;
    }
    
    try {
      await Supabase.instance.client.from('bookings').insert(booking);
      return true;
    } catch (e) {
      debugPrint('Supabase uploadBooking error: $e');
      return false;
    }
  }

  /// Mock or fetch live station updates
  static Future<List<Map<String, dynamic>>?> fetchLiveStations() async {
    if (!_initialized) {
      return null; // Will fallback to SQLite local database
    }

    try {
      final response = await Supabase.instance.client.from('stations').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase fetchLiveStations error: $e');
      return null;
    }
  }
}
