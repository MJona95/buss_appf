import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_datasources.dart';
import '../models/trip_mapper.dart';

class TripRepositoryImpl implements TripRepository {
  final TripLocalDatasource local;

  TripRepositoryImpl({required this.local});

  @override
  Future<List<Trip>> getTrips() async {
    final rows = await local.getRutas();
    final favoritos = await local.getFavoritos();
    return rows
        .map(
          (row) => TripMapper.fromDbMap(
            row,
            isBookmarked: favoritos.contains('${row['id']}'),
          ),
        )
        .toList();
  }

  @override
  Future<void> updateBookmark(String id, bool isBookmarked) {
    return local.updateFavorito(id, isBookmarked);
  }
}
