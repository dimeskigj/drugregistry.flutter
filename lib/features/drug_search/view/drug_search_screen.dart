import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drug_registry/features/drug_details/view/drug_details_screen.dart';
import 'package:flutter_drug_registry/features/drug_search/bloc/drug_search_bloc.dart';
import 'package:flutter_drug_registry/features/drug_search/drug_search.dart';
import 'package:flutter_drug_registry/features/drug_search/view/drug_card.dart';
import 'package:flutter_drug_registry/features/drug_search/view/suggestion_list.dart';
import 'package:flutter_drug_registry/widgets/suggestion_chips.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({Key? key}) : super(key: key);

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final _searchController = SearchController();
  final _focusNode = FocusNode();

  static const pageStorageKey = 'drug_search_screen';
  static const suggestions = [
    "paracetamol",
    "ibuprofen",
    "loratadine",
    "analgin",
    "amoxicillin",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<DrugSearchBloc>().add(DrugSearchInitialized());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final drugSearchBloc = context.read<DrugSearchBloc>();

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
                      drugSearchBloc.add(DrugSearchQueryChanged(query: value)),
              viewOnSubmitted: (value) {
                drugSearchBloc.add(DrugSearchQuerySubmitted(query: value));
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
                      hintText: "Пребарувај лекови",
                      elevation: WidgetStateProperty.all(0),
                      focusNode: _focusNode,
                      controller: _searchController,
                      shape: const WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onTap: () {
                        _searchController.openView();
                      },
                      onChanged: (value) {
                        drugSearchBloc.add(
                          DrugSearchQueryChanged(query: value),
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
                return BlocBuilder<DrugSearchBloc, DrugSearchState>(
                  builder:
                      (context, state) => switch (state) {
                        DrugSearchLoadInProgress() => const Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        DrugSearchLoadSuccess() => DrugSuggestionList(
                          drugs: state.drugs,
                          onTileTap: (d) {
                            drugSearchBloc.add(
                              DrugSearchSuggestionTapped(drugGroup: d),
                            );
                            _searchController.closeView(null);
                            _searchController.text = d.latinName;
                            _focusNode.unfocus();

                            if (d.drugs.length == 1) {
                              Navigator.of(context).push(
                                DrugDetailsScreen.route(drug: d.drugs.first),
                              );
                            }
                          },
                        ),
                        _ => Container(),
                      },
                );
              },
              suggestionsBuilder: (_, __) => [],
            ),
            BlocBuilder<DrugSearchBloc, DrugSearchState>(
              builder: (_, state) {
                return switch (state) {
                  DrugSearchLoadInProgress() => const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  DrugSearchLoadFail() => Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Text('Нешто тргна наопаку, пробај пак...'),
                    ),
                  ),
                  DrugSearchLoadSuccess() =>
                    state.drugs.isEmpty
                        ? Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: const Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                Text('Нема резултат од пребарувањето.'),
                              ],
                            ),
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
                                    ...state.drugs
                                        .map(
                                          (drug) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 14,
                                            ),
                                            child: DrugCard(
                                              onTap:
                                                  () => Navigator.of(
                                                    context,
                                                  ).push(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              DrugDetailsScreen(
                                                                drug: drug,
                                                              ),
                                                    ),
                                                  ),
                                              drug: drug,
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
                                      Theme.of(context).scaffoldBackgroundColor,
                                      Theme.of(context).scaffoldBackgroundColor
                                          .withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  DrugSearchInitial() => Container(
                    margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: SuggestionChips(
                      suggestions: suggestions,
                      recentSearches: state.recentSearches,
                      onSuggestionSelected: (suggestion) {
                        drugSearchBloc.add(
                          DrugSearchQuerySubmitted(query: suggestion),
                        );
                        _searchController.text = suggestion;
                      },
                    ),
                  ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
