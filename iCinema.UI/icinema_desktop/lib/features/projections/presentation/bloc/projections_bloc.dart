import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_desktop/features/projections/data/projection_service.dart';
import 'package:icinema_desktop/features/projections/data/cinema_service.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_event.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_state.dart';
import 'package:icinema_desktop/features/projections/domain/projection.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProjectionsBloc extends Bloc<ProjectionsEvent, ProjectionsState> {
  final ProjectionService projectionService;
  final CinemaService cinemaService;

  // simple in-memory cache keyed by yyyy-MM-cinemaId (or yyyy-MM-all for all cinemas)
  final Map<String, List<Projection>> _cache = {};
  String? _latestRequestKey;
  
  // cinema state
  List<Cinema> _availableCinemas = [];
  Cinema? _selectedCinema;

  ProjectionsBloc(this.projectionService, this.cinemaService) : super(ProjectionsInitial()) {
    on<LoadCinemas>((event, emit) async {
      try {
        _availableCinemas = await cinemaService.fetchCinemas();
        // Re-emit current state with updated cinemas
        if (state is ProjectionsLoaded) {
          final current = state as ProjectionsLoaded;
          emit(ProjectionsLoaded(current.projections, current.month, 
              availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
        } else if (state is ProjectionsError) {
          final current = state as ProjectionsError;
          emit(ProjectionsError(current.message, current.month, 
              availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
        }
      } catch (e) {
        // Keep current state, just log error for cinemas
        print('Error loading cinemas: $e');
      }
    });

    on<SelectCinema>((event, emit) async {
      _selectedCinema = event.cinema;
      _cache.clear(); // Clear cache when cinema selection changes
      
      // Reload current month with new cinema filter
      if (state is ProjectionsLoaded) {
        final current = state as ProjectionsLoaded;
        add(LoadProjectionsForMonth(current.month));
      } else if (state is ProjectionsError) {
        final current = state as ProjectionsError;
        add(LoadProjectionsForMonth(current.month));
      }
    });

    on<LoadProjectionsForMonth>((event, emit) async {
      final month = DateTime(event.month.year, event.month.month, 1);
      final key = _keyFor(month);
      _latestRequestKey = key;

      // if cached, show immediately
      if (_cache.containsKey(key)) {
        emit(ProjectionsLoaded(List<Projection>.from(_cache[key]!), month,
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      } else {
        emit(ProjectionsLoading(month, 
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      }

      try {
        final projections = await projectionService.fetchProjections(
            date: month, disablePaging: true, cinemaId: _selectedCinema?.id);
        // Guard against stale responses
        if (_latestRequestKey != key) return;
        _cache[key] = projections;
        emit(ProjectionsLoaded(projections, month,
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      } catch (e) {
        // Guard against stale errors
        if (_latestRequestKey != key) return;
        emit(ProjectionsError('Error fetching projections', month,
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      }
    });

    on<AddProjection>((event, emit) async {
      final currentMonth = _currentMonthFromState();
      if (currentMonth == null) return;
      emit(ProjectionsLoading(currentMonth, 
          availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      try {
        await projectionService.addProjection(event.projection);
        _invalidateMonth(currentMonth);
        add(LoadProjectionsForMonth(currentMonth)); // reload after add
      } catch (e) {
        emit(ProjectionsError('Error adding projection', currentMonth,
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      }
    });

    on<UpdateProjection>((event, emit) async {
      final currentMonth = _currentMonthFromState();
      if (currentMonth == null) return;
      emit(ProjectionsLoading(currentMonth, 
          availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      try {
        await projectionService.updateProjection(event.projection);
        _invalidateMonth(currentMonth);
        add(LoadProjectionsForMonth(currentMonth));
      } catch (e) {
        emit(ProjectionsError('Error updating projection', currentMonth,
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      }
    });

    on<DeleteProjection>((event, emit) async {
      // Proceed only if Projections are loaded; otherwise, ignore the delete.
      final currentMonth = _currentMonthFromState();
      if (currentMonth == null) return;

      // Validate ID before showing loading state to avoid flicker on invalid input.
      final id = event.id;
      if (id == null || id.isEmpty) {
        emit(ProjectionsError('No projection id provided', currentMonth));
        return;
      }

      emit(ProjectionsLoading(currentMonth, 
          availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      try {
        await projectionService.deleteProjection(id);
        // Reload the Projections after successful deletion.
        _invalidateMonth(currentMonth);
        add(LoadProjectionsForMonth(currentMonth));
      } catch (e) {
        emit(ProjectionsError('Error deleting projection', currentMonth,
            availableCinemas: _availableCinemas, selectedCinema: _selectedCinema));
      }
    });
  }

  String _keyFor(DateTime month) {
    final monthKey = '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
    final cinemaKey = _selectedCinema?.id ?? 'all';
    return '$monthKey-$cinemaKey';
  }

  DateTime? _currentMonthFromState() {
    if (state is ProjectionsLoaded) return (state as ProjectionsLoaded).month;
    if (state is ProjectionsLoading) return (state as ProjectionsLoading).month;
    if (state is ProjectionsError) return (state as ProjectionsError).month;
    return null;
  }

  void _invalidateMonth(DateTime month) {
    _cache.remove(_keyFor(month));
  }
}
