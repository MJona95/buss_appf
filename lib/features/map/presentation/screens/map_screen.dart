import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/widgets/custom_card.dart';
import 'package:buss_app/core/widgets/custom_text_field.dart';
import 'package:buss_app/core/widgets/custom_top_app_bar.dart';
import '../../domain/entities/station.dart';
import '../../domain/usecases/filter_rutas.dart';
import '../controllers/map_controller.dart';
import '../widgets/station_card.dart';
import '../widgets/vehicle_marker_builder.dart';

class MapScreen extends StatefulWidget {
  final bool isActive;

  const MapScreen({super.key, this.isActive = true});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Map<String, BitmapDescriptor> _markerCache = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(12.865416, -86.273062),
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    _preloadVehicleMarkers();
  }

  Future<void> _preloadVehicleMarkers() async {
    final cache = <String, BitmapDescriptor>{};
    for (final tipo in VehicleMarkerBuilder.tipos) {
      cache[tipo] = await VehicleMarkerBuilder.markerFor(tipo);
    }
    if (mounted) setState(() => _markerCache = cache);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(MapController controller) {
    return controller.displayedStations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: station.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          controller.selectedStationId == station.id
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueAzure,
        ),
        onTap: () {
          controller.selectStation(station.id);
          _animateToStation(station);
        },
      );
    }).toSet();
  }

  Set<Polyline> _buildPolylines(MapController controller) {
    final selectedId = controller.selectedRutaId;
    final baseColors = const [
      Color(0xFF3949AB),
      Color(0xFF00897B),
      Color(0xFFD81B60),
      Color(0xFFF4511E),
    ];
    return controller.rutasVisibles.map((ruta) {
      final index = controller.rutasMapa.indexWhere((r) => r.id == ruta.id);
      final colorIndex = index < 0 ? 0 : index % baseColors.length;
      final isSelected = ruta.id == selectedId;
      final color = isSelected
          ? baseColors[colorIndex].withAlpha(255)
          : baseColors[colorIndex].withAlpha(120);
      return Polyline(
        polylineId: PolylineId('ruta_${ruta.id}'),
        points: ruta.puntos
            .map((p) => LatLng(p.latitud, p.longitud))
            .toList(),
        color: color,
        width: isSelected ? 7 : 4,
        onTap: () => controller.selectRuta(ruta.id),
      );
    }).toSet();
  }

  Set<Marker> _buildVehicleMarkers(MapController controller) {
    final vehiculos = {
      for (final v in controller.vehiculosVisibles) v.id: v,
    };
    return controller.vehiculoPosiciones.entries
        .where((entry) => vehiculos.containsKey(entry.key))
        .map((entry) {
      final vehiculo = vehiculos[entry.key];
      final posicion = entry.value;
      final tipo = vehiculo?.tipoCodigo ?? 'bus';
      return Marker(
        markerId: MarkerId('vehiculo_${entry.key}'),
        position: LatLng(posicion.latitud, posicion.longitud),
        infoWindow: InfoWindow(
          title: vehiculo?.nombre ?? 'Unidad',
          snippet: vehiculo != null
              ? '${vehiculo.placa ?? ''} · Sale ${vehiculo.horaSalida}'
                    '${vehiculo.horaLlegada != null ? ' · Llega ${vehiculo.horaLlegada} (estimado)' : ''}'
              : '${vehiculo?.placa ?? ''} · Ruta activa',
        ),
        icon: _markerCache[tipo] ??
            BitmapDescriptor.defaultMarkerWithHue(_vehiculoHue(tipo)),
      );
    }).toSet();
  }

  static double _vehiculoHue(String tipoCodigo) {
    switch (tipoCodigo) {
      case 'microbus':
        return BitmapDescriptor.hueViolet;
      case 'taxi':
        return BitmapDescriptor.hueYellow;
      case 'car':
        return BitmapDescriptor.hueGreen;
      case 'van':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _animateToStation(Station station) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(station.latitude, station.longitude),
          zoom: 14.5,
        ),
      ),
    );
  }

  Future<void> _centerOnUser(MapController controller) async {
    try {
      final position = await controller.centerOnUser();
      if (position == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación.')),
        );
        return;
      }
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MapController>();
    final stationMarkers = _buildMarkers(controller);
    final vehicleMarkers = _buildVehicleMarkers(controller);
    final polylines = _buildPolylines(controller);

    return Scaffold(
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: CustomTopAppBar(
                        title: 'Explore Stations',
                        profileImageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDfmA772YTD-GSL31OxXmelhuAJJzcgqDkm4xHZ3f9MrCgMB-msRbm8fKT7PsZavgZ4yJl_9hTJ3NUTHgmFYOGFlec961jMrOJcSvoHv5oBWAji8GINiDKU_0v_JPo5borQTv3jhOY2pwePP4NKJ0PYVxg3pFoolFqZsU3V7sZItD4ntoOD8Lkg0O2UV6oEAG9ZIuApjVqdodwz8Sah73Ak_v0xN-IoQP8GDt4OmYZQoWd7zBIckQfIBuy5CzgNx0meokfam2kwhYN0',
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: _initialCameraPosition,
                            markers: {...stationMarkers, ...vehicleMarkers},
                            polylines: polylines,
                            onMapCreated: (mapController) {
                              _mapController = mapController;
                              final selected = controller.selectedStation;
                              if (selected != null) {
                                _animateToStation(selected);
                              }
                            },
                            myLocationEnabled: controller.myLocationEnabled,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            gestureRecognizers:
                                <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          right: 24,
                          child: Column(
                            children: [
                              FloatingActionButton.small(
                                heroTag: 'zoom_in',
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppTheme.primaryColor,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                                child: const Icon(Icons.add),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.small(
                                heroTag: 'zoom_out',
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppTheme.primaryColor,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                                child: const Icon(Icons.remove),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.small(
                                heroTag: 'my_loc',
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppTheme.primaryColor,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () => _centerOnUser(controller),
                                child: const Icon(Icons.my_location),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.small(
                                heroTag: 'sim_mode',
                                backgroundColor: controller.simulation
                                    ? AppTheme.primaryColor
                                    : Colors.white.withOpacity(0.9),
                                foregroundColor: controller.simulation
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () => controller.toggleSimulation(),
                                child: Icon(
                                  controller.simulation
                                      ? Icons.speed
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.small(
                                heroTag: 'add_station',
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () {},
                                child: const Icon(Icons.add_location_alt),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchTextField(
                              placeholder: 'Search for a station...',
                              onChanged: controller.search,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 38,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (final filtro in [
                                    FilterRutasPorDestino.todos,
                                    ...FilterRutasPorDestino.destinos,
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _DestinoChip(
                                        label: filtro ==
                                                FilterRutasPorDestino.todos
                                            ? 'Todas'
                                            : 'A $filtro',
                                        isActive: controller.filtroRuta ==
                                            filtro,
                                        onTap: () => controller
                                            .setFiltroRuta(filtro),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nearby Stations',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () => controller.search(''),
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (controller.displayedStations.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('No stations found'),
                              ),
                            )
                          else
                            ...controller.displayedStations.map(
                              (station) => StationCard(
                                station: station,
                                isSelected:
                                    controller.selectedStationId == station.id,
                                onTap: () {
                                  controller.selectStation(station.id);
                                  _animateToStation(station);
                                },
                              ),
                            ),
                          const SizedBox(height: 24),
                          CustomCard(
                            borderRadius: 16,
                            backgroundColor: AppTheme.primaryColor,
                            borderColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                              height: 128,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  const Positioned(
                                    right: -20,
                                    bottom: -20,
                                    child: Icon(
                                      Icons.bolt_rounded,
                                      size: 140,
                                      color: Colors.white10,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ZENITH EXCLUSIVE',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Live-tracked Premium Fleet',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DestinoChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DestinoChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.borderVariantColor.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
