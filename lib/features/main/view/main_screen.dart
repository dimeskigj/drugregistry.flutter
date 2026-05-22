import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drug_registry/constants.dart';
import 'package:flutter_drug_registry/features/drug_search/view/drug_search_screen.dart';
import 'package:flutter_drug_registry/features/information/information.dart';
import 'package:flutter_drug_registry/features/main/main.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/pharmacy_search.dart';
import 'package:flutter_drug_registry/features/review_prompt/cubit/review_prompt_cubit.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final PageStorageBucket bucket = PageStorageBucket();
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<MainScreenCubit>(context).checkIsFirstTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        elevation: 10,
        shadowColor: Theme.of(context).shadowColor,
        selectedIndex: currentPageIndex,
        onDestinationSelected:
            (value) => setState(() {
              currentPageIndex = value;
            }),
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.medication_rounded),
            icon: Icon(Icons.medication_outlined),
            label: 'Лекови',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.health_and_safety_rounded),
            icon: Icon(Icons.health_and_safety_outlined),
            label: 'Аптеки',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.info_rounded),
            icon: Icon(Icons.info_outline_rounded),
            label: 'Информации',
          ),
        ],
      ),
      body: PageStorage(
        bucket: bucket,
        child: BlocListener<MainScreenCubit, MainScreenCubitState>(
          listener: (BuildContext context, MainScreenCubitState state) {
            switch (state) {
              case MainScreenFirstTime():
                showFirstTimeBottomSheet(context);
              case _:
                break;
            }
          },
          child:
              const [
                DrugSearchScreen(),
                PharmacySearchScreen(),
                InformationScreen(),
              ][currentPageIndex],
        ),
      ),
    );
  }

  Future<void> showFirstTimeBottomSheet(BuildContext context) {
    var theme = Theme.of(context);

    return showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder:
          (context) => Container(
            height: 500,
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Добредојде на Регистар на Лекови!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'Ова е '),
                              TextSpan(
                                text: 'неофицијална ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    'мобилна апликација за македонскиот регистар на лекови. ',
                              ),
                              const TextSpan(
                                text:
                                    'Оваа апликација не е поврзана со ниту една државна институција и е направена од независно лице. Информациите за лекови и аптеки се влечат од ',
                              ),
                              TextSpan(
                                text: Constants.lekoviUrl,
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap =
                                          () => launchUrlString(
                                            Constants.lekoviUrl,
                                          ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.primaryColor,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. Во секое време можеш да прочиташ информации за оваа апликација во табот за информации.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed:
                          () => launchUrlString(Constants.privacyPolicyUrl),
                      label: const Text('Политика за Приватност'),
                      icon: const Icon(Icons.launch),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final mainScreenCubit = context.read<MainScreenCubit>();
                        final reviewPromptCubit =
                            context.read<ReviewPromptCubit>();

                        await mainScreenCubit.confirmFirstTimeDialog();
                        reviewPromptCubit.refresh();
                        navigator.pop();
                      },
                      child: const Text('Разбирам'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
