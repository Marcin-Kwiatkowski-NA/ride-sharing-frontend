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
  final Widget Function(BuildContext)? emptyBuilder;
  final Widget? trailingWidget;

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
    this.emptyBuilder,
    this.trailingWidget,
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
      if (emptyBuilder != null) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: emptyBuilder!(context),
        );
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(emptyMessage),
            ],
          ),
        ),
      );
    }

    final showTrailing = !hasMore && trailingWidget != null;
    final int extraCount = hasMore ? 1 : (showTrailing ? 1 : 0);
    final itemCount = items.length + extraCount;

    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          if (hasMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return trailingWidget!;
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
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
