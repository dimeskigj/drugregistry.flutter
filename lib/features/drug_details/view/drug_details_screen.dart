import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drug_registry/core/extensions/issuing_type_extensions.dart';
import 'package:flutter_drug_registry/core/models/drug.dart';
import 'package:flutter_drug_registry/widgets/data_point_display.dart';
import 'package:flutter_drug_registry/features/pdf_viewer/pdf_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DrugDetailsScreen extends StatelessWidget {
  const DrugDetailsScreen({super.key, required this.drug});

  final Drug drug;

  static Route<void> route({required Drug drug}) {
    return MaterialPageRoute(
      builder: (context) => DrugDetailsScreen(drug: drug),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultInsets = EdgeInsets.symmetric(horizontal: 20, vertical: 2);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: Text(drug.latinName!),
        actions: [
          if (drug.url != null)
            IconButton(
              onPressed: () => launchUrl(drug.url!),
              icon: const Icon(Icons.open_in_new),
            ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (drug.latinName != null)
              Container(
                margin: defaultInsets,
                child: Text(
                  drug.latinName!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (drug.genericName != null)
              Container(
                margin: defaultInsets,
                child: Text(
                  drug.genericName!,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            if (drug.atc != null)
              Container(
                margin: defaultInsets,
                child: Row(
                  children: [
                    Text(drug.atc!, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            if (drug.issuingType != null)
              Container(
                margin: defaultInsets,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      child: Text(
                        drug.issuingType!.getSymbol(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        drug.issuingType!.getDetails(),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            if (drug.pharmaceuticalForm != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Фармацевтска форма',
                  dataPoint: drug.pharmaceuticalForm!,
                ),
              ),
            if (drug.ingredients != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Состав',
                  dataPoint: drug.ingredients!,
                ),
              ),
            if (drug.packaging != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Пакување',
                  dataPoint: drug.packaging!,
                ),
              ),
            if (drug.strength != null && drug.packaging != drug.strength)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Јачина',
                  dataPoint: drug.strength!,
                ),
              ),
            Container(
              margin: defaultInsets,
              child: DataPointDisplay(
                theme: theme,
                dataPointName: 'Цена со ДДВ',
                dataPoint: drug.priceWithVat?.toString() ?? 'Недефинирана',
              ),
            ),
            Container(
              margin: defaultInsets,
              child: DataPointDisplay(
                theme: theme,
                dataPointName: 'Цена без ДДВ',
                dataPoint: drug.priceWithoutVat?.toString() ?? 'Недефинирана',
              ),
            ),
            if (drug.manufacturer != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Производител',
                  dataPoint: drug.manufacturer!,
                ),
              ),
            if (drug.approvalCarrier != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Носител на одобрение',
                  dataPoint: drug.approvalCarrier!,
                ),
              ),
            if (drug.decisionNumber != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Број на одлука',
                  dataPoint: drug.decisionNumber!,
                ),
              ),
            if (drug.decisionDate != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Датум на одлука',
                  dataPoint: DateFormat(
                    'yyyy/MM/dd',
                  ).format(drug.decisionDate!),
                ),
              ),
            if (drug.validityDate != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Датум на валидност',
                  dataPoint: DateFormat(
                    'yyyy/MM/dd',
                  ).format(drug.validityDate!),
                ),
              ),
            const SizedBox(height: 20),
            if (drug.manualUrl != null)
              InkWell(
                onTap:
                    () => Navigator.of(context).push(
                      PdfViewerScreen.route(
                        title: 'Упатство за употреба',
                        url: drug.manualUrl!,
                      ),
                    ),
                child: Container(
                  margin: defaultInsets.copyWith(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'Упатство за употреба',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            if (drug.reportUrl != null)
              InkWell(
                onTap:
                    () => Navigator.of(context).push(
                      PdfViewerScreen.route(
                        title: 'Збирен извештај',
                        url: drug.reportUrl!,
                      ),
                    ),
                child: Container(
                  margin: defaultInsets.copyWith(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Text('Збирен извештај', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Container(
              margin: defaultInsets,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text:
                          'Секогаш потврдувај ги информациите на официјалната страна на регистарот на лекови ',
                    ),
                    TextSpan(
                      text: 'lekovi.zdravstvo.gov.mk',
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () => launchUrl(drug.url!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          '. Овој лек е последно ажуриран на ${DateFormat('yyyy/MM/dd').format(drug.lastUpdate!)}.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
