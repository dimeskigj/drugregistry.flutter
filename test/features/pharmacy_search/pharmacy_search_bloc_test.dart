import 'package:flutter_drug_registry/core/models/paged_result.dart';
import 'package:flutter_drug_registry/core/models/pharmacy.dart';
import 'package:flutter_drug_registry/core/services/pharmacy_service.dart';
import 'package:flutter_drug_registry/core/services/shared_preferences_service.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/bloc/pharmacy_search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PharmacySearchBloc', () {
    test('returns to initial suggestions when query is cleared', () async {
      final bloc = PharmacySearchBloc(
        _FakePharmacyService(),
        _FakeSharedPreferencesService(recentPharmacySearches: ['Зегин']),
      );

      bloc.add(PharmacySearchInitialized());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PharmacySearchQuerySubmitted(''));
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state,
        isA<PharmacySearchInitial>().having(
          (state) => state.recentSearches,
          'recentSearches',
          ['Зегин'],
        ),
      );

      await bloc.close();
    });

    test('does not load municipality or place filters', () async {
      final service = _FakePharmacyService(
        results: [const Pharmacy('1', name: 'Зегин Центар')],
        municipalities: ['Скопје'],
        placesByMunicipality: {
          'Скопје': ['Центар'],
        },
      );
      final bloc = PharmacySearchBloc(service, _FakeSharedPreferencesService());

      bloc.add(PharmacySearchInitialized());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PharmacySearchQuerySubmitted('Зегин'));
      await Future<void>.delayed(Duration.zero);

      expect(service.municipalityLoadCount, 0);
      expect(service.placeLoadCount, 0);
      expect(service.searches, hasLength(1));
      expect(service.searches.single.query, 'Зегин');
      expect(service.searches.single.municipality, isNull);
      expect(service.searches.single.place, isNull);

      await bloc.close();
    });
  });
}

class _FakePharmacyService extends PharmacyService {
  _FakePharmacyService({
    this.results = const [],
    this.municipalities = const [],
    this.placesByMunicipality = const {},
  });

  final List<Pharmacy> results;
  final List<String> municipalities;
  final Map<String, List<String>> placesByMunicipality;
  final List<_PharmacySearchCall> searches = [];
  int municipalityLoadCount = 0;
  int placeLoadCount = 0;

  @override
  Future<PagedResult<Pharmacy>> searchPharmacies(
    String query, {
    int page = 0,
    int size = 10,
    String? municipality,
    String? place,
  }) async {
    searches.add(
      _PharmacySearchCall(
        query: query,
        municipality: municipality,
        place: place,
      ),
    );
    return PagedResult(results, results.length, page, size);
  }

  @override
  Future<Iterable<String>> getMunicipalitiesByFrequency() async {
    municipalityLoadCount++;
    return municipalities;
  }

  @override
  Future<Iterable<String>> getPlacesByFrequency(String municipality) async {
    placeLoadCount++;
    return placesByMunicipality[municipality] ?? [];
  }
}

class _PharmacySearchCall {
  const _PharmacySearchCall({
    required this.query,
    this.municipality,
    this.place,
  });

  final String query;
  final String? municipality;
  final String? place;
}

class _FakeSharedPreferencesService extends SharedPreferencesService {
  _FakeSharedPreferencesService({List<String>? recentPharmacySearches})
    : _recentPharmacySearches = recentPharmacySearches ?? [];

  List<String> _recentPharmacySearches;

  @override
  List<String>? getRecentPharmacySearches() => _recentPharmacySearches;

  @override
  Future<bool> setRecentPharmacySearches(List<String> value) async {
    _recentPharmacySearches = value;
    return true;
  }
}
