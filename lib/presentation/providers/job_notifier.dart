import 'package:flutter/foundation.dart';

import '../../application/use_cases/apply_to_vacancy_use_case.dart';
import '../../application/use_cases/get_cities_use_case.dart';
import '../../application/use_cases/get_vacancies_use_case.dart';
import '../../domain/entities/vacancy.dart';
import '../../domain/entities/vacancy_filter.dart';

class JobNotifier extends ChangeNotifier {
  final GetVacanciesUseCase _getVacancies;
  final GetCitiesUseCase _getCities;
  final ApplyToVacancyUseCase _applyToVacancy;

  JobNotifier({
    required GetVacanciesUseCase getVacancies,
    required GetCitiesUseCase getCities,
    required ApplyToVacancyUseCase applyToVacancy,
  })  : _getVacancies = getVacancies,
        _getCities = getCities,
        _applyToVacancy = applyToVacancy;

  String _query = '';
  final Set<String> _filters = {};
  String? _city;

  List<Vacancy> _vacancies = const [];
  List<String> _cities = const [];
  int _requestId = 0; // захист від "гонки" асинхронних запитів

  String get query => _query;
  Set<String> get filters => Set.unmodifiable(_filters);
  String? get city => _city;
  List<Vacancy> get vacancies => _vacancies;
  List<String> get cities => _cities;
  int get activeCount => _filters.length + (_city != null ? 1 : 0);

  Future<void> init() async {
    _cities = await _getCities();
    await _refresh();
  }

  Future<void> _refresh() async {
    final id = ++_requestId;
    final result = await _getVacancies(VacancyFilter(
      query: _query,
      filters: Set.of(_filters),
      city: _city,
    ));
    if (id != _requestId) return; // прийшла застаріла відповідь
    _vacancies = result;
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
    _refresh();
  }

  void toggleFilter(String filter) {
    if (!_filters.remove(filter)) _filters.add(filter);
    notifyListeners();
    _refresh();
  }

  void setCity(String? city) {
    if (city == _city) return;
    _city = city;
    notifyListeners();
    _refresh();
  }

  void resetFilters() {
    _filters.clear();
    _city = null;
    notifyListeners();
    _refresh();
  }

  Future<void> apply(String vacancyId) => _applyToVacancy(vacancyId);
}