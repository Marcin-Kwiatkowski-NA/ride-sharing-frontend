import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/city.dart';
import '../providers/city_providers.dart';
import '../repository/city_repository.dart';

/// Autocomplete text field for city selection
///
/// Uses [CityRepository] for combined API search and recent cities.
/// Features:
/// - Debounced API calls (350ms)
/// - Request cancellation to prevent race conditions
/// - Loading, error, and empty states
/// - Country code display in suggestions
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
  String? _pendingKey; // '$lang|$query' - prevents duplicate fetches

  // References for focus handling
  FocusNode? _focusNode;
  TextEditingController? _fieldControllerRef;
  CityRepository? _repositoryRef;
  String? _langRef;

  static const Duration _debounceDuration = Duration(milliseconds: 350);

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _removeFocusListener();
    super.dispose();
  }

  void _removeFocusListener() {
    _focusNode?.removeListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode?.hasFocus == true &&
        (_fieldControllerRef?.text.isEmpty ?? true)) {
      // Focus gained with empty text - fetch recents immediately
      _fetchSuggestions('', _repositoryRef, _langRef ?? 'en');
    }
  }

  void _onTextChanged(String query, CityRepository? repository, String lang) {
    if (repository == null) return;

    final key = '$lang|$query';
    if (key == _pendingKey) return; // Prevent duplicate fetches

    _pendingKey = key;
    _debounce?.cancel();
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

    // Cancel any pending request
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    if (query.isEmpty) {
      // Fetch recent cities without loading indicator
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
      loading: () => _buildField(context, theme, null, lang),
      error: (error, stackTrace) => _buildField(context, theme, null, lang),
      data: (repository) => _buildField(context, theme, repository, lang),
    );
  }

  Widget _buildField(
    BuildContext context,
    ThemeData theme,
    CityRepository? repository,
    String lang,
  ) {
    // Store refs for focus handling and lang-change detection
    _repositoryRef = repository;

    // Trigger refetch if lang changed
    if (_langRef != null && _langRef != lang && repository != null) {
      final currentQuery = _fieldControllerRef?.text ?? '';
      _onTextChanged(currentQuery, repository, lang);
    }
    _langRef = lang;

    return RawAutocomplete<City>(
      textEditingController: widget.controller,
      focusNode: _focusNode ??= FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text;

        if (query.isEmpty) return _suggestions;

        final lowerQuery = query.toLowerCase();
        return _suggestions
            .where((c) => c.name.toLowerCase().contains(lowerQuery))
            .toList();
      },
      displayStringForOption: (City option) => option.name,
      onSelected: (City selection) {
        repository?.addToRecent(selection);
        widget.onCitySelected(selection);

        // Ensure field displays chosen city
        widget.controller.text = selection.name;

        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        // Keep your focus listener behavior
        if (_focusNode != focusNode) {
          _removeFocusListener();
          _focusNode = focusNode;
          focusNode.addListener(_onFocusChange);
        }

        return TextFormField(
          controller: textController, // this is widget.controller now
          focusNode: focusNode,
          validator: widget.validator,
          onChanged: (text) {
            if (text.isEmpty) {
              widget.onCityCleared?.call();
            }
            _onTextChanged(text, repository, lang);
          },
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.85),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        Widget content;

        if (_isLoading) {
          content = const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (_errorMessage != null) {
          content = Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        } else if (options.isEmpty) {
          content = const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No cities found'),
          );
        } else {
          content = ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return ListTile(
                title: Text(option.name),
                trailing: option.countryCode != null
                    ? Text(
                  option.countryCode!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
                    : null,
                onTap: () => onSelected(option),
              );
            },
          );
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: content,
            ),
          ),
        );
      },
    );
  }
}
