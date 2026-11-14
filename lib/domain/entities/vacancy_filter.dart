import 'vacancy.dart';

class VacancyFilter {
  static const List<String> employmentTypes = [
    'Повна зайнятість',
    'Часткова',
    'Віддалено',
  ];
  static const List<String> levels = ['Junior', 'Middle', 'Senior'];

  final String query;
  final Set<String> filters;
  final String? city;

  const VacancyFilter({
    this.query = '',
    this.filters = const {},
    this.city,
  });

  /// Між групами "І", всередині групи "АБО".
  bool matches(Vacancy v) {
    final q = query.trim().toLowerCase();
    final types = filters.where(employmentTypes.contains).toSet();
    final lvls = filters.where(levels.contains).toSet();

    final okQuery = q.isEmpty ||
        v.title.toLowerCase().contains(q) ||
        v.company.toLowerCase().contains(q);
    final okType = types.isEmpty || types.contains(v.employment);
    final okLevel = lvls.isEmpty || lvls.contains(v.level);
    final okCity = city == null || v.city == city;

    return okQuery && okType && okLevel && okCity;
  }
}