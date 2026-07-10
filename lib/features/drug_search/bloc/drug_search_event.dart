part of 'drug_search_bloc.dart';

sealed class DrugSearchEvent extends Equatable {
  const DrugSearchEvent();

  @override
  List<Object> get props => [];
}

class DrugSearchInitialized extends DrugSearchEvent {}

class DrugSearchQueryChanged extends DrugSearchEvent {
  const DrugSearchQueryChanged({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class DrugSearchQuerySubmitted extends DrugSearchEvent {
  const DrugSearchQuerySubmitted({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class DrugSearchSuggestionTapped extends DrugSearchEvent {
  const DrugSearchSuggestionTapped({required this.drugGroup});

  final DrugGroup drugGroup;

  @override
  List<Object> get props => [drugGroup];
}

class DrugSearchGroupBackRequested extends DrugSearchEvent {}

class DrugSearchDrugTapped extends DrugSearchEvent {
  const DrugSearchDrugTapped({required this.drug});

  final Drug drug;

  @override
  List<Object> get props => [drug.id];
}
