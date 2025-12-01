import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projections/domain/cinema.dart';
import '../../../projections/domain/hall.dart';
import '../bloc/cinemas_bloc.dart';
import '../bloc/cinemas_event.dart';
import 'hall_form_modal.dart';
import 'cinema_form_dialog.dart';

class CinemaDetailView extends StatelessWidget {
  final Cinema cinema;

  const CinemaDetailView({
    super.key,
    required this.cinema,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // Header with cinema info and actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<CinemasBloc>().add(ClearSelection());
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cinema.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cinema.displayLocation,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showEditCinemaDialog(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Uredi'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteCinemaDialog(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Obriši'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'Adresa',
                      value: cinema.address,
                    ),
                    const SizedBox(width: 16),
                    if (cinema.email != null && cinema.email!.isNotEmpty)
                      _InfoCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: cinema.email!,
                      ),
                    const SizedBox(width: 16),
                    if (cinema.phoneNumber != null && cinema.phoneNumber!.isNotEmpty)
                      _InfoCard(
                        icon: Icons.phone_outlined,
                        title: 'Telefon',
                        value: cinema.phoneNumber!,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Halls section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sale (${cinema.halls.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddHallDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Dodaj salu'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: cinema.halls.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.meeting_room_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nema dodanih sala',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dodajte prvu salu za ovo kino',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 300,
                              childAspectRatio: 1.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: cinema.halls.length,
                            itemBuilder: (context, index) {
                              final hall = cinema.halls[index];
                              return _HallCard(
                                hall: hall,
                                onEdit: () => _showEditHallDialog(context, hall),
                                onDelete: () => _showDeleteHallDialog(context, hall),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCinemaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CinemasBloc>(),
        child: CinemaFormDialog(cinema: cinema),
      ),
    );
  }

  void _showDeleteCinemaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Potvrdi brisanje'),
        content: Text('Da li ste sigurni da želite obrisati kino "${cinema.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CinemasBloc>().add(DeleteCinema(cinema.id!));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
  }

  void _showAddHallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CinemasBloc>(),
        child: HallFormModal(
          cinemaId: cinema.id!,
          cinemaName: cinema.name,
        ),
      ),
    );
  }

  void _showEditHallDialog(BuildContext context, Hall hall) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CinemasBloc>(),
        child: HallFormModal(
          cinemaId: cinema.id!,
          hall: hall,
          cinemaName: cinema.name,
        ),
      ),
    );
  }

  void _showDeleteHallDialog(BuildContext context, Hall hall) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Potvrdi brisanje sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Da li ste sigurni da želite obrisati salu "${hall.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalji sale:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('• Kapacitet: ${hall.capacity} mjesta'),
                  Text('• Raspored: ${hall.rowsCount} redova × ${hall.seatsPerRow} sjedišta'),
                  if (hall.hallType.isNotEmpty) Text('• Tip: ${hall.hallType}'),
                  if (hall.isDolbyAtmos) const Text('• Dolby Atmos'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ova akcija se ne može poništiti.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CinemasBloc>().add(DeleteHall(
                cinemaId: cinema.id!,
                hallId: hall.id!,
              ));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Obriši salu'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HallCard extends StatelessWidget {
  final Hall hall;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HallCard({
    required this.hall,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hall.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Uredi'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text('Obriši'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.event_seat,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${hall.capacity} mjesta',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.grid_view,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${hall.rowsCount}×${hall.seatsPerRow}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (hall.hallType.isNotEmpty || hall.screenSize.isNotEmpty || hall.isDolbyAtmos)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (hall.hallType.isNotEmpty)
                    _FeatureChip(label: hall.hallType),
                  if (hall.screenSize.isNotEmpty)
                    _FeatureChip(label: hall.screenSize),
                  if (hall.isDolbyAtmos)
                    _FeatureChip(label: 'Dolby Atmos'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 10,
        ),
      ),
    );
  }
}
