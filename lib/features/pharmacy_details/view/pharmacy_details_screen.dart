import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drug_registry/core/models/pharmacy.dart';
import 'package:flutter_drug_registry/features/review_prompt/cubit/review_prompt_cubit.dart';
import 'package:flutter_drug_registry/widgets/data_point_display.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PharmacyDetailsScreen extends StatefulWidget {
  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  final Pharmacy pharmacy;

  static Route<void> route({required Pharmacy pharmacy}) {
    return MaterialPageRoute(
      builder: (context) => PharmacyDetailsScreen(pharmacy: pharmacy),
    );
  }

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewPromptCubit>().recordDetailView();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultInsets = EdgeInsets.symmetric(horizontal: 20, vertical: 2);
    final pharmacy = widget.pharmacy;
    final pharmacyName = pharmacy.name ?? 'Аптека';

    var hasEmail = (pharmacy.email?.length ?? 0) > 1;
    var hasPhoneNumber = (pharmacy.phoneNumber?.length ?? 0) > 1;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 75, title: Text(pharmacyName)),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: defaultInsets,
              child: Text(
                pharmacyName,
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
