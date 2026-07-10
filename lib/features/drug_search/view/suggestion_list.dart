import 'package:flutter/material.dart';
import 'package:flutter_drug_registry/core/models/drug.dart';
import 'package:flutter_drug_registry/core/models/drug_group.dart';
import 'package:flutter_drug_registry/core/utils/drug_grouping.dart';

class DrugSuggestionList extends StatelessWidget {
  const DrugSuggestionList({
    super.key,
    required this.drugs,
    required this.onTileTap,
  });

  final List<Drug> drugs;
  final void Function(DrugGroup d) onTileTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...groupDrugsByType(drugs)
            .map(
              (d) => GestureDetector(
                onTap: () => onTileTap(d),
                child: ListTile(
                  key: Key(d.genericName + d.latinName),
                  leading: const Icon(Icons.search),
                  trailing:
                      d.drugs.length > 1
                          ? CircleAvatar(
                            radius: 12,
                            child: Text(d.drugs.length.toString()),
                          )
                          : const SizedBox(),
                  title: Text(d.latinName),
                  subtitle: Text(d.genericName),
                ),
              ),
            )
            .toList(),
        Container(height: 300),
      ],
    );
  }
}
