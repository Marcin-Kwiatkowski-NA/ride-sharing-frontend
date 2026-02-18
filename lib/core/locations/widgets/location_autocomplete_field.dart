import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_extension.dart';
import '../domain/location.dart';
import '../providers/location_providers.dart';
import '../repository/location_repository.dart';

/// Inline location search field with results list below.
///
/// Designed for bottom sheets: no overlay, suggestions appear in a ListView
/// that you control (pass your own ScrollController if needed).
class LocationAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final void Function(Location) onLocationSelected;
  final void Function()? onLocationCleared;
  final String? Function(String?)? validator;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.onLocationSelected,
    this.onLocationCleared,
    this.validator,
  });

  @override
  ConsumerState<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState
    extends ConsumerState<LocationAutocompleteField> {
  Timer? _debounce;
  List<Location> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  CancelToken? _cancelToken;
  String? _pendingKey;

  final _focusNode = FocusNode();
  LocationRepository? _repositoryRef;

  static const Duration _debounceDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.controller.text.isEmpty) {
      _fetchSuggestions('', _repositoryRef);
    }
  }

  void _onTextChanged() {
    final query = widget.controller.text;
    final repository = _repositoryRef;

    if (repository == null) return;

    if (query == _pendingKey) return;

    _pendingKey = query;
    _debounce?.cancel();

    if (query.isEmpty) {
      widget.onLocationCleared?.call();
    }

    _debounce = Timer(_debounceDuration, () {
      _fetchSuggestions(query, repository);
    });
  }

  Future<void> _fetchSuggestions(
    String query,
    LocationRepository? repository,
  ) async {
    if (repository == null) return;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    if (query.isEmpty) {
      try {
        final recents = await repository.getRecentLocations();
        if (mounted) {
          setState(() {
            _suggestions = recents;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isLoading = false;
          });
        }
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await repository.searchLocations(
        query: query,
        cancelToken: _cancelToken,
      );

      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout) {
            _errorMessage = 'connectionError';
          } else {
            _errorMessage = 'searchFailed';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'searchFailed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repositoryAsync = ref.watch(locationRepositoryProvider);

    return repositoryAsync.when(
      loading: () => _buildContent(context, theme, null),
      error: (error, stackTrace) => _buildContent(context, theme, null),
      data: (repository) => _buildContent(context, theme, repository),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    LocationRepository? repository,
  ) {
    final previousRef = _repositoryRef;
    _repositoryRef = repository;

    // When repository becomes available and field already has focus,
    // fetch recents immediately (autofocus fires before repo is ready).
    if (previousRef == null &&
        repository != null &&
        _focusNode.hasFocus &&
        widget.controller.text.isEmpty &&
        _suggestions.isEmpty) {
      _fetchSuggestions('', repository);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          autofocus: true,
          onChanged: (_) => _onTextChanged(),
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onLocationCleared?.call();
                    },
                  )
                : null,
          ),
        ),

        const SizedBox(height: 12),

        // Inline results list (scrollable, Material 3 style)
        Expanded(
          child: _buildResultsList(context, theme, repository),
        ),
      ],
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    ThemeData theme,
    LocationRepository? repository,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage == 'connectionError'
                    ? context.l10n.locationConnectionError
                    : context.l10n.locationSearchFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.noLocationsFound,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final location = _suggestions[index];
        return ListTile(
          title: Text(location.name),
          trailing: location.countryCode != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    location.countryCode!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                )
              : null,
          onTap: () {
            repository?.addToRecent(location);
            widget.controller.text = location.name;
            widget.onLocationSelected(location);
            FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }
}
