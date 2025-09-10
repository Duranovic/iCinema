import 'package:flutter/material.dart';
import '../../domain/report_type.dart';
import '../../data/reports_service.dart';
import '../../../../app/di/injection.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _formKey = GlobalKey<FormState>();
  final _reportsService = getIt<ReportsService>();

  final List<ReportType> _reportTypes = ReportType.values;

  ReportType _selectedType = ReportType.movieReservations;
  DateTime? _from;
  DateTime? _to;

  bool _loading = false;
  List<Map<String, dynamic>> _rows = const [];
  String? _errorMessage;
  ReportType? _currentReportType; // Track the report type of currently displayed data

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _from : _to;
    final first = DateTime(2020, 1, 1);
    final last = DateTime(DateTime.now().year + 1, 12, 31);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: first,
      lastDate: last,
      helpText: isFrom ? 'Period od' : 'Period do',
      locale: const Locale('bs'),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = DateTime(picked.year, picked.month, picked.day);
        } else {
          _to = DateTime(picked.year, picked.month, picked.day);
        }
      });
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await _reportsService.generateReport(
        reportType: _selectedType,
        dateFrom: _from!,
        dateTo: _to!,
      );

      setState(() {
        _rows = response.data;
        _currentReportType = _selectedType; // Update the current report type
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Greška pri generiranju izvještaja: ${e.toString()}';
        _loading = false;
      });
    }
  }

  List<DataColumn> _getColumns() {
    if (_currentReportType == null) return const [];
    switch (_currentReportType!) {
      case ReportType.movieReservations:
        return const [
          DataColumn(label: Text('Naziv filma')),
          DataColumn(label: Text('Broj projekcija')),
          DataColumn(label: Text('Rezervacija')),
          DataColumn(label: Text('Prihod (KM)')),
        ];
      case ReportType.movieSales:
        return const [
          DataColumn(label: Text('Naziv filma')),
          DataColumn(label: Text('Prodane karte')),
          DataColumn(label: Text('Prihod (KM)')),
          DataColumn(label: Text('Prosječna cijena (KM)')),
        ];
      case ReportType.hallReservations:
        return const [
          DataColumn(label: Text('Naziv sale')),
          DataColumn(label: Text('Kino')),
          DataColumn(label: Text('Broj projekcija')),
          DataColumn(label: Text('Rezervacija')),
          DataColumn(label: Text('Popunjenost (%)')),
        ];
      case ReportType.cinemaReservations:
        return const [
          DataColumn(label: Text('Naziv kina')),
          DataColumn(label: Text('Grad')),
          DataColumn(label: Text('Broj projekcija')),
          DataColumn(label: Text('Rezervacija')),
          DataColumn(label: Text('Prihod (KM)')),
        ];
    }
  }

  List<DataCell> _getRowCells(Map<String, dynamic> row) {
    if (_currentReportType == null) return const [];
    switch (_currentReportType!) {
      case ReportType.movieReservations:
        return [
          DataCell(Text(row['name']?.toString() ?? '')),
          DataCell(Text(row['projections']?.toString() ?? '')),
          DataCell(Text(row['reservations']?.toString() ?? '')),
          DataCell(Text(row['revenue']?.toStringAsFixed(2) ?? '')),
        ];
      case ReportType.movieSales:
        return [
          DataCell(Text(row['name']?.toString() ?? '')),
          DataCell(Text(row['ticketsSold']?.toString() ?? '')),
          DataCell(Text(row['revenue']?.toStringAsFixed(2) ?? '')),
          DataCell(Text(row['avgPrice']?.toStringAsFixed(2) ?? '')),
        ];
      case ReportType.hallReservations:
        return [
          DataCell(Text(row['name']?.toString() ?? '')),
          DataCell(Text(row['cinema']?.toString() ?? '')),
          DataCell(Text(row['projections']?.toString() ?? '')),
          DataCell(Text(row['reservations']?.toString() ?? '')),
          DataCell(Text('${row['occupancy']?.toStringAsFixed(1) ?? ''}%')),
        ];
      case ReportType.cinemaReservations:
        return [
          DataCell(Text(row['name']?.toString() ?? '')),
          DataCell(Text(row['city']?.toString() ?? '')),
          DataCell(Text(row['projections']?.toString() ?? '')),
          DataCell(Text(row['reservations']?.toString() ?? '')),
          DataCell(Text(row['revenue']?.toStringAsFixed(2) ?? '')),
        ];
    }
  }

  List<DataCell> _getTotalCells() {
    if (_currentReportType == null) return const [];
    switch (_currentReportType!) {
      case ReportType.movieReservations:
        final totalProjections = _rows.fold<int>(0, (sum, row) => sum + (row['projections'] as int? ?? 0));
        final totalReservations = _rows.fold<int>(0, (sum, row) => sum + (row['reservations'] as int? ?? 0));
        final totalRevenue = _rows.fold<double>(0.0, (sum, row) => sum + (row['revenue'] as double? ?? 0.0));
        return [
          const DataCell(Text('Ukupno', style: TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalProjections.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalReservations.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalRevenue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w600))),
        ];
      case ReportType.movieSales:
        final totalTickets = _rows.fold<int>(0, (sum, row) => sum + (row['ticketsSold'] as int? ?? 0));
        final totalRevenue = _rows.fold<double>(0.0, (sum, row) => sum + (row['revenue'] as double? ?? 0.0));
        final avgPrice = totalTickets > 0 ? totalRevenue / totalTickets : 0.0;
        return [
          const DataCell(Text('Ukupno', style: TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalTickets.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalRevenue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(avgPrice.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w600))),
        ];
      case ReportType.hallReservations:
        final totalProjections = _rows.fold<int>(0, (sum, row) => sum + (row['projections'] as int? ?? 0));
        final totalReservations = _rows.fold<int>(0, (sum, row) => sum + (row['reservations'] as int? ?? 0));
        final avgOccupancy = _rows.isNotEmpty 
            ? _rows.fold<double>(0.0, (sum, row) {
                final occupancy = row['occupancy'];
                final occupancyDouble = occupancy is int ? occupancy.toDouble() : (occupancy as double? ?? 0.0);
                return sum + occupancyDouble;
              }) / _rows.length
            : 0.0;
        return [
          const DataCell(Text('Ukupno', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataCell(Text('-', style: TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalProjections.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalReservations.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text('${avgOccupancy.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w600))),
        ];
      case ReportType.cinemaReservations:
        final totalProjections = _rows.fold<int>(0, (sum, row) => sum + (row['projections'] as int? ?? 0));
        final totalReservations = _rows.fold<int>(0, (sum, row) => sum + (row['reservations'] as int? ?? 0));
        final totalRevenue = _rows.fold<double>(0.0, (sum, row) => sum + (row['revenue'] as double? ?? 0.0));
        return [
          const DataCell(Text('Ukupno', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataCell(Text('-', style: TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalProjections.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalReservations.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          DataCell(Text(totalRevenue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w600))),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izvještavanje'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Filters
            Container(
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iCinema Admin Panel - Izvještavanje',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            runSpacing: 12,
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Tip izvještaja
                              SizedBox(
                                width: 260,
                                child: DropdownButtonFormField<ReportType>(
                                  value: _selectedType,
                                  decoration: const InputDecoration(
                                    labelText: 'Tip izvještaja',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _reportTypes
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedType = v!),
                                ),
                              ),
                              // Period od
                              SizedBox(
                                width: 180,
                                child: InkWell(
                                  onTap: () => _pickDate(isFrom: true),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Period od',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                                    ),
                                    child: Text(_fmt(_from)),
                                  ),
                                ),
                              ),
                              // Period do
                              SizedBox(
                                width: 180,
                                child: InkWell(
                                  onTap: () => _pickDate(isFrom: false),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Period do',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                                    ),
                                    child: Text(_fmt(_to)),
                                  ),
                                ),
                              ),
                              // Generate button
                              ElevatedButton.icon(
                                onPressed: _loading ? null : _generate,
                                icon: const Icon(Icons.assessment_outlined),
                                label: const Text('Generiši izvještaj'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // PDF button (aligned to the right)
                        OutlinedButton.icon(
                          onPressed: _rows.isEmpty ? null : () {/* TODO: export to PDF */},
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Preuzmi PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Results
            Expanded(
              child: Container(
                width: double.infinity,
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
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _ErrorState(message: _errorMessage!)
                        : _rows.isEmpty
                            ? const _EmptyState()
                            : _ReportTable(
                                title:
                                    'Izvještaj: ${_currentReportType?.displayName ?? ''} za period ${_fmt(_from)} - ${_fmt(_to)}',
                                columns: _getColumns(),
                                rows: _rows,
                                getRowCells: _getRowCells,
                                getTotalCells: _getTotalCells,
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insert_chart_outlined,
            size: 64, color: Theme.of(context).disabledColor),
        const SizedBox(height: 12),
        Text(
          'Rezultati izvještaja će se prikazati ovdje',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline,
            size: 64, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ReportTable extends StatelessWidget {
  final String title;
  final List<DataColumn> columns;
  final List<Map<String, dynamic>> rows;
  final List<DataCell> Function(Map<String, dynamic>) getRowCells;
  final List<DataCell> Function() getTotalCells;

  const _ReportTable({
    required this.title,
    required this.columns,
    required this.rows,
    required this.getRowCells,
    required this.getTotalCells,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DataTable(
              columns: columns,
              rows: [
                ...rows.map((row) => DataRow(cells: getRowCells(row))),
                DataRow(cells: List.generate(columns.length, (_) => const DataCell(SizedBox.shrink()))),
                DataRow(cells: getTotalCells()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
