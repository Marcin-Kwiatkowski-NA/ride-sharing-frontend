import 'package:flutter/material.dart';

/// Material 3 SegmentedButton for selecting between exact and approximate time modes.
class TimeModeSelector extends StatelessWidget {
  final bool isApproximate;
  final ValueChanged<bool> onChanged;

  const TimeModeSelector({
    super.key,
    required this.isApproximate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: false,
          label: Text('Exact Time'),
          icon: Icon(Icons.access_time),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text('Approximate'),
          icon: Icon(Icons.schedule),
        ),
      ],
      selected: {isApproximate},
      onSelectionChanged: (Set<bool> selected) {
        onChanged(selected.first);
      },
      showSelectedIcon: false,
    );
  }
}
