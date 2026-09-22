import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';
import '../datasources/station_datasources.dart';
import '../models/station_mapper.dart';

class StationRepositoryImpl implements StationRepository {
  final StationLocalDatasource local;

  StationRepositoryImpl({required this.local});

  @override
  Future<List<Station>> getStations() async {
    final rows = await local.getStations();
    return rows.map(StationMapper.fromDbMap).toList();
  }
}
