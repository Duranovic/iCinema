import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import '../../data/models/ticket_dto.dart';
import '../../data/services/reservation_api_service.dart';
import 'reservation_details_cubit.dart';
import 'reservation_details_state.dart';

class ReservationDetailsPage extends StatelessWidget {
  const ReservationDetailsPage({super.key, required this.reservationId});
  final String reservationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalji rezervacije')),
      body: BlocConsumer<ReservationDetailsCubit, ReservationDetailsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!.replaceFirst('Exception: ', ''))),
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.header == null && state.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final h = state.header;
          final canCancel = h != null && !h.isCanceled && (h.startTime == null || DateTime.now().isBefore(h.startTime!));

          return RefreshIndicator(
            onRefresh: () => context.read<ReservationDetailsCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(header: h),
                const SizedBox(height: 16),
                _TicketsList(
                  tickets: state.tickets,
                  isReservationCanceled: (h?.isCanceled ?? false),
                ),
                const SizedBox(height: 16),
                if (canCancel)
                  _CancelCard(
                    onCancel: () async {
                      // Perform cancel; remain on this page. The header/tickets update in-place.
                      await context.read<ReservationDetailsCubit>().cancel();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.header});
  final ReservationHeader? header;

  @override
  Widget build(BuildContext context) {
    final h = header;
    if (h == null) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (h.posterUrl != null && h.posterUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(h.posterUrl!, width: 80, height: 110, fit: BoxFit.cover),
          )
        else
          Container(
            width: 80,
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.movie, size: 28),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(h.movieTitle ?? 'Rezervacija', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              if (h.cinemaName != null || h.hallName != null)
                Text('${h.cinemaName ?? ''}${(h.cinemaName != null && h.hallName != null) ? ' • ' : ''}${h.hallName ?? ''}'),
              const SizedBox(height: 4),
              if (h.startTime != null)
                Text(_fmtDateTime(h.startTime!),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              if (h.totalPrice != null) Text('Ukupno: ${h.totalPrice!.toStringAsFixed(2)} KM'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketsList extends StatelessWidget {
  const _TicketsList({required this.tickets, required this.isReservationCanceled});
  final List<TicketDto> tickets;
  final bool isReservationCanceled;

  Color _statusColor(BuildContext ctx, String s) {
    switch (s) {
      case 'Used':
        return Colors.green;
      case 'Canceled':
        return Colors.redAccent;
      default:
        return Theme.of(ctx).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: const [
              Icon(Icons.confirmation_num_outlined),
              SizedBox(width: 8),
              Expanded(child: Text('Nema karata za ovu rezervaciju.')),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Karte', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final t in tickets)
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openTicketSheet(context, t, forceDisabled: isReservationCanceled),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.qr_code_2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Red ${t.rowNumber}, Sjedište ${t.seatNumber}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Status: ${isReservationCanceled ? 'Canceled' : t.ticketStatus}'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(context, isReservationCanceled ? 'Canceled' : t.ticketStatus).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isReservationCanceled ? 'Canceled' : t.ticketStatus,
                        style: TextStyle(color: _statusColor(context, isReservationCanceled ? 'Canceled' : t.ticketStatus)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CancelCard extends StatelessWidget {
  const _CancelCard({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Otkazivanje'),
            const SizedBox(height: 8),
            const Text('Otkazivanje će poništiti CIJELU rezervaciju i sve karte. Sjedišta će postati slobodna.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Theme.of(ctx).colorScheme.error),
                        const SizedBox(width: 8),
                        const Text('Potvrda otkazivanja'),
                      ],
                    ),
                    content: const Text('Da li ste sigurni da želite otkazati CIJELU rezervaciju? Sve karte će biti poništene i više neće važiti.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Ne'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(ctx).colorScheme.error,
                          foregroundColor: Theme.of(ctx).colorScheme.onError,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Da, otkaži'),
                      ),
                    ],
                  ),
                );
                if (ok == true) onCancel();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Otkaži rezervaciju (sve karte)'),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  final d = dt.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}. u ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

Future<void> _openTicketSheet(BuildContext context, TicketDto ticket, {bool forceDisabled = false}) async {
  final brightness = ScreenBrightness();
  double? prev;
  try {
    prev = await brightness.current;
  } catch (_) {}

  // Pojačaj svjetlinu ekrana na maksimum za skeniranje
  if (!forceDisabled) {
    try {
      await brightness.setScreenBrightness(1.0);
    } catch (_) {}
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return _TicketSheet(ticket: ticket, forceDisabled: forceDisabled || ticket.ticketStatus == 'Canceled');
    },
  );

  // Vrati prethodnu svjetlinu
  if (prev != null) {
    try {
      await brightness.setScreenBrightness(prev);
    } catch (_) {}
  }
}

class _TicketSheet extends StatefulWidget {
  const _TicketSheet({required this.ticket, this.forceDisabled = false});
  final TicketDto ticket;
  final bool forceDisabled;

  @override
  State<_TicketSheet> createState() => _TicketSheetState();
}

class _TicketSheetState extends State<_TicketSheet> {
  DateTime? _expiresAt;
  bool _loading = false;
  String? _error;
  Timer? _ticker;

  Future<void> _loadExpiry() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = GetIt.I<ReservationApiService>();
      final qr = await api.getTicketQr(widget.ticket.ticketId);
      setState(() {
        _expiresAt = qr.expiresAt;
      });
      _startTicker();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    if (_expiresAt == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
        _ticker?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final canShowQr = !widget.forceDisabled && t.qrCode != null && t.qrCode!.isNotEmpty && t.ticketStatus == 'Active';
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.92,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text('Karta', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (canShowQr)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: t.qrCode!,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              )
            else
              Container(
                width: 220,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('QR nije dostupan'),
              ),
            const SizedBox(height: 12),
            Text('Red ${t.rowNumber}, Sjedište ${t.seatNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Status: ${widget.forceDisabled ? 'Canceled' : t.ticketStatus}'),
            const SizedBox(height: 12),
            if (t.qrCode != null && t.qrCode!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Kod', style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          t.qrCode!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Kopiraj kod',
                      onPressed: () => _copyQr(context, t.qrCode!),
                      icon: const Icon(Icons.copy_all_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              Text(_error!.replaceFirst('Exception: ', ''), style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (!widget.forceDisabled)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 180),
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _loadExpiry,
                      icon: const Icon(Icons.timer_outlined),
                      label: Text(
                        _expiresAt == null ? 'Prikaži važenje' : 'Važi do: ${_fmtDateTime(_expiresAt!)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            if (_expiresAt != null && !widget.forceDisabled) ...[
              const SizedBox(height: 8),
              _RemainingChip(expiresAt: _expiresAt!),
            ],
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Gotovo'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyQr(BuildContext context, String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod je kopiran.')));
  }
}

String _remainingText(DateTime expiresAt) {
  final now = DateTime.now();
  if (!expiresAt.isAfter(now)) return 'Isteklo';
  final diff = expiresAt.difference(now);
  final days = diff.inDays;
  final hours = diff.inHours % 24;
  final mins = diff.inMinutes % 60;
  final secs = diff.inSeconds % 60;
  final parts = <String>[];
  if (days > 0) parts.add('${days}d');
  if (hours > 0) parts.add('${hours}h');
  if (mins > 0) parts.add('${mins}m');
  if (parts.isEmpty) parts.add('${secs}s');
  return 'Važi još: ${parts.join(' ')}';
}

class _RemainingChip extends StatelessWidget {
  const _RemainingChip({required this.expiresAt});
  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expired = !expiresAt.isAfter(now);
    final remaining = expiresAt.difference(now);
    final urgent = !expired && remaining.inMinutes < 5;

    final scheme = Theme.of(context).colorScheme;
    final warn = !expired && !urgent && remaining.inMinutes < 10;
    final bg = expired
        ? scheme.surfaceContainerHighest
        : (urgent
            ? scheme.errorContainer
            : (warn ? scheme.tertiaryContainer : scheme.primaryContainer));
    final fg = expired
        ? scheme.onSurfaceVariant
        : (urgent
            ? scheme.onErrorContainer
            : (warn ? scheme.onTertiaryContainer : scheme.onPrimaryContainer));

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 18, color: fg),
          const SizedBox(width: 6),
          Text(
            expired ? 'Isteklo' : _remainingText(expiresAt),
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
