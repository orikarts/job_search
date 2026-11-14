class Vacancy {
  final String id;
  final String title;
  final String company;
  final String city;
  final String salary;
  final String employment;
  final String level;
  final String logoKey; // ключ логотипа; відповідний IconData живе в Presentation

  const Vacancy({
    required this.id,
    required this.title,
    required this.company,
    required this.city,
    required this.salary,
    required this.employment,
    required this.level,
    required this.logoKey,
  });

  @override
  bool operator ==(Object other) => other is Vacancy && other.id == id;

  @override
  int get hashCode => id.hashCode;
}