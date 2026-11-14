import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/vacancy.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../logo_icons.dart';
import '../providers/job_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Вакансії'),
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        actions: [
          // Точкова підписка: перебудовується лише іконка з бейджем
          Consumer<JobNotifier>(
            builder: (context, job, _) => IconButton(
              tooltip: 'Активні фільтри',
              onPressed: () => context.read<JobNotifier>().resetFilters(),
              icon: Badge(
                isLabelVisible: job.activeCount > 0,
                label: Text('${job.activeCount}'),
                child: const Icon(Icons.filter_alt_outlined),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Збережені',
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _SearchField(),
            const _FiltersRow(),
            const _ResultsHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 900 : double.infinity,
                      ),
                      // Список вакансій через Selector
                      child: Selector<JobNotifier, List<Vacancy>>(
                        selector: (_, job) => job.vacancies,
                        shouldRebuild: (prev, next) => !listEquals(prev, next),
                        builder: (context, vacancies, _) {
                          if (vacancies.isEmpty) {
                            return const _EmptyState();
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: vacancies.length,
                            itemBuilder: (context, index) =>
                                VacancyCard(vacancy: vacancies[index]),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Поле пошуку (без власного стану: значення йде в JobNotifier)
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (value) => context.read<JobNotifier>().setQuery(value),
        decoration: InputDecoration(
          hintText: 'Посада, компанія або ключове слово',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

/// Рядок чіпів-фільтрів. context.watch №1
class _FiltersRow extends StatelessWidget {
  const _FiltersRow();

  @override
  Widget build(BuildContext context) {
    final job = context.watch<JobNotifier>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Місто
            InputChip(
              avatar: const Icon(Icons.location_on_outlined, size: 18),
              label: Text(job.city ?? 'Місто'),
              selected: job.city != null,
              onPressed: () => _pickCity(context),
              onDeleted: job.city == null
                  ? null
                  : () => context.read<JobNotifier>().setCity(null),
            ),
            const SizedBox(width: 8),
            // Тип зайнятості
            for (final type in VacancyFilter.employmentTypes) ...[
              FilterChip(
                label: Text(type),
                selected: job.filters.contains(type),
                onSelected: (_) =>
                    context.read<JobNotifier>().toggleFilter(type),
              ),
              const SizedBox(width: 8),
            ],
            // Рівень
            for (final level in VacancyFilter.levels) ...[
              FilterChip(
                label: Text(level),
                selected: job.filters.contains(level),
                onSelected: (_) =>
                    context.read<JobNotifier>().toggleFilter(level),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  void _pickCity(BuildContext context) {
    final job = context.read<JobNotifier>();
    final cities = job.cities;
    final current = job.city;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Усі міста'),
              trailing: current == null ? const Icon(Icons.check) : null,
              onTap: () {
                job.setCity(null);
                Navigator.pop(sheetContext);
              },
            ),
            for (final city in cities)
              ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(city),
                trailing: current == city ? const Icon(Icons.check) : null,
                onTap: () {
                  job.setCity(city);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Заголовок результатів. context.watch №2 (інше місце дерева)
class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final job = context.watch<JobNotifier>();
    final count = job.vacancies.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Знайдено: $count',
            style: text.labelLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (job.activeCount > 0)
            TextButton.icon(
              onPressed: () => context.read<JobNotifier>().resetFilters(),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Скинути'),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: colors.outline),
          const SizedBox(height: 8),
          Text('Вакансій не знайдено', style: text.titleMedium),
        ],
      ),
    );
  }
}

/// Картка вакансії
class VacancyCard extends StatelessWidget {
  final Vacancy vacancy;

  const VacancyCard({super.key, required this.vacancy});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Логотип 56x56
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconForLogo(vacancy.logoKey),
                color: colors.onSecondaryContainer,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),

            // Назва / компанія / місто
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vacancy.title,
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vacancy.company} · ${vacancy.level}',
                    style: text.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: colors.primary),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${vacancy.city} · ${vacancy.employment}',
                          style: text.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Зарплата + кнопка
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      vacancy.salary,
                      style: text.titleSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    context.read<JobNotifier>().apply(vacancy.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Відгук надіслано: ${vacancy.title}'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Відгукнутись'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}