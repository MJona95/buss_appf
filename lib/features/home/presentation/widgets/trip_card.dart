import 'package:flutter/material.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/widgets/custom_badge.dart';
import 'package:buss_app/core/widgets/custom_button.dart';
import 'package:buss_app/core/widgets/custom_card.dart';
import 'package:buss_app/core/widgets/pressable_scale.dart';
import '../../domain/entities/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
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
                if (trip.rating > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CustomBadge(
                      label: trip.rating.toStringAsFixed(1),
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      textColor: AppTheme.onBackgroundColor,
                      leading: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: PressableScale(
                    pressedScale: 0.85,
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
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                          child: Icon(
                            trip.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            key: ValueKey(trip.isBookmarked),
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                            '${trip.currency} ${trip.price.toStringAsFixed(2)}',
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
                SizedBox(
                  width: 108,
                  child: SecondaryButton(
                    text: trip.isAvailable ? 'View details' : 'Not available',
                    isEnabled: trip.isAvailable,
                    onPressed: onViewDetails,
                  ),
                ),
              ],
            ),
            if (trip.tieneHorario) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      trip.horarioLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
