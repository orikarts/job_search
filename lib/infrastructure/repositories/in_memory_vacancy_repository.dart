import '../../domain/entities/vacancy.dart';
import '../../domain/repositories/vacancy_repository.dart';

class InMemoryVacancyRepository implements VacancyRepository {
  final Set<String> _appliedIds = {};

  final List<Vacancy> _data = const [
    Vacancy(id: '1', title: 'Flutter-розробник', company: 'SoftServe', city: 'Львів',
        salary: '60 000 – 90 000 ₴', employment: 'Повна зайнятість', level: 'Middle', logoKey: 'phone'),
    Vacancy(id: '2', title: 'UI/UX дизайнер', company: 'Grammarly', city: 'Київ',
        salary: '45 000 – 70 000 ₴', employment: 'Віддалено', level: 'Middle', logoKey: 'design'),
    Vacancy(id: '3', title: 'Backend-розробник (Python)', company: 'EPAM', city: 'Харків',
        salary: '70 000 – 110 000 ₴', employment: 'Повна зайнятість', level: 'Senior', logoKey: 'server'),
    Vacancy(id: '4', title: 'QA інженер', company: 'Luxoft', city: 'Дніпро',
        salary: '35 000 – 55 000 ₴', employment: 'Часткова', level: 'Junior', logoKey: 'bug'),
    Vacancy(id: '5', title: 'Project Manager', company: 'Ciklum', city: 'Київ',
        salary: '80 000 – 120 000 ₴', employment: 'Повна зайнятість', level: 'Senior', logoKey: 'team'),
  ];

  @override
  Future<List<Vacancy>> getAll() async => List.unmodifiable(_data);

  @override
  Future<void> apply(String vacancyId) async {
    _appliedIds.add(vacancyId);
  }
}