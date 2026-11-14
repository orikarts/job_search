import '../../domain/entities/vacancy.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../../domain/repositories/vacancy_repository.dart';

class GetVacanciesUseCase {
  final VacancyRepository _repository;
  const GetVacanciesUseCase(this._repository);

  Future<List<Vacancy>> call(VacancyFilter filter) async {
    final all = await _repository.getAll();
    return all.where(filter.matches).toList();
  }
}