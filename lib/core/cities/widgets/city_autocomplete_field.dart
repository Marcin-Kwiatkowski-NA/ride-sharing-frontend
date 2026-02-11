import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/city.dart';
import '../providers/city_providers.dart';
import '../repository/city_repository.dart';

/// Inline city search field with results list below.
///
/// Designed for bottom sheets: no overlay, suggestions appear in a ListView
/// that you control (pass your own ScrollController if needed).
class CityAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final void Function(City) onCitySelected;
  final void Function()? onCityCleared;
  final String? Function(String?)? validator;
  final String? langOverride;

  const CityAutocompleteField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.onCitySelected,
    this.onCityCleared,
    this.validator,
    this.langOverride,
  });

  @override
  ConsumerState<CityAutocompleteField> createState() =>
      _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends ConsumerState<CityAutocompleteField> {
  Timer? _debounce;
  List<City> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  CancelToken? _cancelToken;
  String? _pendingKey;

  final _focusNode = FocusNode();
  CityRepository? _repositoryRef;
  String? _langRef;

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
      _fetchSuggestions('', _repositoryRef, _langRef ?? 'en');
    }
  }

  void _onTextChanged() {
    final query = widget.controller.text;
    final repository = _repositoryRef;
    final lang = _langRef ?? 'en';

    if (repository == null) return;

    final key = '$lang|$query';
    if (key == _pendingKey) return;

    _pendingKey = key;
    _debounce?.cancel();

    if (query.isEmpty) {
      widget.onCityCleared?.call();
    }

    _debounce = Timer(_debounceDuration, () {
      _fetchSuggestions(query, repository, lang);
    });
  }

  Future<void> _fetchSuggestions(
      String query,
      CityRepository? repository,
      String lang,
      ) async {
    if (repository == null) return;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    if (query.isEmpty) {
      try {
        final recents = await repository.getRecentCities();
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
      final results = await repository.searchCities(
        query: query,
        lang: lang,
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
            _errorMessage = 'Connection error. Check your network.';
          } else {
            _errorMessage = 'Failed to load cities';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load cities';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repositoryAsync = ref.watch(cityRepositoryProvider);
    final String lang =
        widget.langOverride ?? ref.watch(citySearchLangProvider);

    return repositoryAsync.when(
      loading: () => _buildContent(context, theme, null, lang),
      error: (error, stackTrace) => _buildContent(context, theme, null, lang),
      data: (repository) => _buildContent(context, theme, repository, lang),
    );
  }

  Widget _buildContent(
      BuildContext context,
      ThemeData theme,
      CityRepository? repository,
      String lang,
      ) {
    _repositoryRef = repository;

    // Trigger refetch if lang changed
    if (_langRef != null && _langRef != lang && repository != null) {
      _onTextChanged();
    }
    _langRef = lang;

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
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                widget.controller.clear();
                widget.onCityCleared?.call();
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
      CityRepository? repository,
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
                _errorMessage!,
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
                'No cities found',
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
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final city = _suggestions[index];
        return ListTile(
          title: Text(city.name),
          trailing: city.countryCode != null
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
              city.countryCode!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          )
              : null,
          onTap: () {
            repository?.addToRecent(city);
            widget.controller.text = city.name;
            widget.onCitySelected(city);
            FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }
}
