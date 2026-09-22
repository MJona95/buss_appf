import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/widgets/custom_card.dart';
import 'package:buss_app/core/widgets/custom_text_field.dart';
import 'package:buss_app/core/widgets/custom_top_app_bar.dart';
import '../controllers/home_controller.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onSearchPressed;

  const HomeScreen({super.key, this.onSearchPressed});

  static const _categoryIcons = [
    Icons.directions_bus,
    Icons.public,
    Icons.lock,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    CustomTopAppBar(
                      showSearch: true,
                      onSearchPressed: onSearchPressed,
                      profileImageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBEtHO9h1Djccsb89omYfU_Oqz5vYRxZZ-pMXTyAunBsePhtahZSthUlnx5L4A4SKXekRr2mz27TWNMS4N_BtTisp3sNbvoq2WAkin0xJpoV_UPlbWdEs0IWg6SoXiLjg_r9G8Sp0S3uJqN2evrkdHiQ4Zp7lYPz3oB4FBefpnamm5KTIusdvOGmUWckNLEsMJ4zWMTg_prF7h3KHGvhDnvshr3Mz3u9dIU2KoDvaJ9nailFokZ5jNC_jGhs2wWZ7bnnV66dYaKfyye',
                    ),
                    const SizedBox(height: 24),
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
                    SearchTextField(
                      placeholder: 'Where do you want to go?',
                      onChanged: controller.search,
                      onFilterPressed: () {},
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: HomeController.categories.length,
                        itemBuilder: (context, index) {
                          final catName = HomeController.categories[index];
                          final catIcon = _categoryIcons[index];
                          final isActive =
                              catName == controller.selectedCategory;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: CustomCard(
                              borderRadius: 24,
                              backgroundColor: isActive
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderColor: isActive
                                  ? AppTheme.primaryColor
                                  : AppTheme.borderVariantColor
                                      .withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              onTap: () => controller.selectCategory(catName),
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
                    if (controller.trips.isEmpty)
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
                      ...controller.trips.map(
                        (trip) => TripCard(
                          trip: trip,
                          onBookmarkToggled: (_) =>
                              controller.toggleBookmark(trip.id),
                          onViewDetails: () {
                            if (trip.isAvailable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Detalles de ${trip.name}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }
}
