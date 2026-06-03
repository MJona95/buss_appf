import 'package:flutter/material.dart';
import '../core/api/supabase_client.dart';
import '../core/database/local_database.dart';
import '../core/theme/app_theme.dart';
import '../models/booking_model.dart';
import '../widgets/booking_form.dart';

class PrivateTransportScreen extends StatefulWidget {
  const PrivateTransportScreen({super.key});

  @override
  State<PrivateTransportScreen> createState() => _PrivateTransportScreenState();
}

class _PrivateTransportScreenState extends State<PrivateTransportScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoadingBookings = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final dbData = await LocalDatabase.instance.getBookings();
      setState(() {
        _bookings = dbData.map((map) => BookingModel.fromDbMap(map)).toList();
        _isLoadingBookings = false;
      });
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      setState(() {
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _handleBookingSubmitted(
      String pickup, String dropoff, String date, String time) async {
    setState(() {
      _isSubmitting = true;
    });

    // 1. Simulate network calculation delay
    await Future.delayed(const Duration(seconds: 2));

    final String bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    final newBooking = {
      'id': bookingId,
      'pickup_location': pickup,
      'dropoff_location': dropoff,
      'departure_date': date,
      'pickup_time': time,
      'status': 'Confirmed',
    };

    try {
      // 2. Save locally in SQLite
      await LocalDatabase.instance.insertBooking(newBooking);

      // 3. Try to sync to Supabase (handling online/offline sync fallback gracefully)
      await SupabaseManager.uploadBooking(newBooking);

      // 4. Reload bookings
      await _loadBookings();

      if (mounted) {
        // Show success quote confirmation dialog
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
                  const Text('Su viaje privado ejecutivo ha sido cotizado:'),
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
                        Text(
                          'Estimated Price:',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor),
                        ),
                        Text(
                          '\$120.00 USD',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your chauffeur will pick you up at the specified time. Thank you for choosing Zenith Private.',
                    style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error saving booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la cotización.')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
              Row(
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
                        'Zenith Transit',
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
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBH2WgqsEpeL1QuSPVvAAYOBZl8NGl3yvx92eoukJglOS0_IaEgRacG0nT40Kz5DfhuXsSMr33a_KwXS1RdeBZXwwSsY3pt2FR0l4LiIdSC6WWZ1v_OjjKiFJVYgQR2sQVOID08sB6nhg7wsC6L6c_19aNZVP7_YriFU2-U_0lVVUkTGJ1s-Va9ojUMduTs1fdHn-Gp1rUxmHecO2sI81yVAs-M1OfVwCRauX8Q9UHhE_wffDlwVIFhN9_eLPxP_TQZWuPMIN0RjW4F',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Hero Image card
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Premium Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
              
              // Features Grid Section
              Row(
                children: [
                  _buildFeatureCard(Icons.airport_shuttle, 'Luxury Vans', 'Premium fleet for private groups.'),
                  const SizedBox(width: 8),
                  _buildFeatureCard(Icons.person_pin, 'Pro Chauffeurs', 'Vetted & professional drivers.'),
                  const SizedBox(width: 8),
                  _buildFeatureCard(Icons.door_front_door_rounded, 'Door-to-door', 'Ultimate convenience & comfort.'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Booking Form
              BookingForm(
                onSubmit: _handleBookingSubmitted,
                isLoading: _isSubmitting,
              ),
              const SizedBox(height: 24),
              
              // Why Zenith Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B), // dark background
                  borderRadius: BorderRadius.circular(16),
                ),
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
                    _buildWhyRow('Fixed pricing, no hidden fees or surge charges.'),
                    const SizedBox(height: 8),
                    _buildWhyRow('Complimentary wait time of 45 minutes at airports.'),
                    const SizedBox(height: 8),
                    _buildWhyRow('24/7 Premium support for any travel changes.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Local Bookings List Header
              const Text(
                'Your Active Bookings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Local Bookings List
              if (_isLoadingBookings)
                const Center(child: CircularProgressIndicator())
              else if (_bookings.isEmpty)
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
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final b = _bookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceContainer),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.airport_shuttle, size: 16, color: AppTheme.primaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ID: ${b.id.substring(0, 7)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  b.status,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
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
                                  'Pick-up: ${b.pickupLocation}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                  'Drop-off: ${b.dropoffLocation}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fecha: ${b.departureDate}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
                              ),
                              Text(
                                'Hora: ${b.pickupTime}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 100), // Spacing for floating bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String body) {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderVariantColor.withOpacity(0.15)),
        ),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
