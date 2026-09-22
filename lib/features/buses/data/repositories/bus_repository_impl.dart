import '../../domain/entities/bus.dart';
import '../../domain/repositories/bus_repository.dart';
import '../datasources/bus_datasources.dart';
import '../models/bus_mapper.dart';

class BusRepositoryImpl implements BusRepository {
  final BusLocalDatasource local;

  BusRepositoryImpl({required this.local});

  @override
  Future<List<Bus>> getBuses() async {
    final rows = await local.getBuses();
    return rows.map(BusMapper.fromDbMap).toList();
  }
}
