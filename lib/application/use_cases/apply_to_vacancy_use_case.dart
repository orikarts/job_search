import '../../domain/repositories/vacancy_repository.dart';

class ApplyToVacancyUseCase {
  final VacancyRepository _repository;
  const ApplyToVacancyUseCase(this._repository);

  Future<void> call(String vacancyId) => _repository.apply(vacancyId);
}