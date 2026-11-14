import '../../domain/repositories/vacancy_repository.dart';

class GetCitiesUseCase {
  final VacancyRepository _repository;
  const GetCitiesUseCase(this._repository);

  Future<List<String>> call() async {
    final all = await _repository.getAll();
    return all.map((v) => v.city).toSet().toList()..sort();
  }
}