import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_top_app_bar.dart';
import '../widgets/common/custom_card.dart';
import '../models/trip_model.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSearchPressed;

  const HomeScreen({super.key, this.onSearchPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Todos';

  final List<String> categories = ['Todos', 'Express', 'Urbano', 'Interurbano'];
  final List<IconData> categoryIcons = [
    Icons.directions_bus,
    Icons.bolt,
    Icons.location_city,
    Icons.map,
  ];

  // Raw mock list matching the Design file specifications
  final List<TripModel> _allTrips = [
    TripModel(
      id: 'trip_1',
      companyName: 'NILDOWS',
      price: 25.00,
      duration: '10 min-15 min',
      rating: 5.0,
      isBookmarked: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBbGkrDLcoyLutz_HbPky-E6iYYdEgOsKsFbx-FfI0PxdWNFzRBGb8u7wNpgeHqJ8FKs_7nPEdges7V_bn-nzRacLpMv66blwE7RtD8GWXEzp14pzG_czOitDK9VGyqjzCnqKyV-DIBDTGbzGTh1V6RHW5W2Q6oOdaeoH7ppNuIytp4fgWVVI32okfLJ6tXCVekvp52veHZcBGBNeo-Ky4vAvGoSbF9bFhNM4AmP-hcUriBv1CU13TBvvCWpJ72ZRaXpFFklXpzVhsb',
      isAvailable: true,
    ),
    TripModel(
      id: 'trip_2',
      companyName: 'City Coach',
      price: 18.00,
      duration: '30 min-45 min',
      rating: 4.5,
      isBookmarked: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA3iK_AaReJ1sZ9g_9-k_4K66Pm_eBROrVtQxTXgMBIwBFCjRiotQ6dyZJPUqnbFUjicy1HBfApN82ZHTgN1iKPMrhAiKSKkFCO4SSJbo7ILZpYUWai9Kqy6Ylkehn1dmltIdqOGozEogLv1p9gVjf_bcaKVzI8lLK2Mkpxt2IozoPwd2Mb-XZAs4N77q9xrv_El1rtK6ayfOx-JSM5zX1SW1eDqTq2wHdVuwag0zKdRYsh5xFr3UI0mmTbqDKWFYI5H_dTl8tRdRkA',
      isAvailable: false,
    ),
  ];

  late List<TripModel> _trips;

  @override
  void initState() {
    super.initState();
    _trips = List.from(_allTrips);
  }

  void _toggleBookmark(int index) {
    setState(() {
      final trip = _trips[index];
      _trips[index] = TripModel(
        id: trip.id,
        companyName: trip.companyName,
        price: trip.price,
        duration: trip.duration,
        rating: trip.rating,
        isBookmarked: !trip.isBookmarked,
        imageUrl: trip.imageUrl,
        isAvailable: trip.isAvailable,
      );
    });
  }

  void _searchTrips(String query) {
    setState(() {
      if (query.isEmpty) {
        _trips = List.from(_allTrips);
      } else {
        _trips = _allTrips
            .where(
              (trip) =>
                  trip.companyName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // TopAppBar Section
              CustomTopAppBar(
                showSearch: true,
                onSearchPressed: widget.onSearchPressed,
                profileImageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBEtHO9h1Djccsb89omYfU_Oqz5vYRxZZ-pMXTyAunBsePhtahZSthUlnx5L4A4SKXekRr2mz27TWNMS4N_BtTisp3sNbvoq2WAkin0xJpoV_UPlbWdEs0IWg6SoXiLjg_r9G8Sp0S3uJqN2evrkdHiQ4Zp7lYPz3oB4FBefpnamm5KTIusdvOGmUWckNLEsMJ4zWMTg_prF7h3KHGvhDnvshr3Mz3u9dIU2KoDvaJ9nailFokZ5jNC_jGhs2wWZ7bnnV66dYaKfyye',
              ),
              const SizedBox(height: 24),
              // Welcome Text
              const Text(
                'Hi, Welcome',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Explore New Bus Trips',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.56,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Hero Section Image Card
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDsErOqwhORxo4KCK429Q4w-SWmrx1WPGsiZSd1AY-rgCc2sPvSrsgGSbNYGDTAlF9MOfCSE1lcFPPd0WeIWnSIbBJBJ1vM85BbUvy8GQ4dSgFFLs2uxgI8uEECBIJ-rHMwfTRji6o31rBrlcy_zdBdze9NROZQ2IVoTYEpGbepje6W6HUbKG7uNs4M-X6ABd8YhvakhfjZdPeoxC2HdjqR52ZZOyb86meCii8XyYUhvP7HkHqpF3q3aehWHJnrQ_1-3yJrXaOjzab8',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        'Tu viaje comienza aquí',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Search & Filter Input
              SearchTextField(
                placeholder: 'Where do you want to go?',
                onChanged: _searchTrips,
                onFilterPressed: () {},
              ),
              const SizedBox(height: 24),
              // Categories Horizontal List
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final catName = categories[index];
                    final catIcon = categoryIcons[index];
                    final isActive = catName == selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CustomCard(
                        borderRadius: 24,
                        backgroundColor: isActive
                            ? AppTheme.primaryColor
                            : Colors.white,
                        borderColor: isActive
                            ? AppTheme.primaryColor
                            : AppTheme.borderVariantColor.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        onTap: () {
                          setState(() {
                            selectedCategory = catName;
                            if (catName == 'Todos') {
                              _trips = List.from(_allTrips);
                            } else if (catName == 'Express') {
                              _trips = _allTrips
                                  .where((t) => t.companyName == 'NILDOWS')
                                  .toList();
                            } else if (catName == 'Urbano') {
                              _trips = _allTrips
                                  .where((t) => t.companyName == 'City Coach')
                                  .toList();
                            } else {
                              _trips = _allTrips
                                  .where((t) => t.isAvailable)
                                  .toList();
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              catIcon,
                              color: isActive
                                  ? Colors.white
                                  : AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              catName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : AppTheme.onBackgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Trips Cards list
              if (_trips.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No trips found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(
                  _trips.length,
                  (index) => TripCard(
                    trip: _trips[index],
                    onBookmarkToggled: (value) => _toggleBookmark(index),
                    onViewDetails: () {
                      if (_trips[index].isAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Details for ${_trips[index].companyName}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ),
              const SizedBox(height: 100), // Spacing for floating bottom bar
            ],
          ),
        ),
      ),
    );
  }
}
