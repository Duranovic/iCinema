import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/report_type.dart';

@injectable
class PdfService {
  Future<void> generateAndDownloadReport({
    required ReportType reportType,
    required List<Map<String, dynamic>> data,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final pdf = pw.Document();
    
    // Load a Unicode-compatible font
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    // Generate PDF content based on report type
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(reportType, dateFrom, dateTo, font, fontBold),
            pw.SizedBox(height: 20),
            _buildTable(reportType, data, font, fontBold),
            pw.SizedBox(height: 20),
            _buildTotals(reportType, data, font, fontBold),
          ];
        },
      ),
    );

    // Save and open PDF
    await _saveAndOpenPdf(pdf, reportType, dateFrom, dateTo);
  }

  pw.Widget _buildHeader(ReportType reportType, DateTime dateFrom, DateTime dateTo, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'iCinema - Izvještaj',
          style: pw.TextStyle(
            fontSize: 24,
            font: fontBold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Tip izvještaja: ${reportType.displayName}',
          style: pw.TextStyle(fontSize: 16, font: font),
        ),
        pw.Text(
          'Period: ${_formatDate(dateFrom)} - ${_formatDate(dateTo)}',
          style: pw.TextStyle(fontSize: 16, font: font),
        ),
        pw.Text(
          'Generirano: ${_formatDate(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildTable(ReportType reportType, List<Map<String, dynamic>> data, pw.Font font, pw.Font fontBold) {
    final headers = _getTableHeaders(reportType);
    final rows = data.map((row) => _getTableRow(reportType, row)).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: _getColumnWidths(reportType),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: headers.map((header) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              header,
              style: pw.TextStyle(font: fontBold),
            ),
          )).toList(),
        ),
        // Data rows
        ...rows.map((row) => pw.TableRow(
          children: row.map((cell) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(cell, style: pw.TextStyle(font: font)),
          )).toList(),
        )),
      ],
    );
  }

  pw.Widget _buildTotals(ReportType reportType, List<Map<String, dynamic>> data, pw.Font font, pw.Font fontBold) {
    final totals = _calculateTotals(reportType, data);
    if (totals.isEmpty) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ukupno:',
            style: pw.TextStyle(
              fontSize: 16,
              font: fontBold,
            ),
          ),
          pw.SizedBox(height: 8),
          ...totals.entries.map((entry) => pw.Text(
            '${entry.key}: ${entry.value}',
            style: pw.TextStyle(fontSize: 14, font: font),
          )),
        ],
      ),
    );
  }

  List<String> _getTableHeaders(ReportType reportType) {
    switch (reportType) {
      case ReportType.movieReservations:
        return ['Naziv filma', 'Broj projekcija', 'Rezervacija', 'Prihod (KM)'];
      case ReportType.movieSales:
        return ['Naziv filma', 'Prodane karte', 'Prihod (KM)', 'Prosječna cijena (KM)'];
      case ReportType.hallReservations:
        return ['Naziv sale', 'Kino', 'Broj projekcija', 'Rezervacija', 'Popunjenost (%)'];
      case ReportType.cinemaReservations:
        return ['Naziv kina', 'Grad', 'Broj projekcija', 'Rezervacija', 'Prihod (KM)'];
    }
  }

  List<String> _getTableRow(ReportType reportType, Map<String, dynamic> row) {
    switch (reportType) {
      case ReportType.movieReservations:
        return [
          row['name']?.toString() ?? '',
          row['projections']?.toString() ?? '',
          row['reservations']?.toString() ?? '',
          (row['revenue'] as double?)?.toStringAsFixed(2) ?? '',
        ];
      case ReportType.movieSales:
        return [
          row['name']?.toString() ?? '',
          row['ticketsSold']?.toString() ?? '',
          (row['revenue'] as double?)?.toStringAsFixed(2) ?? '',
          (row['avgPrice'] as double?)?.toStringAsFixed(2) ?? '',
        ];
      case ReportType.hallReservations:
        return [
          row['name']?.toString() ?? '',
          row['cinema']?.toString() ?? '',
          row['projections']?.toString() ?? '',
          row['reservations']?.toString() ?? '',
          '${(row['occupancy'] as num?)?.toStringAsFixed(1) ?? ''}%',
        ];
      case ReportType.cinemaReservations:
        return [
          row['name']?.toString() ?? '',
          row['city']?.toString() ?? '',
          row['projections']?.toString() ?? '',
          row['reservations']?.toString() ?? '',
          (row['revenue'] as double?)?.toStringAsFixed(2) ?? '',
        ];
    }
  }

  Map<int, pw.TableColumnWidth> _getColumnWidths(ReportType reportType) {
    switch (reportType) {
      case ReportType.movieReservations:
        return {
          0: const pw.FlexColumnWidth(3), // Movie name
          1: const pw.FlexColumnWidth(2), // Projections
          2: const pw.FlexColumnWidth(2), // Reservations
          3: const pw.FlexColumnWidth(2), // Revenue
        };
      case ReportType.movieSales:
        return {
          0: const pw.FlexColumnWidth(3), // Movie name
          1: const pw.FlexColumnWidth(2), // Tickets sold
          2: const pw.FlexColumnWidth(2), // Revenue
          3: const pw.FlexColumnWidth(2), // Avg price
        };
      case ReportType.hallReservations:
        return {
          0: const pw.FlexColumnWidth(2), // Hall name
          1: const pw.FlexColumnWidth(2), // Cinema
          2: const pw.FlexColumnWidth(2), // Projections
          3: const pw.FlexColumnWidth(2), // Reservations
          4: const pw.FlexColumnWidth(2), // Occupancy
        };
      case ReportType.cinemaReservations:
        return {
          0: const pw.FlexColumnWidth(3), // Cinema name
          1: const pw.FlexColumnWidth(2), // City
          2: const pw.FlexColumnWidth(2), // Projections
          3: const pw.FlexColumnWidth(2), // Reservations
          4: const pw.FlexColumnWidth(2), // Revenue
        };
    }
  }

  Map<String, String> _calculateTotals(ReportType reportType, List<Map<String, dynamic>> data) {
    if (data.isEmpty) return {};

    switch (reportType) {
      case ReportType.movieReservations:
        final totalProjections = data.fold<int>(0, (sum, row) => sum + (row['projections'] as int? ?? 0));
        final totalReservations = data.fold<int>(0, (sum, row) => sum + (row['reservations'] as int? ?? 0));
        final totalRevenue = data.fold<double>(0.0, (sum, row) => sum + (row['revenue'] as double? ?? 0.0));
        return {
          'Broj projekcija': totalProjections.toString(),
          'Rezervacija': totalReservations.toString(),
          'Prihod': '${totalRevenue.toStringAsFixed(2)} KM',
        };
      case ReportType.movieSales:
        final totalTickets = data.fold<int>(0, (sum, row) => sum + (row['ticketsSold'] as int? ?? 0));
        final totalRevenue = data.fold<double>(0.0, (sum, row) => sum + (row['revenue'] as double? ?? 0.0));
        final avgPrice = totalTickets > 0 ? totalRevenue / totalTickets : 0.0;
        return {
          'Prodane karte': totalTickets.toString(),
          'Prihod': '${totalRevenue.toStringAsFixed(2)} KM',
          'Prosječna cijena': '${avgPrice.toStringAsFixed(2)} KM',
        };
      case ReportType.hallReservations:
        final totalProjections = data.fold<int>(0, (sum, row) => sum + (row['projections'] as int? ?? 0));
        final totalReservations = data.fold<int>(0, (sum, row) => sum + (row['reservations'] as int? ?? 0));
        final avgOccupancy = data.isNotEmpty 
            ? data.fold<double>(0.0, (sum, row) {
                final occupancy = row['occupancy'];
                final occupancyDouble = occupancy is int ? occupancy.toDouble() : (occupancy as double? ?? 0.0);
                return sum + occupancyDouble;
              }) / data.length
            : 0.0;
        return {
          'Broj projekcija': totalProjections.toString(),
          'Rezervacija': totalReservations.toString(),
          'Prosječna popunjenost': '${avgOccupancy.toStringAsFixed(1)}%',
        };
      case ReportType.cinemaReservations:
        final totalProjections = data.fold<int>(0, (sum, row) => sum + (row['projections'] as int? ?? 0));
        final totalReservations = data.fold<int>(0, (sum, row) => sum + (row['reservations'] as int? ?? 0));
        final totalRevenue = data.fold<double>(0.0, (sum, row) => sum + (row['revenue'] as double? ?? 0.0));
        return {
          'Broj projekcija': totalProjections.toString(),
          'Rezervacija': totalReservations.toString(),
          'Prihod': '${totalRevenue.toStringAsFixed(2)} KM',
        };
    }
  }

  Future<void> _saveAndOpenPdf(pw.Document pdf, ReportType reportType, DateTime dateFrom, DateTime dateTo) async {
    final Uint8List bytes = await pdf.save();
    
    // Generate filename
    final fileName = 'iCinema_${reportType.name}_${_formatDateForFilename(dateFrom)}_${_formatDateForFilename(dateTo)}.pdf';
    
    // On desktop, save to a safe directory (HOME/Downloads -> HOME -> system temp) and open with system default
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        // Determine a writable directory without using path_provider (to avoid MissingPluginException on desktop)
        Directory directory;
        if (Platform.isMacOS) {
          // macOS sandbox restricts access to Downloads/Desktop without user prompt; use system temp
          directory = Directory.systemTemp;
        } else if (Platform.isLinux) {
          final home = Platform.environment['HOME'];
          if (home != null && home.isNotEmpty) {
            final downloads = Directory('$home/Downloads');
            directory = await downloads.exists() ? downloads : Directory(home);
          } else {
            directory = Directory.systemTemp;
          }
        } else {
          // Windows
          final userProfile = Platform.environment['USERPROFILE'];
          if (userProfile != null && userProfile.isNotEmpty) {
            final downloads = Directory('$userProfile\\Downloads');
            directory = await downloads.exists() ? downloads : Directory(userProfile);
          } else {
            directory = Directory.systemTemp;
          }
        }

        final file = File('${directory.path}${Platform.pathSeparator}$fileName');
        await file.writeAsBytes(bytes);
        
        // Open the PDF with system default application using OS commands (avoid url_launcher on desktop)
        try {
          if (Platform.isMacOS) {
            await Process.run('open', [file.path]);
          } else if (Platform.isLinux) {
            await Process.run('xdg-open', [file.path]);
          } else if (Platform.isWindows) {
            await Process.run('start', [file.path], runInShell: true);
          }
        } catch (openError) {
          // If opening fails, just inform user where file is saved
          print('PDF saved to: ${file.path}');
          print('Could not open automatically: $openError');
        }
      } catch (e) {
        print('Error saving PDF: $e');
        rethrow;
      }
    } else {
      // On mobile, use printing dialog (if supported)
      try {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
          name: fileName,
        );
      } catch (e) {
        print('Printing not supported on this platform: $e');
        rethrow;
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
  }

  String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}
