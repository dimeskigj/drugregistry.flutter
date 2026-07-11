import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_drug_registry/core/models/drug.dart';
import 'package:flutter_drug_registry/core/models/drug_group.dart';
import 'package:flutter_drug_registry/core/services/drug_service.dart';
import 'package:flutter_drug_registry/core/services/shared_preferences_service.dart';
import 'package:flutter_drug_registry/core/utils/bloc_utils.dart';

part 'drug_search_event.dart';
part 'drug_search_state.dart';

class DrugSearchBloc extends Bloc<DrugSearchEvent, DrugSearchState> {
  late final DrugService _drugService;
  late final SharedPreferencesService _sharedPreferencesService;
  String _lastQuery = '';
  List<String> _recentSearches = [];

  DrugSearchBloc(
    DrugService? drugService,
    SharedPreferencesService? sharedPreferencesService,
  ) : super(const DrugSearchInitial()) {
    _drugService = drugService ?? DrugService();
    _sharedPreferencesService =
        sharedPreferencesService ?? SharedPreferencesService();

    on<DrugSearchInitialized>(_onDrugSearchScreenInitialized);
    on<DrugSearchQuerySubmitted>(_onDrugSearchQuerySubmitted);
    on<DrugSearchQueryChanged>(
      _onDrugSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<DrugSearchSuggestionTapped>(_onDrugSearchSuggestionTapped);
    on<DrugSearchGroupBackRequested>(_onDrugSearchGroupBackRequested);
  }

  Future<void> _onDrugSearchScreenInitialized(
    DrugSearchInitialized event,
    Emitter<DrugSearchState> emit,
  ) async {
    var sharedPreferencesRecentSearches =
        _sharedPreferencesService.getRecentDrugSearches() ?? [];

    if (sharedPreferencesRecentSearches.equals(_recentSearches)) return;

    _recentSearches = sharedPreferencesRecentSearches;
    emit(DrugSearchInitial(recentSearches: _recentSearches));
  }

  Future<void> _onDrugSearchQueryChanged(
    DrugSearchQueryChanged event,
    Emitter<DrugSearchState> emit,
  ) async {
    await _queryDrugs(event.query, emit);
  }

  Future<void> _onDrugSearchQuerySubmitted(
    DrugSearchQuerySubmitted event,
    Emitter<DrugSearchState> emit,
  ) async {
    await _queryDrugs(event.query, emit, shouldReQuery: true);
  }

  Future<void> _queryDrugs(
    String query,
    Emitter<DrugSearchState> emit, {
    bool shouldReQuery = false,
  }) async {
    try {
      if (_lastQuery == query && !shouldReQuery) return;
      _lastQuery = query;

      if (query == '') {
        emit(DrugSearchInitial(recentSearches: _recentSearches));
        return;
      }

      emit(DrugSearchLoadInProgress(query: query));
      var results = await _drugService.searchDrugs(query, size: 50);
      emit(DrugSearchLoadSuccess(drugs: results.data.toList(), query: query));

      if (shouldReQuery && results.data.isNotEmpty) {
        await updateRecentSearches(query: query);
      }
    } catch (_) {
      emit(DrugSearchLoadFail(query: query));
    }
  }

  Future<void> _onDrugSearchSuggestionTapped(
    DrugSearchSuggestionTapped event,
    Emitter<DrugSearchState> emit,
  ) async {
    if (event.drugGroup.drugs.length > 1) {
      final previousState = state;
      emit(
        DrugSearchGroupSelected(
          drugGroup: event.drugGroup,
          previousDrugs:
              previousState is DrugSearchLoadSuccess
                  ? previousState.drugs
                  : const [],
          previousQuery:
              previousState is DrugSearchLoadSuccess ? previousState.query : '',
        ),
      );
    }

    await updateRecentSearches(query: event.drugGroup.latinName.toLowerCase());
  }

  void _onDrugSearchGroupBackRequested(
    DrugSearchGroupBackRequested event,
    Emitter<DrugSearchState> emit,
  ) {
    final currentState = state;
    if (currentState is! DrugSearchGroupSelected ||
        !currentState.canReturnToResults) {
      return;
    }

    emit(
      DrugSearchLoadSuccess(
        drugs: currentState.previousDrugs,
        query: currentState.previousQuery,
      ),
    );
  }

  Future<void> updateRecentSearches({String query = ''}) async {
    if (query.isEmpty) return;

    _recentSearches.remove(query);
    _recentSearches.insert(0, query);

    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.take(5).toList();
    }

    await _sharedPreferencesService.setRecentDrugSearches(_recentSearches);
  }
}
