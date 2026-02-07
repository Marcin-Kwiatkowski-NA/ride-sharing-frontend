import 'package:flutter/material.dart';

/// Vertical list of recent searches displayed below the [HeroSearchCard].
///
/// Dark semi-transparent container styled as a "recent history" dropdown.
/// Currently uses mock data — will be wired to [recentSearchesProvider] later.
class RecentSearchesList extends StatelessWidget {
  const RecentSearchesList({super.key});

  static const _mockSearches = [
    'Warsaw → Krakow',
    'Warsaw → Gdansk',
    'Krakow → Wroclaw',
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _mockSearches.length; i++) ...[
            _SearchRow(label: _mockSearches[i]),
            if (i < _mockSearches.length - 1)
              const Divider(
                color: Colors.white12,
                height: 1,
                indent: 48,
              ),
          ],
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final String label;

  const _SearchRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}
