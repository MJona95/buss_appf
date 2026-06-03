import 'package:flutter/material.dart';
import 'core/api/supabase_client.dart';
import 'core/database/local_database.dart';
import 'core/theme/app_theme.dart';
import 'layout/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database instance
  // (Triggers onCreate schema definition & seeding)
  await LocalDatabase.instance.database;

  // Initialize Supabase configuration gracefully
  await SupabaseManager.initialize();

  runApp(const BussApp());
}

class BussApp extends StatelessWidget {
  const BussApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusGo / Zenith Transit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const MainNavigationContainer(),
    );
  }
}
