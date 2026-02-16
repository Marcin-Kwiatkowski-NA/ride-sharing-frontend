import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Debug-only screen for validating the theme design system.
///
/// Shows all component states in both light and dark mode with a toggle.
/// Navigate to `/dev/gallery` to access.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final brightness =
        _mode == ThemeMode.dark ? Brightness.dark : Brightness.light;

    return Theme(
      data: brightness == Brightness.dark
          ? Theme.of(context)
              .copyWith(colorScheme: Theme.of(context).colorScheme)
          : Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Gallery'),
          actions: [
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {_mode},
              onSelectionChanged: (v) => setState(() => _mode = v.first),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Text Fields'),
            _textFields(context),
            const SizedBox(height: 24),
            _section('Search-like Surface'),
            _searchSurface(context),
            const SizedBox(height: 24),
            _section('Buttons'),
            _buttons(context),
            const SizedBox(height: 24),
            _section('Segmented Button'),
            _segmentedButton(context),
            const SizedBox(height: 24),
            _section('Chips'),
            _chips(context),
            const SizedBox(height: 24),
            _section('Cards'),
            _cards(context),
            const SizedBox(height: 24),
            _section('Overlay Surface'),
            _overlaySurface(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _textFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Empty field',
            hintText: 'Hint text',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: 'Filled value',
          decoration: const InputDecoration(
            labelText: 'Filled field',
            prefixIcon: Icon(Icons.email),
            suffixIcon: Icon(Icons.check),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Error field',
            errorText: 'This field has an error',
            prefixIcon: Icon(Icons.warning),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          enabled: false,
          initialValue: 'Disabled field',
          decoration: const InputDecoration(
            labelText: 'Disabled',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
      ],
    );
  }

  Widget _searchSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: AppTokens.elevationHigh,
      borderRadius: BorderRadius.circular(AppTokens.radiusXL),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.primary, size: 28),
              const SizedBox(width: 16),
              Text(
                'Where to?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(onPressed: () {}, child: const Text('Primary')),
        FilledButton(
          onPressed: () {},
          style: tokens?.brandCtaStyle,
          child: const Text('Brand CTA'),
        ),
        FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
        OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
        TextButton(onPressed: () {}, child: const Text('Text')),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Destructive'),
        ),
        FilledButton(onPressed: null, child: const Text('Disabled')),
      ],
    );
  }

  Widget _segmentedButton(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Option A'), icon: Icon(Icons.star)),
        ButtonSegment(value: 1, label: Text('Option B'), icon: Icon(Icons.bolt)),
      ],
      selected: const {0},
      onSelectionChanged: (_) {},
    );
  }

  Widget _chips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        const Chip(label: Text('Default')),
        Chip(
          label: const Text('With icon'),
          avatar: const Icon(Icons.calendar_today, size: 16),
          onDeleted: () {},
        ),
        const FilterChip(label: Text('Filter'), selected: true, onSelected: null),
        const FilterChip(label: Text('Unselected'), selected: false, onSelected: null),
      ],
    );
  }

  Widget _cards(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card Title'),
            SizedBox(height: 4),
            Text('Card body text showing the default card styling.'),
          ],
        ),
      ),
    );
  }

  Widget _overlaySurface(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        image: const DecorationImage(
          image: AssetImage('assets/road6.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overlay surface',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Rides')),
                ButtonSegment(value: 1, label: Text('Passengers')),
              ],
              selected: const {0},
              onSelectionChanged: (_) {},
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_car, size: 20),
                  label: const Text('My Offers'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  style: tokens?.brandCtaStyle,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Post'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant),
            Text(
              'Secondary text',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            Text(
              'Tertiary text',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
