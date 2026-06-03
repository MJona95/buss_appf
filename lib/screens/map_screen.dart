import 'package:flutter/material.dart';
import '../core/database/local_database.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/custom_text_field.dart';
import '../models/station_model.dart';
import '../widgets/station_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulsingController;
  List<StationModel> _allStations = [];
  List<StationModel> _displayedStations = [];
  String? _selectedStationId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize pulsing animation for the map marker
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadStations();
  }

  @override
  void dispose() {
    _pulsingController.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    try {
      final dbData = await LocalDatabase.instance.getStations();
      setState(() {
        _allStations = dbData.map((map) => StationModel.fromDbMap(map)).toList();
        _displayedStations = List.from(_allStations);
        if (_displayedStations.isNotEmpty) {
          _selectedStationId = _displayedStations.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchStations(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedStations = List.from(_allStations);
      } else {
        _displayedStations = _allStations
            .where((station) =>
                station.name.toLowerCase().contains(query.toLowerCase()) ||
                station.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.menu, color: AppTheme.onBackgroundColor),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Explore Stations',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.borderVariantColor.withOpacity(0.3),
                                width: 1.0,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDfmA772YTD-GSL31OxXmelhuAJJzcgqDkm4xHZ3f9MrCgMB-msRbm8fKT7PsZavgZ4yJl_9hTJ3NUTHgmFYOGFlec961jMrOJcSvoHv5oBWAji8GINiDKU_0v_JPo5borQTv3jhOY2pwePP4NKJ0PYVxg3pFoolFqZsU3V7sZItD4ntoOD8Lkg0O2UV6oEAG9ZIuApjVqdodwz8Sah73Ak_v0xN-IoQP8GDt4OmYZQoWd7zBIckQfIBuy5CzgNx0meokfam2kwhYN0',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Interactive Map Section representation
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCzZRu6ib6N6hqP0MOblKyLdifx3JaiRgQdp2eWNJQX24sOhpSY1ryYMVz0IDQg2Im9UODJ4X-JXk4ItDE2eBkBgYsRauZVPQ8KkLSW5MTUW8ea24oW3TKnmOe7q9UUflWcdGE4GsoLyC-rjxGksX_qQUtS_2m-uh284bIyy2hfpSb24hH8PNFltk-XqeP9goSvPCmj_ErcgE4jo8eB14zVrnkMqwnKl0jIHZVvgMyqx7MK8Pn-mymTlp23kbcWEycohMYLnNou-a6R',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Floating Map Actions
                        Positioned(
                          bottom: 24,
                          right: 24,
                          child: Column(
                            children: [
                              FloatingActionButton.small(
                                heroTag: 'my_loc',
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: AppTheme.primaryColor,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Locating user position...'),
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.my_location),
                              ),
                              const SizedBox(height: 12),
                              FloatingActionButton.small(
                                heroTag: 'add_station',
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: const CircleBorder(),
                                onPressed: () {},
                                child: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        // Pulsing location marker
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.17,
                          left: MediaQuery.of(context).size.width * 0.5 - 12,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulsingController,
                                builder: (context, child) {
                                  return Container(
                                    width: 24 + (24 * _pulsingController.value),
                                    height: 24 + (24 * _pulsingController.value),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.2 * (1.0 - _pulsingController.value)),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
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
                                  });
                                },
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Premium fleet banner
                          Container(
                            height: 128,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 100), // padding for floating navbar
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
