import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'application/use_cases/apply_to_vacancy_use_case.dart';
import 'application/use_cases/get_cities_use_case.dart';
import 'application/use_cases/get_vacancies_use_case.dart';
import 'domain/repositories/vacancy_repository.dart';
import 'infrastructure/config/app_config.dart';
import 'infrastructure/repositories/in_memory_vacancy_repository.dart';
import 'presentation/providers/job_notifier.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  // Dependency Injection: конкретна реалізація підставляється тут
  final VacancyRepository repository = InMemoryVacancyRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JobNotifier(
            getVacancies: GetVacanciesUseCase(repository),
            getCities: GetCitiesUseCase(repository),
            applyToVacancy: ApplyToVacancyUseCase(repository),
          )..init(),
        ),
      ],
      child: const JobSearchApp(),
    ),
  );
}

class JobSearchApp extends StatelessWidget {
  const JobSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}