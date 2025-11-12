import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../data/reference_service.dart';
import '../../domain/country.dart';
import '../../domain/city.dart';
import '../cubit/cities_cubit.dart';
import 'package:icinema_desktop/app/widgets/state_error_listener.dart';

class CitiesPage extends StatelessWidget {
  const CitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => CitiesCubit(ReferenceService())..load(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 120,
          leading: TextButton.icon(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Nazad'),
          ),
          title: const Text('Gradovi'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: StateErrorListener<CitiesCubit, CitiesState>(
          errorSelector: (s) => s.error,
          onClear: () => context.read<CitiesCubit>().clearError(),
          child: const _CitiesContent(),
        ),
      ),
    );
  }
}

Future<void> _openAddDialog(BuildContext context, List<Country> countries) async {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  String? selectedCountryId = countries.isNotEmpty ? countries.first.id : null;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Dodaj grad'),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Naziv grada'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite naziv' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCountryId,
                isExpanded: true,
                items: countries
                    .map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Država',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) => selectedCountryId = val,
                validator: (v) => (v == null || v.isEmpty) ? 'Odaberite državu' : null,
              ),
            ],
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

  if (result == true && selectedCountryId != null) {
    await context.read<CitiesCubit>().create(name: nameCtrl.text.trim(), countryId: selectedCountryId!);
  }
}

Future<void> _openEditDialog(BuildContext context, City city, List<Country> countries) async {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController(text: city.name);
  String selectedCountryId = city.countryId;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Uredi grad'),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Naziv grada'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite naziv' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCountryId.isEmpty ? null : selectedCountryId,
                isExpanded: true,
                items: countries
                    .map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Država',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) => selectedCountryId = val ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Odaberite državu' : null,
              ),
            ],
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
    await context.read<CitiesCubit>().update(id: city.id, name: nameCtrl.text.trim(), countryId: selectedCountryId);
  }
}

Future<void> _confirmDelete(BuildContext context, City city) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Brisanje grada'),
      content: Text('Da li ste sigurni da želite obrisati grad "${city.name}"?'),
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
    await context.read<CitiesCubit>().delete(city.id);
  }
}

class _CitiesContent extends StatefulWidget {
  const _CitiesContent();

  @override
  State<_CitiesContent> createState() => _CitiesContentState();
}

class _CitiesContentState extends State<_CitiesContent> {
  final _searchCtrl = TextEditingController();
  final _service = ReferenceService();
  List<Country> _countries = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final res = await _service.getCountries(pageSize: 1000);
    if (!mounted) return;
    setState(() => _countries = res.items);
  }

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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
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
                      context.read<CitiesCubit>().load(page: 1, search: v);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 260,
                child: BlocBuilder<CitiesCubit, CitiesState>(
                  buildWhen: (p, n) => p.countryId != n.countryId || p.loading != n.loading,
                  builder: (context, state) {
                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: state.countryId.isEmpty ? null : state.countryId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Sve države'),
                        ),
                        ..._countries.map(
                          (c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Država',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 350), () {
                          if (!mounted) return;
                          context.read<CitiesCubit>().load(page: 1, countryId: val ?? '');
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _countries.isEmpty
                    ? null
                    : () => _openAddDialog(context, _countries),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj grad'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<CitiesCubit, CitiesState>(
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
                                      DataColumn(label: Text('Država')),
                                      DataColumn(label: Text('Akcije')),
                                    ],
                                    rows: state.items
                                        .map(
                                          (city) => DataRow(
                                            cells: [
                                              DataCell(Text(city.name)),
                                              DataCell(Text(
                                                _countries.firstWhere(
                                                  (c) => c.id == city.countryId,
                                                  orElse: () => Country(id: '', name: 'Nepoznato'),
                                                ).name,
                                              )),
                                              DataCell(Row(
                                                children: [
                                                  IconButton(
                                                    tooltip: 'Uredi',
                                                    icon: const Icon(Icons.edit_outlined),
                                                    onPressed: () => _openEditDialog(context, city, _countries),
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Obriši',
                                                    icon: const Icon(Icons.delete_outline),
                                                    color: Theme.of(context).colorScheme.error,
                                                    onPressed: () => _confirmDelete(context, city),
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
                      onPageChanged: (p) => context.read<CitiesCubit>().load(page: p),
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
