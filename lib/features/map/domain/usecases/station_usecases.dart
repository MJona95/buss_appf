import 'package:buss_app/core/services/location_service.dart';

import '../entities/station.dart';
import '../repositories/station_repository.dart';

class GetStations {
  final StationRepository repository;

  GetStations(this.repository);

  Future<List<Station>> call() => repository.getStations();
}

class SearchStations {
  List<Station> call({
    required List<Station> all,
    required String query,
  }) {
    if (query.trim().isEmpty) return List.from(all);
    final q = query.toLowerCase();
    return all
        .where(
          (station) =>
              station.name.toLowerCase().contains(q) ||
              station.address.toLowerCase().contains(q),
        )
        .toList();
  }
}

class UpdateStationDistances {
  final LocationService locationService;

  UpdateStationDistances(this.locationService);

  List<Station> call({
    required List<Station> stations,
    required double latitude,
    required double longitude,
  }) {
    return stations
        .map(
          (station) => station.copyWith(
            distance: double.parse(
              locationService
                  .distanceKm(
                    fromLat: latitude,
                    fromLng: longitude,
                    toLat: station.latitude,
                    toLng: station.longitude,
                  )
                  .toStringAsFixed(1),
            ),
          ),
        )
        .toList();
  }
}
