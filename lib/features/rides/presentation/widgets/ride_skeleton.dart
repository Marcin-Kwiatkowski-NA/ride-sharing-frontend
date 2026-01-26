import 'package:flutter/material.dart';

/// Skeleton loading placeholder for ride cards.
class RideSkeleton extends StatelessWidget {
  const RideSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerLine(width: 100, height: 20),
            const SizedBox(height: 12),
            _buildShimmerLine(width: 180, height: 18),
            const SizedBox(height: 8),
            _buildShimmerLine(width: 160, height: 18),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerLine(width: 80, height: 16),
                _buildShimmerLine(width: 60, height: 16),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerLine(width: 70, height: 16),
                _buildShimmerLine(width: 80, height: 20),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerLine(width: double.infinity, height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// List of skeleton cards for loading state.
class RideSkeletonList extends StatelessWidget {
  final int count;

  const RideSkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) => const RideSkeleton(),
    );
  }
}
