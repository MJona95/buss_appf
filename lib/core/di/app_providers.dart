import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:buss_app/core/database/local_database.dart';
import 'package:buss_app/core/services/location_service.dart';
import 'package:buss_app/core/services/quote_service.dart';
import 'package:buss_app/core/services/whatsapp_service.dart';
import 'package:buss_app/core/sync/catalog_sync_service.dart';
import 'package:buss_app/features/buses/data/datasources/bus_datasources.dart';
import 'package:buss_app/features/buses/data/repositories/bus_repository_impl.dart';
import 'package:buss_app/features/buses/domain/repositories/bus_repository.dart';
import 'package:buss_app/features/buses/presentation/controllers/buses_controller.dart';
import 'package:buss_app/features/home/data/datasources/trip_datasources.dart';
import 'package:buss_app/features/home/data/repositories/trip_repository_impl.dart';
import 'package:buss_app/features/home/domain/repositories/trip_repository.dart';
import 'package:buss_app/features/home/presentation/controllers/home_controller.dart';
import 'package:buss_app/features/map/data/datasources/map_routes_datasources.dart';
import 'package:buss_app/features/map/data/datasources/osrm_geometry_datasource.dart';
import 'package:buss_app/features/map/data/datasources/station_datasources.dart';
import 'package:buss_app/features/map/data/repositories/ruta_mapa_repository_impl.dart';
import 'package:buss_app/features/map/data/repositories/station_repository_impl.dart';
import 'package:buss_app/features/map/domain/repositories/ruta_mapa_repository.dart';
import 'package:buss_app/features/map/domain/repositories/station_repository.dart';
import 'package:buss_app/features/map/presentation/controllers/map_controller.dart';
import 'package:buss_app/features/private_transport/data/datasources/booking_datasources.dart';
import 'package:buss_app/features/private_transport/data/repositories/booking_repository_impl.dart';
import 'package:buss_app/features/private_transport/domain/repositories/booking_repository.dart';
import 'package:buss_app/features/private_transport/presentation/controllers/booking_controller.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    Provider<LocalDatabase>.value(value: LocalDatabase.instance),
    Provider(create: (context) => CatalogSyncService(context.read())),
    Provider(create: (_) => LocationService()),
    Provider(create: (_) => WhatsAppService()),
    Provider(create: (_) => QuoteService()),
    Provider(create: (context) => TripLocalDatasource(context.read())),
    Provider<TripRepository>(
      create: (context) => TripRepositoryImpl(local: context.read()),
    ),
    Provider(create: (context) => StationLocalDatasource(context.read())),
    Provider<StationRepository>(
      create: (context) => StationRepositoryImpl(local: context.read()),
    ),
    Provider(create: (context) => MapRoutesLocalDatasource(context.read())),
    Provider(create: (_) => OsrmGeometryDatasource()),
    Provider<RutaMapaRepository>(
      create: (context) => RutaMapaRepositoryImpl(
        local: context.read(),
        osrm: context.read(),
      ),
    ),
    Provider(create: (context) => BusLocalDatasource(context.read())),
    Provider<BusRepository>(
      create: (context) => BusRepositoryImpl(local: context.read()),
    ),
    Provider(create: (context) => BookingLocalDatasource(context.read())),
    Provider(create: (_) => BookingRemoteDatasource()),
    Provider<BookingRepository>(
      create: (context) => BookingRepositoryImpl(
        local: context.read(),
        remote: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => HomeController(
        repository: context.read(),
      )..load(),
    ),
    ChangeNotifierProvider(
      create: (context) => MapController(
        repository: context.read(),
        rutasRepository: context.read(),
        locationService: context.read(),
      )..load(),
    ),
    ChangeNotifierProvider(
      create: (context) => BusesController(
        repository: context.read(),
      )..load(),
    ),
    ChangeNotifierProvider(
      create: (context) => BookingController(
        repository: context.read(),
        quoteService: context.read(),
      )..load(),
    ),
  ];
}
