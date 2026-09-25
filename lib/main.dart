import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/supabase_client.dart';
import 'core/database/local_database.dart';
import 'core/di/app_providers.dart';
import 'core/layout/main_layout.dart';
import 'core/sync/catalog_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.database;
  await SupabaseManager.initialize();
  await CatalogSyncService(LocalDatabase.instance).syncIfNeeded();
  runApp(const BussApp());
}

class BussApp extends StatelessWidget {
  const BussApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'BussApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            darkTheme: AppTheme.darkThemeData,
            themeMode: themeController.themeMode,
            home: const MainNavigationContainer(),
          );
        },
      ),
    );
  }
}
