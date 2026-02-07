import 'package:flutter/material.dart';

import '../../../../core/utils/error_mapper.dart';

/// Generic sliver list for paginated content with loading/error/empty states.
class PaginatedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final Object? error;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyMessage;
  final Widget? loadingWidget;

  const PaginatedSliverList({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.error,
    required this.onRetry,
    required this.itemBuilder,
    this.emptyIcon = Icons.search_off,
    this.emptyMessage = 'No results found.',
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: loadingWidget ?? const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null && items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildErrorWidget(context),
      );
    }

    if (!isLoading && items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(emptyMessage),
            ],
          ),
        ),
      );
    }

    final itemCount = hasMore ? items.length + 1 : items.length;

    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return itemBuilder(context, items[index]);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final failure = ErrorMapper.map(error!);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
