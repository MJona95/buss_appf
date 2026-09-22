import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/widgets/custom_badge.dart';
import 'package:buss_app/core/widgets/custom_card.dart';
import 'package:buss_app/core/widgets/custom_top_app_bar.dart';
import '../../domain/entities/booking.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_form.dart';

class PrivateTransportScreen extends StatelessWidget {
  const PrivateTransportScreen({super.key});

  Future<void> _handleSubmit(
    BuildContext context,
    String pickup,
    String dropoff,
    String date,
    String time,
  ) async {
    final controller = context.read<BookingController>();
    final booking = await controller.submit(
      pickup: pickup,
      dropoff: dropoff,
      date: date,
      time: time,
    );

    if (!context.mounted) return;

    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la cotización.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Quote Calculated!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.isPendingSync
                    ? 'Cotización guardada localmente. Se sincronizará cuando haya conexión.'
                    : 'Su viaje privado ejecutivo ha sido cotizado:',
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Price:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    Text(
                      '\$${booking.quoteAmount.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                booking.isPendingSync
                    ? 'Estado: ${booking.status}'
                    : 'Your chauffeur will pick you up at the specified time. Thank you for choosing Zenith Private.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BookingController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const CustomTopAppBar(
                title: 'Zenith Transit',
                profileImageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBH2WgqsEpeL1QuSPVvAAYOBZl8NGl3yvx92eoukJglOS0_IaEgRacG0nT40Kz5DfhuXsSMr33a_KwXS1RdeBZXwwSsY3pt2FR0l4LiIdSC6WWZ1v_OjjKiFJVYgQR2sQVOID08sB6nhg7wsC6L6c_19aNZVP7_YriFU2-U_0lVVUkTGJ1s-Va9ojUMduTs1fdHn-Gp1rUxmHecO2sI81yVAs-M1OfVwCRauX8Q9UHhE_wffDlwVIFhN9_eLPxP_TQZWuPMIN0RjW4F',
              ),
              const SizedBox(height: 24),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAGT-KAPm_nGYdELl6TDxaOgXw7B0BF2NKfCnrdU_qQRDQVFj1eBdEHdeHjQDuknL3DVIuevl8DdBEhVQ2pSk9A4qW7kUf6IKjD4WSFimgo-DXLGgM-llV6f0-ptelZUSFH8AmuZEKsnyoUq0a4kmy7Sksp6mw-fHpP0im0vx_yyOQToWs-v11DVgKlHFYbdgBimDvGkwFrsn4gVwqglu-YozKTWTBq5xfuBO_LM-SZEdso00IOWGAOHYxigxkQ1KvQHs3JM1e2r-lw',
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
                    Positioned(
                      top: 16,
                      left: 16,
                      child: CustomBadge(
                        label: 'Premium Service',
                        backgroundColor: Colors.white.withOpacity(0.2),
                        textColor: Colors.white,
                        leading:
                            const Icon(Icons.star, color: Colors.white, size: 14),
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        'Private Executive Travel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildFeatureCard(
                    Icons.airport_shuttle,
                    'Luxury Vans',
                    'Premium fleet for private groups.',
                  ),
                  const SizedBox(width: 8),
                  _buildFeatureCard(
                    Icons.person_pin,
                    'Pro Chauffeurs',
                    'Vetted & professional drivers.',
                  ),
                  const SizedBox(width: 8),
                  _buildFeatureCard(
                    Icons.door_front_door_rounded,
                    'Door-to-door',
                    'Ultimate convenience & comfort.',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BookingForm(
                onSubmit: (pickup, dropoff, date, time) =>
                    _handleSubmit(context, pickup, dropoff, date, time),
                isLoading: controller.isSubmitting,
              ),
              const SizedBox(height: 24),
              CustomCard(
                borderRadius: 16,
                backgroundColor: const Color(0xFF1B1B1B),
                borderColor: Colors.transparent,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why Zenith Private?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWhyRow(
                      'Fixed pricing, no hidden fees or surge charges.',
                    ),
                    const SizedBox(height: 8),
                    _buildWhyRow(
                      'Complimentary wait time of 45 minutes at airports.',
                    ),
                    const SizedBox(height: 8),
                    _buildWhyRow(
                      '24/7 Premium support for any travel changes.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Active Bookings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              if (controller.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (controller.bookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No tienes viajes cotizados aún.',
                      style: TextStyle(color: AppTheme.secondaryColor),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.bookings.length,
                  itemBuilder: (context, index) {
                    final b = controller.bookings[index];
                    return _BookingTile(booking: b);
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String body) {
    return Expanded(
      child: CustomCard(
        borderRadius: 12,
        borderColor: AppTheme.borderVariantColor.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              body,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;

  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 12,
      borderColor: AppTheme.surfaceContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.airport_shuttle,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ID: ${booking.shortId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              CustomBadge(
                label: booking.status,
                isSuccess: booking.status.toLowerCase() == 'confirmed',
                showDot: false,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pick-up: ${booking.pickupLocation}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place, size: 10, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Drop-off: ${booking.dropoffLocation}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fecha: ${booking.departureDate}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryColor,
                ),
              ),
              Text(
                '\$${booking.quoteAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                'Hora: ${booking.pickupTime}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
