import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../data/reference_service.dart';
import '../cubit/countries_cubit.dart';
import 'package:icinema_desktop/app/widgets/state_error_listener.dart';
import 'package:icinema_desktop/app/widgets/state_success_listener.dart';

class CountriesPage extends StatelessWidget {
  const CountriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => CountriesCubit(ReferenceService())..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 120,
              leading: TextButton.icon(
                onPressed: () => context.go('/admin'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Nazad'),
              ),
              title: const Text('Države'),
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
            ),
            body: StateErrorListener<CountriesCubit, CountriesState>(
              errorSelector: (s) => s.error,
              onClear: () => context.read<CountriesCubit>().clearError(),
              child: StateSuccessListener<CountriesCubit, CountriesState>(
                successSelector: (s) => s.success,
                onClear: () => context.read<CountriesCubit>().clearSuccess(),
                child: const _CountriesContent(),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _openAddDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Dodaj državu'),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 400,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Naziv države'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite naziv' : null,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Otkaži')),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.of(ctx).pop(true);
          },
          child: const Text('Sačuvaj'),
        ),
      ],
    ),
  );

  if (result == true) {
    await context.read<CountriesCubit>().create(nameCtrl.text.trim());
  }
}

Future<void> _openEditDialog(BuildContext context, String id, String currentName) async {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController(text: currentName);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Uredi državu'),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 400,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Naziv države'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite naziv' : null,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Otkaži')),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.of(ctx).pop(true);
          },
          child: const Text('Sačuvaj'),
        ),
      ],
    ),
  );

  if (result == true) {
    await context.read<CountriesCubit>().update(id, nameCtrl.text.trim());
  }
}

Future<void> _confirmDelete(BuildContext context, String id, String name) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Brisanje države'),
      content: Text('Da li ste sigurni da želite obrisati državu "$name"?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Otkaži')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Obriši'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await context.read<CountriesCubit>().delete(id);
  }
}

class _CountriesContent extends StatefulWidget {
  const _CountriesContent();

  @override
  State<_CountriesContent> createState() => _CountriesContentState();
}

class _CountriesContentState extends State<_CountriesContent> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pretraga',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 350), () {
                      if (!mounted) return;
                      context.read<CountriesCubit>().load(page: 1, search: v);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openAddDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj državu'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<CountriesCubit, CountriesState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.items.isEmpty) {
                  return Center(
                    child: Text('Greška pri učitavanju: ${state.error}'),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Naziv')),
                                      DataColumn(label: Text('Akcije')),
                                    ],
                                    rows: state.items
                                        .map(
                                          (c) => DataRow(
                                            cells: [
                                              DataCell(Text(c.name)),
                                              DataCell(Row(
                                                children: [
                                                  IconButton(
                                                    tooltip: 'Uredi',
                                                    icon: const Icon(Icons.edit_outlined),
                                                    onPressed: () => _openEditDialog(context, c.id, c.name),
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Obriši',
                                                    icon: const Icon(Icons.delete_outline),
                                                    color: Theme.of(context).colorScheme.error,
                                                    onPressed: () => _confirmDelete(context, c.id, c.name),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Pagination(
                      page: state.page,
                      pageSize: state.pageSize,
                      totalCount: state.totalCount,
                      onPageChanged: (p) => context.read<CountriesCubit>().load(page: p),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int pageSize;
  final int totalCount;
  final void Function(int page) onPageChanged;

  const _Pagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / pageSize).ceil().clamp(1, 999999);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Stranica $page od $totalPages'),
        const SizedBox(width: 12),
        IconButton(
          onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
