import '../entities/bus.dart';
import '../repositories/bus_repository.dart';

class GetBuses {
  final BusRepository repository;

  GetBuses(this.repository);

  Future<List<Bus>> call() => repository.getBuses();
}

class FilterBuses {
  List<Bus> call({
    required List<Bus> all,
    required String query,
    required String filter,
  }) {
    var result = all;

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where(
            (bus) =>
                bus.number.toLowerCase().contains(q) ||
                bus.model.toLowerCase().contains(q),
          )
          .toList();
    }

    if (filter == 'Disponibles') {
      result = result.where((bus) => bus.isEnServicio).toList();
    } else if (filter == 'En Mantenimiento') {
      result = result.where((bus) => !bus.isEnServicio).toList();
    } else if (filter == 'Ruteados') {
      result = result.where((bus) => bus.serviceType != 'expreso').toList();
    } else if (filter == 'Expresos') {
      result = result.where((bus) => bus.serviceType == 'expreso').toList();
    }

    return result;
  }
}
