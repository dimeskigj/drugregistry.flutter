import 'package:flutter/material.dart';
import 'package:flutter_drug_registry/core/models/pharmacy.dart';
import 'package:flutter_drug_registry/widgets/data_point_display.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PharmacyDetailsScreen extends StatelessWidget {
  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  final Pharmacy pharmacy;

  static Route<void> route({required Pharmacy pharmacy}) {
    return MaterialPageRoute(
      builder: (context) => PharmacyDetailsScreen(pharmacy: pharmacy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultInsets = EdgeInsets.symmetric(horizontal: 20, vertical: 2);

    var hasEmail = pharmacy.email != null && pharmacy.email!.length > 1;
    var hasPhoneNumber =
        pharmacy.phoneNumber != null && pharmacy.phoneNumber!.length > 1;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 75, title: Text(pharmacy.name!)),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: defaultInsets,
              child: Text(
                pharmacy.name!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (pharmacy.municipality != null)
              Container(
                margin: defaultInsets,
                child: Row(
                  children: [
                    Text(
                      pharmacy.municipality!,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            if (pharmacy.address != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Адреса',
                  dataPoint: pharmacy.address!,
                ),
              ),
            if (pharmacy.place != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Место',
                  dataPoint: pharmacy.place!,
                ),
              ),
            if (hasEmail || hasPhoneNumber) const SizedBox(height: 30),
            if (hasEmail)
              InkWell(
                onTap: () => launchUrlString('mailto:${pharmacy.email}'),
                child: Container(
                  margin: defaultInsets.copyWith(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.mail, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pharmacy.email!,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Icon(Icons.exit_to_app, color: theme.hintColor),
                    ],
                  ),
                ),
              ),
            if (hasPhoneNumber)
              InkWell(
                onTap: () => launchUrlString('tel:${pharmacy.phoneNumber}'),
                child: Container(
                  margin: defaultInsets.copyWith(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pharmacy.phoneNumber!,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Icon(Icons.exit_to_app, color: theme.hintColor),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
            if (pharmacy.code != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Шифра',
                  dataPoint: pharmacy.code!,
                ),
              ),
            if (pharmacy.idNumber != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Матичен број',
                  dataPoint: pharmacy.idNumber!,
                ),
              ),
            if (pharmacy.taxNumber != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Даночен број',
                  dataPoint: pharmacy.taxNumber!,
                ),
              ),
            if (pharmacy.pharmacists != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Фармацевти',
                  dataPoint: pharmacy.pharmacists!,
                ),
              ),
            if (pharmacy.technicians != null)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Техничари',
                  dataPoint: pharmacy.technicians!,
                ),
              ),
            if (pharmacy.comment != null && pharmacy.comment!.isNotEmpty)
              Container(
                margin: defaultInsets,
                child: DataPointDisplay(
                  theme: theme,
                  dataPointName: 'Коментар',
                  dataPoint: pharmacy.comment!,
                ),
              ),
            Container(
              margin: defaultInsets,
              child: DataPointDisplay(
                theme: theme,
                dataPointName: 'Активна',
                dataPoint: pharmacy.active ? 'Да' : 'Не',
              ),
            ),
            Container(
              margin: defaultInsets,
              child: DataPointDisplay(
                theme: theme,
                dataPointName: 'Централна',
                dataPoint: pharmacy.central ? 'Да' : 'Не',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
