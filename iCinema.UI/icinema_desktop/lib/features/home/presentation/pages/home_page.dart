import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icinema_desktop/features/home/presentation/bloc/home_kpis_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Početna'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting / heading
            Text(
              'Dobrodošli u iCinema administraciju',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Brzi pregled ključnih informacija i akcija',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),

            // Simple KPI cards (live from backend via Cubit)
            BlocBuilder<HomeKpisCubit, HomeKpisState>(
              builder: (context, state) {
                if (state is HomeKpisLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is HomeKpisError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Greška pri učitavanju KPI podataka',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.read<HomeKpisCubit>().load(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Pokušaj ponovo'),
                        ),
                      ],
                    ),
                  );
                }

                final k = (state as HomeKpisLoaded).data;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 700;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _KpiCard(title: 'Rezervacije danas', value: '${k.reservationsToday}'),
                        _KpiCard(title: 'Prihod (KM)', value: k.revenueMonth.toStringAsFixed(2)),
                        _KpiCard(title: 'Prosječna popunjenost', value: '${k.avgOccupancy.toStringAsFixed(1)}%'),
                      ].map((w) => SizedBox(
                            width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
                            child: w,
                          )).toList(),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick actions
            Text('Brze akcije', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/projections'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Dodaj projekciju'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/reports'),
                  icon: const Icon(Icons.insert_chart_outlined),
                  label: const Text('Generiši izvještaj'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 8),
            Text(value, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
