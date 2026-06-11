import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import 'common/custom_button.dart';
import 'common/custom_badge.dart';
import 'common/custom_card.dart';
import '../models/bus_model.dart';

class BusUnitCard extends StatelessWidget {
  final BusModel bus;

  const BusUnitCard({super.key, required this.bus});

  Future<void> _contactBus(BuildContext context) async {
    final rawNumber = bus.phoneNumber.replaceAll(RegExp(r'\+'), '');
    final uri = Uri.parse(
      'https://wa.me/$rawNumber?text=Hola%20Unidad%20${bus.number},%20me%20gustaria%20obtener%20informacion.',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo abrir WhatsApp. Teléfono: ${bus.phoneNumber}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aspect Ratio Image Header
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: AppTheme.surfaceContainerLow,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBtUnxYol0ZhSbJ2UgrmSrKx58x5ZDO7XL3lV4uyr8FwMhWxBS42GassybZfNUqCK7QespJD7nQdPsKnKlTLqoGWnejAFvnrRdmuJyDhiK2TS9bN_md3dUYQmWKRlYR7Y2ZutA_AooEDWjIE1QmULjtrdyYPF7nxUdHrtiE7mcIfMjzhVZJY6qPA1ROppvDb7VTFqfxelf2dya43d8ZzHsrtEEJ5dEnhSXlbja1F9ijTtuCa6N1YB2gJ4qRInsbp2XoI1p-cOCkaKsH',
                    fit: BoxFit.cover,
                    color: bus.isEnServicio ? null : Colors.grey,
                    colorBlendMode: bus.isEnServicio
                        ? null
                        : BlendMode.saturation,
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
              // Status Badge
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Capacity Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unidad ${bus.number}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.model,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'CAPACIDAD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        Text(
                          '${bus.capacity} Pax',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Operating Hours
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
                          Text(
                            bus.operatingHours,
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

                // Current Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: AppTheme.secondaryColor,
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
                          Text(
                            bus.currentLocation,
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

                // Action WhatsApp Button or Blocked
                if (bus.isEnServicio)
                  ContactButton(
                    text: 'Contactar Unidad',
                    onPressed: () => _contactBus(context),
                  )
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
