import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/api/google_maps_api.dart';
import '../core/database/local_database.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_top_app_bar.dart';
import '../widgets/common/custom_card.dart';
import '../models/station_model.dart';
import '../widgets/station_card.dart';

class MapScreen extends StatefulWidget {
  final bool isActive;

  const MapScreen({super.key, this.isActive = true});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<StationModel> _allStations = [];
  List<StationModel> _displayedStations = [];
  String? _selectedStationId;
  bool _isLoading = true;
  bool _myLocationEnabled = false;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(12.865416, -86.273062), // Center of Nicaragua
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    debugPrint(
      'Initializing Map Screen. Configuration endpoint: ${GoogleMapsApi.staticMapUrl}',
    );
    _loadStations();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 

    if (mounted) {
      setState(() {
        _myLocationEnabled = true;
      });
    }
  }

  Future<void> _centerOnUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied.'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _myLocationEnabled = true;
        });
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    try {
      final dbData = await LocalDatabase.instance.getStations();
      setState(() {
        _allStations = dbData
            .map((map) => StationModel.fromDbMap(map))
            .toList();
        _displayedStations = List.from(_allStations);
        if (_displayedStations.isNotEmpty) {
          _selectedStationId = _displayedStations.first.id;
        }
        _isLoading = false;
        _buildMarkers();
      });

      if (_displayedStations.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animateToStation(_displayedStations.first);
        });
      }
    } catch (e) {
      debugPrint('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _buildMarkers() {
    setState(() {
      _markers.clear();
      for (final station in _displayedStations) {
        _markers.add(
          Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude, station.longitude),
            infoWindow: InfoWindow(
              title: station.name,
              snippet: station.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _selectedStationId == station.id
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueAzure,
            ),
            onTap: () {
              setState(() {
                _selectedStationId = station.id;
                _buildMarkers();
              });
              _animateToStation(station);
            },
          ),
        );
      }
    });
  }

  void _animateToStation(StationModel station) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(station.latitude, station.longitude),
          zoom: 14.5,
        ),
      ),
    );
  }

  void _searchStations(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedStations = List.from(_allStations);
      } else {
        _displayedStations = _allStations
            .where(
              (station) =>
                  station.name.toLowerCase().contains(query.toLowerCase()) ||
                  station.address.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      _buildMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TopAppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: CustomTopAppBar(
                        title: 'Explore Stations',
                        profileImageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDfmA772YTD-GSL31OxXmelhuAJJzcgqDkm4xHZ3f9MrCgMB-msRbm8fKT7PsZavgZ4yJl_9hTJ3NUTHgmFYOGFlec961jMrOJcSvoHv5oBWAji8GINiDKU_0v_JPo5borQTv3jhOY2pwePP4NKJ0PYVxg3pFoolFqZsU3V7sZItD4ntoOD8Lkg0O2UV6oEAG9ZIuApjVqdodwz8Sah73Ak_v0xN-IoQP8GDt4OmYZQoWd7zBIckQfIBuy5CzgNx0meokfam2kwhYN0',
                      ),
                    ),

                    // Interactive Map Section representation
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: _initialCameraPosition,
                            markers: _markers,
                            onMapCreated: (controller) {
                              _mapController = controller;
                              if (_selectedStationId != null) {
                                final selected = _allStations.firstWhere(
                                  (s) => s.id == _selectedStationId,
                                  orElse: () => _allStations.first,
                                );
                                _animateToStation(selected);
                              }
                            },
                            myLocationEnabled: _myLocationEnabled,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                          ),
                        ),
                        // Floating Map Actions
                        Positioned(
                          bottom: 24,
                          right: 24,
                          child: Column(
                            children: [
                              // Zoom In Button
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
                              // Zoom Out Button
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
                              // My Location (Center) Button
                              FloatingActionButton.small(
                                heroTag: 'my_loc',
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppTheme.primaryColor,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: _centerOnUserLocation,
                                child: const Icon(Icons.my_location),
                              ),
                              const SizedBox(height: 8),
                              // Add Station (Placeholder) Button
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

                    // Search Bar Overlay floating at the top of the stations sheet
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SearchTextField(
                          placeholder: 'Search for a station...',
                          onChanged: _searchStations,
                        ),
                      ),
                    ),

                    // Station List
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
                                onPressed: () {},
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
                          if (_displayedStations.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('No stations found'),
                              ),
                            )
                          else
                            ..._displayedStations.map(
                              (station) => StationCard(
                                station: station,
                                isSelected: _selectedStationId == station.id,
                                onTap: () {
                                  setState(() {
                                    _selectedStationId = station.id;
                                    _buildMarkers();
                                  });
                                  _animateToStation(station);
                                },
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Premium fleet banner
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ZENITH EXCLUSIVE',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
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
                          const SizedBox(
                            height: 100,
                          ), // padding for floating navbar
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
