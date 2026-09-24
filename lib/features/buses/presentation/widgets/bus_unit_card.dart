import 'package:flutter/material.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/widgets/custom_badge.dart';
import 'package:buss_app/core/widgets/custom_button.dart';
import 'package:buss_app/core/widgets/custom_card.dart';
import '../../domain/entities/bus.dart';

class BusUnitCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback? onContact;

  const BusUnitCard({
    super.key,
    required this.bus,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final title = bus.name.isNotEmpty ? bus.name : 'Unidad ${bus.number}';
    final plate = (bus.plate == null || bus.plate!.isEmpty) ? 'S/N' : bus.plate!;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  color: AppTheme.surfaceContainerLow,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBtUnxYol0ZhSbJ2UgrmSrKx58x5ZDO7XL3lV4uyr8FwMhWxBS42GassybZfNUqCK7QespJD7nQdPsKnKlTLqoGWnejAFvnrRdmuJyDhiK2TS9bN_md3dUYQmWKRlYR7Y2ZutA_AooEDWjIE1QmULjtrdyYPF7nxUdHrtiE7mcIfMjzhVZJY6qPA1ROppvDb7VTFqfxelf2dya43d8ZzHsrtEEJ5dEnhSXlbja1F9ijTtuCa6N1YB2gJ4qRInsbp2XoI1p-cOCkaKsH',
                    fit: BoxFit.cover,
                    color: bus.isEnServicio ? null : Colors.grey,
                    colorBlendMode:
                        bus.isEnServicio ? null : BlendMode.saturation,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.directions_bus_filled_rounded,
                          size: 64,
                          color: AppTheme.secondaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: CustomBadge(
                  label: bus.status,
                  isSuccess: bus.isEnServicio,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.model,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        plate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.groups_rounded,
                      label: '${bus.capacity} Pax',
                    ),
                    _InfoChip(
                      icon: Icons.directions_bus_rounded,
                      label: bus.operatingHours,
                    ),
                    _InfoChip(
                      icon: bus.serviceType == 'expreso'
                          ? Icons.bolt_rounded
                          : Icons.alt_route_rounded,
                      label: bus.serviceLabel,
                      highlighted: bus.serviceType == 'expreso',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 20,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Horario de Atención',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.tieneHorario
                                ? bus.horarioLabel
                                : 'Sin horario asignado',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicación Actual',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.currentLocation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (bus.isEnServicio && bus.phoneNumber.isNotEmpty)
                  ContactButton(
                    text: 'Contactar Unidad',
                    onPressed: onContact ?? () {},
                  )
                else if (bus.isEnServicio)
                  const SizedBox.shrink()
                else
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          color: AppTheme.secondaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'No Disponible',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.primaryColor.withValues(alpha: 0.12)
            : AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}