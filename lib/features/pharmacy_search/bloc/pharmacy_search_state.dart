part of 'pharmacy_search_bloc.dart';

sealed class PharmacySearchState extends Equatable {
  const PharmacySearchState();

  @override
  List<Object> get props => [];
}

final class PharmacySearchInitial extends PharmacySearchState {
  final List<String> recentSearches;

  const PharmacySearchInitial({this.recentSearches = const []});

  @override
  List<Object> get props => [recentSearches];
}

final class PharmacySearchLoadInProgress extends PharmacySearchState {
  const PharmacySearchLoadInProgress({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

final class PharmacySearchLoadFail extends PharmacySearchState {
  const PharmacySearchLoadFail({this.query = ''});

  final String query;

  @override
  List<Object> get props => [query];
}

final class PharmacySearchLoadSuccess extends PharmacySearchState {
  const PharmacySearchLoadSuccess(this.pharmacies, {this.query = ''});

  final List<Pharmacy> pharmacies;
  final String query;

  @override
  List<Object> get props => [pharmacies, query];
}
