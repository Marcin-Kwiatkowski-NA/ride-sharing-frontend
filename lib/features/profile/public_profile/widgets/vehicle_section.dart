import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../rides/data/dto/vehicle_response_dto.dart';

class VehicleSection extends StatelessWidget {
  final List<VehicleResponseDto> vehicles;

  const VehicleSection({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...vehicles.map((v) => _VehicleCard(vehicle: v)),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleResponseDto vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vehicleName = [vehicle.make, vehicle.model]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    final details = <String>[
      if (vehicle.color != null && vehicle.color!.isNotEmpty) vehicle.color!,
      if (vehicle.productionYear != null) vehicle.productionYear.toString(),
      if (vehicle.licensePlate != null && vehicle.licensePlate!.isNotEmpty)
        _maskLicensePlate(vehicle.licensePlate!),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
              ),
              child: Icon(
                Icons.directions_car,
                color: cs.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicleName.isNotEmpty ? vehicleName : 'Vehicle',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      details.join(' \u2022 '),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskLicensePlate(String plate) {
    if (plate.length <= 5) return plate;
    const visibleStart = 3;
    const visibleEnd = 2;
    final masked = plate.length - visibleStart - visibleEnd;
    return '${plate.substring(0, visibleStart)}${'*' * masked}${plate.substring(plate.length - visibleEnd)}';
  }
}
