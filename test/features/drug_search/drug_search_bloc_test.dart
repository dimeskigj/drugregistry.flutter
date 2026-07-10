import 'package:flutter_drug_registry/core/models/drug.dart';
import 'package:flutter_drug_registry/core/models/drug_group.dart';
import 'package:flutter_drug_registry/core/models/paged_result.dart';
import 'package:flutter_drug_registry/core/services/drug_service.dart';
import 'package:flutter_drug_registry/core/services/shared_preferences_service.dart';
import 'package:flutter_drug_registry/core/utils/drug_grouping.dart';
import 'package:flutter_drug_registry/features/drug_search/bloc/drug_search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groupDrugsByType', () {
    test(
      'groups drugs with the same latin and generic names in result order',
      () {
        const firstVariant = Drug(
          '1',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
          packaging: '10 tablets',
        );
        const secondDrug = Drug(
          '2',
          latinName: 'Ibuprofen',
          genericName: 'Ibuprofenum',
        );
        const secondVariant = Drug(
          '3',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
          packaging: '20 tablets',
        );

        final groups = groupDrugsByType([
          firstVariant,
          secondDrug,
          secondVariant,
        ]);

        expect(groups, hasLength(2));
        expect(groups.first.latinName, 'Paracetamol');
        expect(groups.first.genericName, 'Paracetamolum');
        expect(groups.first.drugs, [firstVariant, secondVariant]);
        expect(groups.last.drugs, [secondDrug]);
      },
    );
  });

  group('DrugSearchBloc', () {
    test('returns to initial suggestions when query is cleared', () async {
      final bloc = DrugSearchBloc(
        _FakeDrugService([]),
        _FakeSharedPreferencesService(recentDrugSearches: ['analgin']),
      );

      bloc.add(DrugSearchInitialized());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const DrugSearchQuerySubmitted(query: ''));
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state,
        isA<DrugSearchInitial>().having(
          (state) => state.recentSearches,
          'recentSearches',
          ['analgin'],
        ),
      );

      await bloc.close();
    });

    test(
      'keeps full results behind a single-drug suggestion navigation',
      () async {
        const firstDrug = Drug(
          '1',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
        );
        const secondDrug = Drug(
          '2',
          latinName: 'Ibuprofen',
          genericName: 'Ibuprofenum',
        );
        final bloc = DrugSearchBloc(
          _FakeDrugService([firstDrug, secondDrug]),
          _FakeSharedPreferencesService(),
        );

        bloc.add(const DrugSearchQuerySubmitted(query: 'para'));
        await Future<void>.delayed(Duration.zero);

        bloc.add(
          const DrugSearchSuggestionTapped(
            drugGroup: DrugGroup(
              latinName: 'Paracetamol',
              genericName: 'Paracetamolum',
              drugs: [firstDrug],
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state,
          isA<DrugSearchLoadSuccess>().having((state) => state.drugs, 'drugs', [
            firstDrug,
            secondDrug,
          ]),
        );

        await bloc.close();
      },
    );

    test(
      'selects a grouped variants state for multi-drug suggestions',
      () async {
        const firstVariant = Drug(
          '1',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
        );
        const secondVariant = Drug(
          '2',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
        );
        final bloc = DrugSearchBloc(
          _FakeDrugService([firstVariant, secondVariant]),
          _FakeSharedPreferencesService(),
        );
        const group = DrugGroup(
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
          drugs: [firstVariant, secondVariant],
        );

        bloc.add(const DrugSearchSuggestionTapped(drugGroup: group));
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state,
          isA<DrugSearchGroupSelected>().having(
            (state) => state.drugGroup,
            'drugGroup',
            group,
          ),
        );

        await bloc.close();
      },
    );

    test(
      'returns from grouped variants to the previous search results',
      () async {
        const firstVariant = Drug(
          '1',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
        );
        const secondVariant = Drug(
          '2',
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
        );
        const otherDrug = Drug(
          '3',
          latinName: 'Ibuprofen',
          genericName: 'Ibuprofenum',
        );
        final previousResults = [firstVariant, secondVariant, otherDrug];
        final bloc = DrugSearchBloc(
          _FakeDrugService(previousResults),
          _FakeSharedPreferencesService(),
        );
        const group = DrugGroup(
          latinName: 'Paracetamol',
          genericName: 'Paracetamolum',
          drugs: [firstVariant, secondVariant],
        );

        bloc.add(const DrugSearchQuerySubmitted(query: 'para'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DrugSearchSuggestionTapped(drugGroup: group));
        await Future<void>.delayed(Duration.zero);
        bloc.add(DrugSearchGroupBackRequested());
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state,
          isA<DrugSearchLoadSuccess>()
              .having((state) => state.drugs, 'drugs', previousResults)
              .having((state) => state.query, 'query', 'para'),
        );

        await bloc.close();
      },
    );
  });
}

class _FakeDrugService extends DrugService {
  _FakeDrugService(this.results);

  final List<Drug> results;

  @override
  Future<PagedResult<Drug>> searchDrugs(
    String query, {
    int page = 0,
    int size = 10,
  }) async {
    return PagedResult(results, results.length, page, size);
  }
}

class _FakeSharedPreferencesService extends SharedPreferencesService {
  _FakeSharedPreferencesService({List<String>? recentDrugSearches})
    : _recentDrugSearches = recentDrugSearches ?? [];

  List<String> _recentDrugSearches;

  @override
  List<String>? getRecentDrugSearches() => _recentDrugSearches;

  @override
  Future<bool> setRecentDrugSearches(List<String> value) async {
    _recentDrugSearches = value;
    return true;
  }
}
