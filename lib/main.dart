import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_drug_registry/core/services/drug_service.dart';
import 'package:flutter_drug_registry/core/services/location_service.dart';
import 'package:flutter_drug_registry/core/services/pharmacy_service.dart';
import 'package:flutter_drug_registry/core/services/shared_preferences_service.dart';
import 'package:flutter_drug_registry/features/main/main.dart';
import 'package:flutter_drug_registry/features/review_prompt/cubit/review_prompt_cubit.dart';
import 'package:flutter_drug_registry/observer.dart';
import 'package:flutter_drug_registry/features/drug_details/cubit/drug_details_cubit.dart';
import 'package:flutter_drug_registry/features/drug_search/bloc/drug_search_bloc.dart';
import 'package:flutter_drug_registry/features/pharmacy_search/bloc/pharmacy_search_bloc.dart';
import 'package:get_it/get_it.dart';

void main() async {
  GetIt.I.registerLazySingleton<DrugService>(() => DrugService());
  GetIt.I.registerLazySingleton<PharmacyService>(() => PharmacyService());
  GetIt.I.registerLazySingleton<LocationService>(() => LocationService());
  GetIt.I.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(),
  );

  WidgetsFlutterBinding.ensureInitialized();

  await GetIt.I.get<SharedPreferencesService>().init();

  Bloc.observer = DrugRegistryBlocObserver();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<DrugSearchBloc>(
          create:
              (_) => DrugSearchBloc(
                GetIt.I.get<DrugService>(),
                GetIt.I.get<SharedPreferencesService>(),
              ),
        ),
        BlocProvider<DrugDetailsCubit>(create: (_) => DrugDetailsCubit()),
        BlocProvider<PharmacySearchBloc>(
          create:
              (_) => PharmacySearchBloc(
                GetIt.I.get<PharmacyService>(),
                GetIt.I.get<SharedPreferencesService>(),
              ),
        ),
        BlocProvider<MainScreenCubit>(
          create:
              (_) => MainScreenCubit(GetIt.I.get<SharedPreferencesService>()),
        ),
        BlocProvider<ReviewPromptCubit>(
          create:
              (_) =>
                  ReviewPromptCubit(GetIt.I.get<SharedPreferencesService>())
                    ..refresh(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (context) => MaterialApp(
            home: const MainScreen(),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
                brightness: Brightness.light,
              ),
            ),
            navigatorKey: navigatorKey,
          ),
    );
  }
}
