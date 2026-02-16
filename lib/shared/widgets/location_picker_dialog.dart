import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/locations/domain/location.dart';
import '../../core/locations/widgets/location_autocomplete_field.dart';

/// Opens a fullscreen dialog for location search with auto-focused keyboard.
Future<Location?> showLocationPickerDialog(
  BuildContext context, {
  required String title,
}) {
  return showDialog<Location>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog.fullscreen(
      child: _LocationPickerPage(title: title),
    ),
  );
}

class _LocationPickerPage extends StatelessWidget {
  final String title;
  const _LocationPickerPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LocationAutocompleteField(
          controller: ctrl,
          labelText: context.l10n.searchCity,
          prefixIcon: Icons.search,
          onLocationSelected: (location) =>
              Navigator.of(context).pop(location),
        ),
      ),
    );
  }
}
