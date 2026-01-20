import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<PharmacySearchBloc>().add(PharmacySearchInitialized());
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
                pharmacySearchBloc.add(PharmacySearchQuerySubmitted(value));
                _searchController.closeView(null);
                _focusNode.unfocus();
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
                    ),
                  ),
                );
              },
              viewBuilder: (_) {
                return BlocBuilder<PharmacySearchBloc, PharmacySearchState>(
                  builder:
                      (context, state) => switch (state) {
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
                    PharmacySearchLoadFail() => Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text('Нешто тргна наопаку, пробај пак...'),
                      ),
                    ),
                    PharmacySearchLoadInProgress() => const Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    PharmacySearchLoadSuccess() =>
                      state.pharmacies.isEmpty
                          ? Container(
                            margin: const EdgeInsets.only(top: 16),
                            child: const Align(
                              alignment: Alignment.topCenter,
                              child: Text('Нема резултат од пребарувањето.'),
                            ),
                          )
                          : Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ListView(
                                    key: PageStorageKey(
                                      '$pageStorageKey${state.hashCode}',
                                    ),
                                    children: [
                                      const SizedBox(height: 24),
                                      ...state.pharmacies
                                          .map(
                                            (pharmacy) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 14,
                                                  ),
                                              child: PharmacyCard(
                                                onTap:
                                                    () => Navigator.of(
                                                      context,
                                                    ).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) =>
                                                                PharmacyDetailsScreen(
                                                                  pharmacy:
                                                                      pharmacy,
                                                                ),
                                                      ),
                                                    ),
                                                pharmacy: pharmacy,
                                              ),
                                            ),
                                          )
                                          .toList(),
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
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
