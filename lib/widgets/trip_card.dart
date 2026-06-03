import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'common/custom_button.dart';
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.borderVariantColor.withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onBackgroundColor,
                          ),
                        ),
                      ],
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
                        trip.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
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
