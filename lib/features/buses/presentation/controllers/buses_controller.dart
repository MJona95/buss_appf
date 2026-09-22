import 'package:flutter/foundation.dart';

import '../../domain/entities/bus.dart';
import '../../domain/repositories/bus_repository.dart';
import '../../domain/usecases/bus_usecases.dart';

class BusesController extends ChangeNotifier {
  BusesController({required BusRepository repository})
      : _getBuses = GetBuses(repository),
        _filterBuses = FilterBuses();

  final GetBuses _getBuses;
  final FilterBuses _filterBuses;

  List<Bus> _allBuses = [];
  List<Bus> _filteredBuses = [];
  String _selectedFilter = 'Todas las Unidades';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  List<Bus> get filteredBuses => _filteredBuses;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allBuses = await _getBuses();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void selectFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredBuses = _filterBuses(
      all: _allBuses,
      query: _searchQuery,
      filter: _selectedFilter,
    );
  }
}
