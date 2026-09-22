import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:buss_app/core/services/location_service.dart';

import '../../domain/entities/ruta_mapa.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/ruta_mapa_repository.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/usecases/get_rutas_mapa.dart';
import '../../domain/usecases/filter_rutas.dart';
import '../../domain/usecases/route_geometry.dart';
import '../../domain/usecases/station_usecases.dart';

class MapController extends ChangeNotifier {
  MapController({
    required StationRepository repository,
    required RutaMapaRepository rutasRepository,
    required LocationService locationService,
  })  : _getStations = GetStations(repository),
        _getRutasMapa = GetRutasMapa(rutasRepository),
        _searchStations = SearchStations(),
        _updateDistances = UpdateStationDistances(locationService),
        _locationService = locationService;

  final GetStations _getStations;
  final GetRutasMapa _getRutasMapa;
  final SearchStations _searchStations;
  final UpdateStationDistances _updateDistances;
  final LocationService _locationService;

  static const _tickDuration = Duration(seconds: 1);

  List<Station> _allStations = [];
  List<Station> _displayedStations = [];
  String? _selectedStationId;
  String _query = '';
  bool _isLoading = true;
  bool _myLocationEnabled = false;
  String? _error;

  List<RutaMapa> _rutasMapa = [];
  final Map<String, GeoPunto> _vehiculoPosiciones = {};
  String? _selectedRutaId;
  String _filtroRuta = FilterRutasPorDestino.todos;
  bool _simulation = false;
  DateTime _simulationStartedAt = DateTime.now();
  Timer? _timer;

  List<Station> get displayedStations => _displayedStations;
  List<Station> get allStations => _allStations;
  String? get selectedStationId => _selectedStationId;
  bool get isLoading => _isLoading;
  bool get myLocationEnabled => _myLocationEnabled;
  String? get error => _error;

  List<RutaMapa> get rutasMapa => _rutasMapa;
  Map<String, GeoPunto> get vehiculoPosiciones =>
      Map.unmodifiable(_vehiculoPosiciones);
  String? get selectedRutaId => _selectedRutaId;
  bool get simulation => _simulation;
  String get filtroRuta => _filtroRuta;

  List<RutaMapa> get rutasVisibles =>
      FilterRutasPorDestino.ejecutar(_rutasMapa, _filtroRuta);

  List<VehiculoEnRuta> get vehiculosVisibles {
    return [for (final ruta in rutasVisibles) ...ruta.vehiculos];
  }

  List<VehiculoEnRuta> get vehiculosEnRuta {
    return [for (final ruta in _rutasMapa) ...ruta.vehiculos];
  }

  Station? get selectedStation {
    if (_selectedStationId == null || _allStations.isEmpty) return null;
    return _allStations.firstWhere(
      (station) => station.id == _selectedStationId,
      orElse: () => _allStations.first,
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allStations = await _getStations();
      _rutasMapa = await _getRutasMapa();
      _estimarHorariosEstaciones();
      _applySearch();
      if (_displayedStations.isNotEmpty) {
        _selectedStationId = _displayedStations.first.id;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    await refreshDistances();
    _startAnimation();
  }

  void search(String query) {
    _query = query;
    _applySearch();
    notifyListeners();
  }

  void selectStation(String id) {
    _selectedStationId = id;
    notifyListeners();
  }

  void selectRuta(String? id) {
    _selectedRutaId = id;
    notifyListeners();
  }

  void setFiltroRuta(String filtro) {
    _filtroRuta = filtro;
    final visibles = rutasVisibles;
    _selectedRutaId = visibles.length == 1 ? visibles.first.id : null;
    notifyListeners();
  }

  void toggleSimulation() {
    _simulation = !_simulation;
    if (_simulation) {
      _simulationStartedAt = DateTime.now();
    }
    _tick();
    notifyListeners();
  }

  Future<void> refreshDistances() async {
    _myLocationEnabled = await _locationService.ensurePermission();
    notifyListeners();
    if (!_myLocationEnabled) return;

    final position = await _locationService.getCurrentPosition();
    if (position == null) return;

    _allStations = _updateDistances(
      stations: _allStations,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    _applySearch();
    notifyListeners();
  }

  Future<Position?> centerOnUser() {
    return _locationService.getCurrentPosition();
  }

  void _startAnimation() {
    _timer?.cancel();
    _vehiculoPosiciones.clear();
    _tick();
    _timer = Timer.periodic(_tickDuration, (_) => _tick());
  }

  void _tick() {
    if (_rutasMapa.isEmpty) return;

    _vehiculoPosiciones.clear();
    final now = DateTime.now();
    for (final ruta in _rutasMapa) {
      final totalKm = RouteGeometry.totalKm(ruta.puntos);
      if (totalKm <= 0) continue;
      for (final vehiculo in ruta.vehiculos) {
        final km = RouteGeometry.distanceTraveledKm(
          now: now,
          horaSalida: vehiculo.horaSalida,
          velocidadMaxima: vehiculo.velocidadMaxima,
          simulation: _simulation,
          simulationStartedAt: _simulationStartedAt,
          totalKm: totalKm,
        );
        final posicion = RouteGeometry.interpolate(ruta.puntos, km);
        _vehiculoPosiciones[vehiculo.id] = posicion;
      }
    }
    notifyListeners();
  }

  void _applySearch() {
    _displayedStations = _searchStations(
      all: _allStations,
      query: _query,
    );
  }

  void _estimarHorariosEstaciones() {
    if (_rutasMapa.isEmpty) return;
    _allStations = _allStations.map((station) {
      final rutaId = station.rutaId;
      if (rutaId == null) return station;
      RutaMapa? ruta;
      for (final candidate in _rutasMapa) {
        if (candidate.id == rutaId) {
          ruta = candidate;
          break;
        }
      }
      if (ruta == null || ruta.puntos.isEmpty) return station;
      final totalKm = RouteGeometry.totalKm(ruta.puntos);
      if (totalKm <= 0) return station;
      final kmOrigenEstacion = RouteGeometry.haversineKm(
        ruta.puntos.first,
        GeoPunto(latitud: station.latitude, longitud: station.longitude),
      );
      final inicio = _minutoDe(station.horaSalida);
      final fin = _minutoDe(station.horaLlegada);
      final String? horaLlegada;
      if (station.horaSalida == null || inicio == null || fin == null) {
        horaLlegada = station.horaLlegada;
      } else {
        horaLlegada = RouteGeometry.estimarLlegadaEnEstacion(
          horaSalida: station.horaSalida!,
          kmOrigenEstacion: kmOrigenEstacion,
          kmRuta: totalKm,
          duracionTotalMin: fin - inicio,
        );
      }
      return station.copyWith(horaLlegada: horaLlegada);
    }).toList();
  }

  int? _minutoDe(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}