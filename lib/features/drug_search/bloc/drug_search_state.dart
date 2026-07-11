part of 'drug_search_bloc.dart';

sealed class DrugSearchState extends Equatable {
  const DrugSearchState();

  @override
  List<Object> get props => [];
}

final class DrugSearchInitial extends DrugSearchState {
  final List<String> recentSearches;

  const DrugSearchInitial({this.recentSearches = const []});

  @override
  List<Object> get props => [recentSearches];
}

final class DrugSearchLoadInProgress extends DrugSearchState {
  final String query;

  const DrugSearchLoadInProgress({required this.query});

  @override
  List<Object> get props => [query];
}

final class DrugSearchLoadSuccess extends DrugSearchState {
  final List<Drug> drugs;
  final String query;

  const DrugSearchLoadSuccess({required this.drugs, this.query = ''});

  @override
  List<Object> get props => [drugs, query];
}

final class DrugSearchGroupSelected extends DrugSearchState {
  final DrugGroup drugGroup;
  final List<Drug> previousDrugs;
  final String previousQuery;

  const DrugSearchGroupSelected({
    required this.drugGroup,
    this.previousDrugs = const [],
    this.previousQuery = '',
  });

  bool get canReturnToResults => previousDrugs.isNotEmpty;

  @override
  List<Object> get props => [drugGroup, previousDrugs, previousQuery];
}

final class DrugSearchLoadFail extends DrugSearchState {
  final String? message;
  final String query;

  const DrugSearchLoadFail({this.message, this.query = ''});

  @override
  List<Object> get props => [message ?? '', query];
}
