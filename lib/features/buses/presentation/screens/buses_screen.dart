import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buss_app/core/services/whatsapp_service.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/widgets/custom_text_field.dart';
import 'package:buss_app/core/widgets/custom_top_app_bar.dart';
import 'package:buss_app/core/widgets/pressable_scale.dart';
import '../../domain/entities/bus.dart';
import '../controllers/buses_controller.dart';
import '../widgets/bus_unit_card.dart';

class BusesScreen extends StatelessWidget {
  const BusesScreen({super.key});

  Future<void> _contactBus(BuildContext context, Bus bus) async {
    try {
      await context.read<WhatsAppService>().contactUnit(
            phoneNumber: bus.phoneNumber,
            unitNumber: bus.number,
          );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BusesController>();

    return Scaffold(
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: 8,
                    ),
                    child: CustomTopAppBar(
                      title: 'Unidades Disponibles',
                      profileImageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBYWVZyhzmuT3XnSb3UR4urlHPLCPr18MIYPkGz9bwUFVPbCENoY31O5ZbhbeuT5iLLw1ZuPiGthmTU4K_2CS2WPzWjHssoyd2bJlZa0Ub96OjVJnL2MfXL6L4UBYUtF_JmS6UNtfVZUmxYW6UWP8Oq_VmwwNCuyDw5dQNFd28BVrRDgPCRiNykgB_iZQDTLe05yigOovx7CxKCc13P6MMVxaqZBB7adOJsPAiARcYKUeAHao8Yn1DxSGCC1L56pgcJJHDt4WCqJ7Ar',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        SearchTextField(
                          placeholder: 'Buscar unidad por número...',
                          onChanged: controller.search,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _FilterTab(
                                label: 'Todas las Unidades',
                                isActive: controller.selectedFilter ==
                                    'Todas las Unidades',
                                onTap: () => controller
                                    .selectFilter('Todas las Unidades'),
                              ),
                              const SizedBox(width: 8),
                              _FilterTab(
                                label: 'Disponibles',
                                isActive:
                                    controller.selectedFilter == 'Disponibles',
                                onTap: () =>
                                    controller.selectFilter('Disponibles'),
                              ),
                              const SizedBox(width: 8),
                              _FilterTab(
                                label: 'En Mantenimiento',
                                isActive: controller.selectedFilter ==
                                    'En Mantenimiento',
                                onTap: () => controller
                                    .selectFilter('En Mantenimiento'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: controller.filteredBuses.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron unidades',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              top: 8,
                              bottom: 100,
                            ),
                            itemCount: controller.filteredBuses.length,
                            itemBuilder: (context, index) {
                              final bus = controller.filteredBuses[index];
                              return BusUnitCard(
                                bus: bus,
                                onContact: () => _contactBus(context, bus),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.94,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.borderVariantColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
