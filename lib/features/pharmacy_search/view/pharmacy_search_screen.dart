import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drug_registry/core/models/pharmacy.dart';
import 'package:flutter_drug_registry/features/pharmacy_details/pharmacy_deatils.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/bloc/pharmacy_search_bloc.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/pharmacy_search.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/view/pharmacy_card.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/view/pharmacy_suggestion_list.dart';
import 'package:flutter_drug_registry/widgets/suggestion_chips.dart';

class PharmacySearchScreen extends StatefulWidget {
  const PharmacySearchScreen({super.key});

  @override
  State<PharmacySearchScreen> createState() => _PharmacySearchScreenState();
}

class _PharmacySearchScreenState extends State<PharmacySearchScreen> {
  final _searchController = SearchController();
  final _focusNode = FocusNode();

  static const pageStorageKey = 'pharmacy_search_screen';
  static const suggestions = ['Зегин', 'Еурофарм', 'Виола'];

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    context.read<PharmacySearchBloc>().add(PharmacySearchInitialized());
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  void _submitSearch(PharmacySearchBloc bloc, String query) {
    bloc.add(PharmacySearchQuerySubmitted(query));
    _searchController.closeView(null);
    _focusNode.unfocus();
  }

  void _clearSearch(PharmacySearchBloc bloc) {
    _searchController.clear();
    bloc.add(const PharmacySearchQueryChanged(''));
    _searchController.openView();
  }

  Widget _buildErrorState(PharmacySearchBloc bloc, String query) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Нешто тргна наопаку',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Провери ја интернет врската и пробај повторно.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => bloc.add(PharmacySearchQuerySubmitted(query)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Пробај пак'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                query.isEmpty
                    ? 'Нема резултат од пребарувањето.'
                    : 'Нема резултати за "$query"',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Пробај со друго име или различен правопис.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyResultList({
    required List<Pharmacy> pharmacies,
    required String title,
    String? subtitle,
  }) {
    return Expanded(
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              key: PageStorageKey(
                '$pageStorageKey$title${pharmacies.hashCode}',
              ),
              children: [
                const SizedBox(height: 18),
                _ResultHeader(title: title, subtitle: subtitle),
                const SizedBox(height: 8),
                ...pharmacies.map(_buildPharmacyCardTile),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 1],
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCardTile(Pharmacy pharmacy) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: PharmacyCard(
        onTap:
            () => Navigator.of(
              context,
            ).push(PharmacyDetailsScreen.route(pharmacy: pharmacy)),
        pharmacy: pharmacy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacySearchBloc = context.read<PharmacySearchBloc>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SearchAnchor(
              searchController: _searchController,
              viewOnChanged:
                  (value) =>
                      pharmacySearchBloc.add(PharmacySearchQueryChanged(value)),
              viewOnSubmitted: (value) {
                _submitSearch(pharmacySearchBloc, value);
              },
              viewLeading: IconButton(
                onPressed: () {
                  _searchController.closeView(null);
                  _focusNode.unfocus();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              dividerColor: Colors.transparent,
              builder: (_, __) {
                return Container(
                  margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SearchBar(
                      hintText: "Пребарувај аптеки",
                      elevation: WidgetStateProperty.all(0),
                      focusNode: _focusNode,
                      controller: _searchController,
                      shape: const WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onTap: () {
                        _searchController.openView();
                      },
                      onChanged: (query) {
                        pharmacySearchBloc.add(
                          PharmacySearchQueryChanged(query),
                        );
                        _searchController.openView();
                      },
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Исчисти пребарување',
                            onPressed: () => _clearSearch(pharmacySearchBloc),
                            icon: const Icon(Icons.close_rounded),
                          ),
                      ],
                    ),
                  ),
                );
              },
              viewBuilder: (_) {
                return BlocBuilder<PharmacySearchBloc, PharmacySearchState>(
                  builder:
                      (context, state) => switch (state) {
                        PharmacySearchInitial() => Padding(
                          padding: const EdgeInsets.all(16),
                          child: SuggestionChips(
                            suggestions: suggestions,
                            recentSearches: state.recentSearches,
                            onSuggestionSelected: (suggestion) {
                              _searchController.text = suggestion;
                              _submitSearch(pharmacySearchBloc, suggestion);
                            },
                          ),
                        ),
                        PharmacySearchLoadInProgress() => const Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        PharmacySearchLoadSuccess() => PharmacySuggestionList(
                          pharmacies: state.pharmacies,
                          onTileTap: (pharmacy) {
                            pharmacySearchBloc.add(
                              PharmacySearchSuggestionTapped(pharmacy),
                            );
                            _searchController.closeView(null);
                            _searchController.text = pharmacy.name ?? '';
                            _focusNode.unfocus();

                            Navigator.of(context).push(
                              PharmacyDetailsScreen.route(pharmacy: pharmacy),
                            );
                          },
                        ),
                        _ => Container(),
                      },
                );
              },
              suggestionsBuilder: (_, __) => [],
            ),
            BlocBuilder<PharmacySearchBloc, PharmacySearchState>(
              builder:
                  (_, state) => switch (state) {
                    PharmacySearchLoadFail() => _buildErrorState(
                      pharmacySearchBloc,
                      state.query,
                    ),
                    PharmacySearchLoadInProgress() => const Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    PharmacySearchLoadSuccess() =>
                      state.pharmacies.isEmpty
                          ? _buildEmptyState(state.query)
                          : _buildPharmacyResultList(
                            pharmacies: state.pharmacies,
                            title: '${state.pharmacies.length} резултати',
                            subtitle:
                                state.query.isEmpty
                                    ? null
                                    : 'Пребарување за "${state.query}"',
                          ),
                    PharmacySearchInitial() => Container(
                      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: SuggestionChips(
                        suggestions: suggestions,
                        recentSearches: state.recentSearches,
                        onSuggestionSelected: (suggestion) {
                          pharmacySearchBloc.add(
                            PharmacySearchQuerySubmitted(suggestion),
                          );
                          _searchController.text = suggestion;
                        },
                      ),
                    ),
                  },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
