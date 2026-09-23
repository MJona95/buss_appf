import 'package:flutter/material.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import '../../domain/entities/station.dart';

Future<void> showStationDetailSheet(
  BuildContext context,
  Station station,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _StationDetailSheet(station: station),
  );
}

class _StationDetailSheet extends StatelessWidget {
  final Station station;

  const _StationDetailSheet({required this.station});

  @override
  Widget build(BuildContext context) {
    final rutasDistintas = station.tarifas.map((t) => t.ruta).toSet().length;
    final porRuta = <String, List<TarifaOpcion>>{};
    for (final tarifa in station.tarifas) {
      porRuta.putIfAbsent(tarifa.ruta, () => []).add(tarifa);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderVariantColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: AppTheme.secondaryColor,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Foto',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PobladoChip(poblado: station.poblado),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tarifas vigentes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            if (station.tarifas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin tarifas registradas',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              )
            else
              for (final entry in porRuta.entries) ...[
                if (rutasDistintas > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 6),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                for (final tarifa in entry.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tarifa.tipo,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onBackgroundColor,
                            ),
                          ),
                        ),
                        Text(
                          'C\$${tarifa.monto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

class _PobladoChip extends StatelessWidget {
  final bool poblado;

  const _PobladoChip({required this.poblado});

  @override
  Widget build(BuildContext context) {
    final color = poblado ? Color(0xFF2E7D32) : Color(0xFFB26A00);
    final background = poblado
        ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
        : const Color(0xFFB26A00).withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        poblado ? 'Poblado' : 'No poblado',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}