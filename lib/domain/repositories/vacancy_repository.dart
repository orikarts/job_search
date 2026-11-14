import '../entities/vacancy.dart';

abstract interface class VacancyRepository {
  Future<List<Vacancy>> getAll();
  Future<void> apply(String vacancyId);
}