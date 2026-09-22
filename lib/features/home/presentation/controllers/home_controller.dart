import 'package:flutter/foundation.dart';

import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/usecases/trip_usecases.dart';

class HomeController extends ChangeNotifier {
  HomeController({required TripRepository repository})
      : _getTrips = GetTrips(repository),
        _filterTrips = FilterTrips(),
        _toggleBookmark = ToggleBookmark(repository);

  final GetTrips _getTrips;
  final FilterTrips _filterTrips;
  final ToggleBookmark _toggleBookmark;

  List<Trip> _allTrips = [];
  List<Trip> _trips = [];
  String _query = '';
  String _selectedCategory = 'Todos';
  bool _isLoading = true;
  String? _error;

  List<Trip> get trips => _trips;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const categories = ['Todos', 'Público', 'Privado'];

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allTrips = await _getTrips();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _query = query;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    _allTrips = await _toggleBookmark(_allTrips, id);
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _trips = _filterTrips(
      all: _allTrips,
      query: _query,
      category: _selectedCategory,
    );
  }
}
