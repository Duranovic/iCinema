import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_bloc.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_event.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_state.dart';

class CinemaSelector extends StatelessWidget {
  const CinemaSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocBuilder<ProjectionsBloc, ProjectionsState>(
      builder: (context, state) {
        final availableCinemas = _getAvailableCinemas(state);
        final selectedCinema = _getSelectedCinema(state);
        
        // Always show the cinema selector, even if cinemas are loading or failed to load
        if (availableCinemas.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Kino:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Učitavanje kina...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          );
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Kino:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Cinema?>(
                    value: selectedCinema,
                    hint: Text(
                      'Sva kina',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    items: [
                      // "All Cinemas" option
                      DropdownMenuItem<Cinema?>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.select_all_rounded,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sva kina',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: selectedCinema == null ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Individual cinema options
                      ...availableCinemas.map((cinema) => DropdownMenuItem<Cinema?>(
                        value: cinema,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cinema.name,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: selectedCinema?.id == cinema.id ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    cinema.displayLocation,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    onChanged: (Cinema? newCinema) {
                      context.read<ProjectionsBloc>().add(SelectCinema(newCinema));
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  List<Cinema> _getAvailableCinemas(ProjectionsState state) {
    if (state is ProjectionsLoaded) return state.availableCinemas;
    if (state is ProjectionsLoading) return state.availableCinemas;
    if (state is ProjectionsError) return state.availableCinemas;
    return [];
  }
  
  Cinema? _getSelectedCinema(ProjectionsState state) {
    if (state is ProjectionsLoaded) return state.selectedCinema;
    if (state is ProjectionsLoading) return state.selectedCinema;
    if (state is ProjectionsError) return state.selectedCinema;
    return null;
  }
}
