import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drug_registry/features/drug_details/view/drug_details_screen.dart';
import 'package:flutter_drug_registry/features/drug_search/bloc/drug_search_bloc.dart';
import 'package:flutter_drug_registry/features/drug_search/drug_search.dart';
import 'package:flutter_drug_registry/features/drug_search/view/barcode_scanner_screen.dart';
import 'package:flutter_drug_registry/features/drug_search/view/drug_card.dart';
import 'package:flutter_drug_registry/features/drug_search/view/suggestion_list.dart';
import 'package:flutter_drug_registry/features/review_prompt/cubit/review_prompt_cubit.dart';
import 'package:flutter_drug_registry/core/models/drug.dart';
import 'package:flutter_drug_registry/core/models/drug_group.dart';
import 'package:flutter_drug_registry/core/utils/drug_grouping.dart';
import 'package:flutter_drug_registry/features/review_prompt/view/review_prompt_panel.dart';
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
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    context.read<DrugSearchBloc>().add(DrugSearchInitialized());
    context.read<ReviewPromptCubit>().refresh();
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  void _submitSearch(DrugSearchBloc bloc, String query) {
    bloc.add(DrugSearchQuerySubmitted(query: query));
    _searchController.closeView(null);
    _focusNode.unfocus();
  }

  void _clearSearch(DrugSearchBloc bloc) {
    _searchController.clear();
    bloc.add(const DrugSearchQueryChanged(query: ''));
    _searchController.openView();
  }

  void _openDrugDetails(Drug drug) {
    Navigator.of(context).push(DrugDetailsScreen.route(drug: drug));
  }

  void _openScanner() {
    Navigator.of(context).push(BarcodeScannerScreen.route());
  }

  Widget _buildErrorState(DrugSearchBloc bloc, String query) {
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
                onPressed:
                    () => bloc.add(DrugSearchQuerySubmitted(query: query)),
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
                'Пробај со генеричко име, заштитено име, производител или различен правопис.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugResultList({
    required List<Drug> drugs,
    required String title,
    String? subtitle,
    bool groupResults = true,
    Widget? headerAction,
  }) {
    final groups = groupResults ? groupDrugsByType(drugs) : <DrugGroup>[];
    final children = <Widget>[
      const SizedBox(height: 18),
      _ResultHeader(title: title, subtitle: subtitle, action: headerAction),
      const SizedBox(height: 8),
      if (groupResults)
        ...groups.map(_buildDrugGroupTile)
      else
        ...drugs.map(_buildDrugCardTile),
      const SizedBox(height: 100),
    ];

    return Expanded(
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              key: PageStorageKey('$pageStorageKey$title${drugs.hashCode}'),
              children: children,
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

  Widget _buildDrugGroupTile(DrugGroup group) {
    if (group.drugs.length == 1) return _buildDrugCardTile(group.drugs.first);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: _DrugGroupCard(
        drugGroup: group,
        onTap: () {
          context.read<DrugSearchBloc>().add(
            DrugSearchSuggestionTapped(drugGroup: group),
          );
          _searchController.text = group.latinName;
        },
      ),
    );
  }

  Widget _buildDrugCardTile(Drug drug) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: DrugCard(onTap: () => _openDrugDetails(drug), drug: drug),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drugSearchBloc = context.read<DrugSearchBloc>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanner,
        child: const Icon(Icons.qr_code_scanner),
      ),
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
                _submitSearch(drugSearchBloc, value);
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
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Исчисти пребарување',
                            onPressed: () => _clearSearch(drugSearchBloc),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        IconButton(
                          tooltip: 'Скенирај баркод',
                          onPressed: _openScanner,
                          icon: const Icon(Icons.qr_code_scanner),
                        ),
                      ],
                    ),
                  ),
                );
              },
              viewBuilder: (_) {
                return BlocBuilder<DrugSearchBloc, DrugSearchState>(
                  builder:
                      (context, state) => switch (state) {
                        DrugSearchInitial() => Padding(
                          padding: const EdgeInsets.all(16),
                          child: SuggestionChips(
                            suggestions: suggestions,
                            recentSearches: state.recentSearches,
                            onSuggestionSelected: (suggestion) {
                              _searchController.text = suggestion;
                              _submitSearch(drugSearchBloc, suggestion);
                            },
                          ),
                        ),
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
                              _openDrugDetails(d.drugs.first);
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
                  DrugSearchLoadFail() => _buildErrorState(
                    drugSearchBloc,
                    state.query,
                  ),
                  DrugSearchLoadSuccess() =>
                    state.drugs.isEmpty
                        ? _buildEmptyState(state.query)
                        : _buildDrugResultList(
                          drugs: state.drugs,
                          title: '${state.drugs.length} резултати',
                          subtitle:
                              state.query.isEmpty
                                  ? null
                                  : 'Пребарување за "${state.query}"',
                        ),
                  DrugSearchGroupSelected() => _buildDrugResultList(
                    drugs: state.drugGroup.drugs,
                    title: 'Варијанти за ${state.drugGroup.latinName}',
                    subtitle:
                        '${state.drugGroup.drugs.length} регистрирани варијанти',
                    groupResults: false,
                    headerAction:
                        state.canReturnToResults
                            ? TextButton.icon(
                              onPressed:
                                  () => drugSearchBloc.add(
                                    DrugSearchGroupBackRequested(),
                                  ),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Назад'),
                            )
                            : null,
                  ),
                  DrugSearchInitial() => Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final minHeight =
                            constraints.maxHeight > 36
                                ? constraints.maxHeight - 36
                                : 0.0;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: minHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SuggestionChips(
                                    suggestions: suggestions,
                                    recentSearches: state.recentSearches,
                                    onSuggestionSelected: (suggestion) {
                                      drugSearchBloc.add(
                                        DrugSearchQuerySubmitted(
                                          query: suggestion,
                                        ),
                                      );
                                      _searchController.text = suggestion;
                                    },
                                  ),
                                  const Spacer(),
                                  BlocBuilder<
                                    ReviewPromptCubit,
                                    ReviewPromptState
                                  >(
                                    builder: (context, state) {
                                      if (!state.shouldShow) {
                                        return const SizedBox.shrink();
                                      }

                                      final reviewPromptCubit =
                                          context.read<ReviewPromptCubit>();

                                      return ReviewPromptPanel(
                                        onReview: reviewPromptCubit.openReview,
                                        onFeedback:
                                            reviewPromptCubit.sendFeedback,
                                        onDismiss: reviewPromptCubit.dismiss,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
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

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
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
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}

class _DrugGroupCard extends StatelessWidget {
  const _DrugGroupCard({required this.drugGroup, required this.onTap});

  final DrugGroup drugGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: .1),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Row(
            children: [
              Icon(Icons.medication_rounded, color: theme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drugGroup.latinName,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (drugGroup.genericName.isNotEmpty)
                      Text(
                        drugGroup.genericName,
                        style: theme.textTheme.titleSmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text('${drugGroup.drugs.length} варијанти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
