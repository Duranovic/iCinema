import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/di/injection.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/seat_map.dart';
import '../bloc/seat_map_cubit.dart';
import '../bloc/seat_map_state.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key, required this.projectionId});
  final String projectionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervacija'),
      ),
      body: BlocConsumer<SeatMapCubit, SeatMapState>(
        listenWhen: (p, c) => p.successMessage != c.successMessage || p.error != c.error,
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!.replaceFirst('Exception: ', ''))),
            );
          }
          final navId = state.lastReservationId;
          if (navId != null && navId.isNotEmpty) {
            context.push('/reservations/${Uri.encodeComponent(navId)}');
            context.read<SeatMapCubit>().acknowledgeNavigationHandled();
          }
        },
        builder: (context, state) {
          final isAuthed = getIt<AuthService>().authState.isAuthenticated;
          if (state.loading && state.map == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final map = state.map;
          if (map == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nema podataka za odabranu projekciju.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<SeatMapCubit>().loadMap(),
                    child: const Text('Pokušaj ponovo'),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SeatMapCubit>().loadMap(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(projection: map.projection),
                const SizedBox(height: 16),
                _SeatGrid(hall: map.hall, seats: map.seats, selected: state.selectedSeatIds),
                const SizedBox(height: 12),
                _Legend(),
                if (!isAuthed) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Morate biti prijavljeni da biste napravili rezervaciju.'),
                          ),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            child: const Text('Prijava'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _Summary(
                  selectedCount: state.selectedSeatIds.length,
                  totalPrice: state.totalPrice,
                  reserving: state.reserving,
                  onReserve: (state.selectedSeatIds.isEmpty || !isAuthed)
                      ? null
                      : () => context.read<SeatMapCubit>().reserve(),
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
  const _Header({required this.projection});
  final ProjectionInfo projection;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (projection.posterUrl != null && projection.posterUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              projection.posterUrl!,
              width: 72,
              height: 100,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 72,
            height: 100,
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
              Text(projection.movieTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 6),
              Text('${projection.cinemaName} • ${projection.hallName}'),
              const SizedBox(height: 4),
              Text(_fmtDateTime(projection.startTime),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text('Cijena: ${projection.price.toStringAsFixed(2)} KM'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeatGrid extends StatelessWidget {
  const _SeatGrid({required this.hall, required this.seats, required this.selected});
  final HallInfo hall;
  final List<SeatInfo> seats;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final byKey = {for (final s in seats) '${s.rowNumber}-${s.seatNumber}': s};
    final rows = List.generate(hall.rowsCount, (i) => i + 1);
    final cols = List.generate(hall.seatsPerRow, (i) => i + 1);
    final cubit = context.read<SeatMapCubit>();

    const double dotSize = 22.0;
    const double hPad = 6.0; // same as before
    const double vPad = 6.0;

    final grid = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('Platno', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        for (final r in rows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: vPad),
            child: Wrap(
              spacing: hPad * 2,
              runSpacing: 0,
              children: [
                for (final c in cols)
                  _SeatDot(
                    seat: byKey['$r-$c'],
                    selected: byKey['$r-$c'] != null && selected.contains(byKey['$r-$c']!.seatId),
                    onTap: (seat) => cubit.toggleSeat(seat.seatId, isTaken: seat.isTaken),
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridWidth = cols.length * (dotSize + hPad * 2);
        final double containerWidth = gridWidth > constraints.maxWidth
            ? gridWidth
            : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: containerWidth,
            child: Align(
              alignment: Alignment.center,
              child: grid,
            ),
          ),
        );
      },
    );
  }
}

class _SeatDot extends StatelessWidget {
  const _SeatDot({required this.seat, required this.selected, required this.onTap});
  final SeatInfo? seat; // null = rupa (nema sjedala)
  final bool selected;
  final void Function(SeatInfo seat) onTap;

  @override
  Widget build(BuildContext context) {
    if (seat == null) {
      return const SizedBox(width: 22, height: 22);
    }
    final s = seat!;
    Color bg;
    if (s.isTaken) {
      bg = Colors.redAccent;
    } else if (selected) {
      bg = Theme.of(context).colorScheme.primary;
    } else {
      bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    }
    final fg = Theme.of(context).colorScheme.onPrimary;
    return InkWell(
      onTap: s.isTaken ? null : () => onTap(s),
      customBorder: const CircleBorder(),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Text(
          s.seatNumber.toString(),
          style: TextStyle(
            fontSize: 10,
            color: s.isTaken ? Colors.white : (selected ? fg : Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(text),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          item(Theme.of(context).colorScheme.surfaceContainerHighest, 'Slobodno'),
          item(Theme.of(context).colorScheme.primary, 'Tvoj odabir'),
          item(Colors.redAccent, 'Zauzeto'),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.selectedCount, required this.totalPrice, required this.reserving, required this.onReserve});
  final int selectedCount;
  final double totalPrice;
  final bool reserving;
  final VoidCallback? onReserve;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odabrano: $selectedCount sjedila'),
            const SizedBox(height: 4),
            Text('Ukupno: ${totalPrice.toStringAsFixed(2)} KM', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: reserving ? null : onReserve,
                child: reserving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Rezerviši kartu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  final d = dt.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$dd.$mm.$yyyy u $hh:$min';
}
