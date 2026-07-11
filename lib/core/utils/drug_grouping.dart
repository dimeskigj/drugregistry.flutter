import 'package:collection/collection.dart';
import 'package:flutter_drug_registry/core/models/drug.dart';
import 'package:flutter_drug_registry/core/models/drug_group.dart';

List<DrugGroup> groupDrugsByType(List<Drug> drugs) {
  final orderedDrugs = Iterable.generate(
    drugs.length,
  ).map((index) => (index, drugs[index]));

  final groupedDrugs = groupBy(
    orderedDrugs,
    (drug) => (drug.$2.genericName, drug.$2.latinName),
  );

  return groupedDrugs.keys
      .sorted(
        (key1, key2) => (groupedDrugs[key1]?.first.$1 as int).compareTo(
          groupedDrugs[key2]?.first.$1 as int,
        ),
      )
      .map((key) => groupedDrugs[key]!.map((tuple) => tuple.$2))
      .where((drugs) => drugs.isNotEmpty)
      .map(
        (drugs) => DrugGroup(
          genericName: drugs.first.genericName ?? '',
          latinName: drugs.first.latinName ?? '',
          drugs: drugs.toList(),
        ),
      )
      .where((groupedDrug) => groupedDrug.drugs.isNotEmpty)
      .toList();
}
