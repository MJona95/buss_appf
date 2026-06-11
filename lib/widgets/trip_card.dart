import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'common/custom_button.dart';
import 'common/custom_card.dart';
import 'common/custom_badge.dart';
import '../models/trip_model.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onViewDetails;
  final ValueChanged<bool>? onBookmarkToggled;

  const TripCard({
    super.key,
    required this.trip,
    required this.onViewDetails,
    this.onBookmarkToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: trip.isAvailable ? 1.0 : 0.7,
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Image.network(
                      trip.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.directions_bus,
                            size: 64,
                            color: AppTheme.secondaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: CustomBadge(
                    label: trip.rating.toStringAsFixed(1),
                    backgroundColor: Colors.white.withOpacity(0.9),
                    textColor: AppTheme.onBackgroundColor,
                    leading: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
                // Bookmark Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () {
                      if (onBookmarkToggled != null) {
                        onBookmarkToggled!(!trip.isBookmarked);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        trip.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Trip metadata details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.companyName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${trip.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/${trip.duration}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call to action button
                SizedBox(
                  width: 130,
                  child: SecondaryButton(
                    text: trip.isAvailable ? 'View details' : 'Not available',
                    isEnabled: trip.isAvailable,
                    onPressed: onViewDetails,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
