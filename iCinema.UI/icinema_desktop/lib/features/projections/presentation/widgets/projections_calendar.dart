import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_desktop/features/projections/domain/projection.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';
import 'package:icinema_desktop/features/projections/domain/hall.dart';
import 'package:icinema_desktop/features/movies/domain/movie.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_bloc.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';
import 'dart:math' as math;
import 'package:icinema_desktop/app/utils/bs_calendar_labels.dart';
import 'package:icinema_desktop/app/utils/date_gates.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_state.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_event.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_state.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_event.dart';

class ProjectionsCalendar extends StatefulWidget {
  const ProjectionsCalendar({super.key});

  @override
  State<ProjectionsCalendar> createState() => _ProjectionsCalendarState();
}

class _ProjectionsCalendarState extends State<ProjectionsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // UI-only cache of events for current visible month, derived from Bloc state
  SplayTreeMap<DateTime, List<Projection>> _groupedEvents = SplayTreeMap<DateTime, List<Projection>>(
    (a, b) => DateUtils.dateOnly(a).compareTo(DateUtils.dateOnly(b)),
  );

  @override
  void initState() {
    super.initState();
  }

  List<Projection> _eventsForDay(DateTime day) => _groupedEvents[DateUtils.dateOnly(day)] ?? const [];

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  // past/tomorrow rules moved to utils/date_gates.dart

  Future<void> _openListSheet(DateTime day) async {
    final projections = _eventsForDay(day);
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 24, right: 24, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Projekcije",
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatBsMediumDate(day),
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content
              if (projections.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Nema zakazanih projekcija",
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Dodajte prvu projekciju za ovaj dan",
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...projections.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _getEventColor(p, colorScheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getEventColor(p, colorScheme).withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getEventColor(p, colorScheme).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_movies_rounded,
                        color: _getEventColor(p, colorScheme),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      p.movieTitle,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.time.format(ctx),
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.meeting_room_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.hall,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Navigator.pop(ctx); // Close current modal
                      // Use WidgetsBinding to schedule the edit modal after the frame
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _showEditProjectionModal(context, p);
                        }
                      });
                    },
                  ),
                )),

              const SizedBox(height: 16),

              // Action button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBeforeTomorrow(day)
                      ? null
                      : () {
                          // Close this list sheet, then open the create sheet
                          Navigator.pop(ctx);
                          Future.microtask(() => _openCreateSheet(day));
                        },
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text("Dodaj projekciju"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateSheet(DateTime day) async {
    TimeOfDay selected = const TimeOfDay(hour: 20, minute: 0);
    String hall = "Dvorana 1";
    final colorScheme = Theme.of(context).colorScheme;
    final priceController = TextEditingController(text: "10.00"); // Default price
    
    // Get current state for cinema and hall selection
    final currentState = context.read<ProjectionsBloc>().state;
    Cinema? selectedCinema;
    Hall? selectedHall;
    List<Cinema> availableCinemas = [];
    List<Hall> availableHalls = [];
    
    // Preselect cinema from current filter if available
    if (currentState is ProjectionsLoaded) {
      availableCinemas = currentState.availableCinemas;
      selectedCinema = currentState.selectedCinema;
      if (selectedCinema != null) {
        availableHalls = selectedCinema.halls;
        if (availableHalls.isNotEmpty) {
          selectedHall = availableHalls.first;
          hall = selectedHall.name;
        }
      }
    } else if (currentState is ProjectionsError) {
      availableCinemas = currentState.availableCinemas;
      selectedCinema = currentState.selectedCinema;
      if (selectedCinema != null) {
        availableHalls = selectedCinema.halls;
        if (availableHalls.isNotEmpty) {
          selectedHall = availableHalls.first;
          hall = selectedHall.name;
        }
      }
    }

    // Get MoviesBloc instance to pass to modal
    final moviesBloc = context.read<MoviesBloc>();
    
    // Declare selectedMovie outside StatefulBuilder to persist selection
    Movie? selectedMovie;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider<MoviesBloc>.value(
        value: moviesBloc,
        child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 24, right: 24, top: 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              
              return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nova projekcija",
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatBsMediumDate(day),
                            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Movie selection dropdown with BlocBuilder
                BlocBuilder<MoviesBloc, MoviesState>(
                  builder: (context, moviesState) {
                    
                    if (moviesState is MoviesError) {
                      return DropdownButtonFormField<Movie?>(
                        value: null,
                        items: [DropdownMenuItem<Movie?>(
                          value: null,
                          child: Text("Greška: ${moviesState.message}"),
                        )],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: "Film",
                          prefixIcon: const Icon(Icons.error_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.errorContainer.withOpacity(0.3),
                        ),
                      );
                    } else if (moviesState is MoviesLoading || moviesState is MoviesInitial) {
                      return DropdownButtonFormField<Movie?>(
                        value: null,
                        items: [const DropdownMenuItem<Movie?>(
                          value: null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text("Učitavanje filmova..."),
                            ],
                          ),
                        )],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: "Film",
                          prefixIcon: const Icon(Icons.movie_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                      );
                    } else if (moviesState is MoviesLoaded) {
                      final movies = moviesState.movies;
                      return DropdownButtonFormField<Movie?>(
                        value: selectedMovie,
                        items: [
                          const DropdownMenuItem<Movie?>(
                            value: null,
                            child: Text("Odaberite film"),
                          ),
                          ...movies.map((movie) => DropdownMenuItem<Movie?>(
                            value: movie,
                            child: Text(
                              movie.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ],
                        onChanged: (Movie? movie) {
                          setSheetState(() {
                            selectedMovie = movie;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Film",
                          prefixIcon: const Icon(Icons.movie_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                      );
                    } else {
                      return DropdownButtonFormField<Movie?>(
                        value: null,
                        items: [const DropdownMenuItem<Movie?>(
                          value: null,
                          child: Text("Filmovi nisu dostupni"),
                        )],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: "Film",
                          prefixIcon: const Icon(Icons.movie_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Price input field
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Cijena (KM)",
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Molimo unesite cijenu';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'Molimo unesite validnu cijenu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cinema selection dropdown
                DropdownButtonFormField<Cinema?>(
                  value: selectedCinema,
                  items: [
                    // "All cinemas" option - only show if no cinema is preselected
                    if (selectedCinema == null)
                      const DropdownMenuItem<Cinema?>(
                        value: null,
                        child: Text("Odaberite kino"),
                      ),
                    // Individual cinema options
                    ...availableCinemas.map((cinema) => DropdownMenuItem<Cinema?>(
                      value: cinema,
                      child: Text('${cinema.name} - ${cinema.displayLocation}'),
                    )),
                  ],
                  onChanged: (Cinema? cinema) {
                    setSheetState(() {
                      selectedCinema = cinema;
                      availableHalls = cinema?.halls ?? [];
                      selectedHall = null;
                      hall = availableHalls.isNotEmpty ? availableHalls.first.name : "Dvorana 1";
                      if (availableHalls.isNotEmpty) {
                        selectedHall = availableHalls.first;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Kino",
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),

                // Hall selection dropdown (full width)
                DropdownButtonFormField<Hall?>(
                  value: selectedHall,
                  items: availableHalls.isEmpty
                      ? [const DropdownMenuItem<Hall?>(
                          value: null,
                          child: Text("Odaberite kino prvo"),
                        )]
                      : availableHalls.map((hall) => DropdownMenuItem<Hall?>(
                          value: hall,
                          child: Text(
                            hall.displayInfo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                  onChanged: availableHalls.isEmpty 
                      ? null 
                      : (Hall? selectedHallValue) {
                          setSheetState(() {
                            selectedHall = selectedHallValue;
                            hall = selectedHallValue?.name ?? "Dvorana 1";
                          });
                        },
                  decoration: InputDecoration(
                    labelText: "Dvorana",
                    prefixIcon: const Icon(Icons.meeting_room_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),

                // Time selection (full width)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime: selected,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (t != null) setSheetState(() => selected = t);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selected.format(ctx),
                              style: Theme.of(ctx).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Otkaži"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          // Validation: require movie, cinema, hall and price
                          if (selectedMovie == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Molimo odaberite film')),
                            );
                            return;
                          }
                          if (selectedCinema == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Molimo odaberite kino')),
                            );
                            return;
                          }
                          if (selectedHall == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Molimo odaberite dvoranu')),
                            );
                            return;
                          }
                          
                          // Validate price
                          final priceText = priceController.text.trim();
                          if (priceText.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Molimo unesite cijenu')),
                            );
                            return;
                          }
                          final price = double.tryParse(priceText);
                          if (price == null || price <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Molimo unesite validnu cijenu')),
                            );
                            return;
                          }

                          final projection = Projection(
                            movieTitle: selectedMovie!.title,
                            hall: selectedHall!.name,
                            time: selected,
                            date: DateUtils.dateOnly(day),
                            price: price,
                            cinemaId: selectedCinema!.id,
                            hallId: selectedHall!.id,
                            movieId: selectedMovie!.id,
                            isActive: true, // Set as active by default as requested
                          );
                          context.read<ProjectionsBloc>().add(AddProjection(projection));
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text("Sačuvaj projekciju"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
            },
          ),
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<ProjectionsBloc, ProjectionsState>(
      listenWhen: (prev, curr) => curr is ProjectionsLoaded || curr is ProjectionsLoading || curr is ProjectionsError,
      listener: (context, state) {
        if (state is ProjectionsLoaded) {
          // regroup events by date for current month
          final map = SplayTreeMap<DateTime, List<Projection>>(
            (a, b) => DateUtils.dateOnly(a).compareTo(DateUtils.dateOnly(b)),
          );
          for (final p in state.projections) {
            final day = DateUtils.dateOnly(p.date);
            map.putIfAbsent(day, () => []).add(p);
          }
          setState(() => _groupedEvents = map);
        }
      },
      builder: (context, state) {
        final isLoadingForFocusedMonth = state is ProjectionsLoading && DateUtils.isSameDay(
          DateUtils.dateOnly(DateTime(state.month.year, state.month.month, 1)),
          DateUtils.dateOnly(DateTime(_focusedDay.year, _focusedDay.month, 1)),
        );
        final isErrorForFocusedMonth = state is ProjectionsError && DateUtils.isSameDay(
          DateUtils.dateOnly(DateTime(state.month.year, state.month.month, 1)),
          DateUtils.dateOnly(DateTime(_focusedDay.year, _focusedDay.month, 1)),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive row height based on available space
            // Account for header, days of week, and 5-6 weeks of calendar
            final availableHeight = constraints.maxHeight;
            final headerHeight = 60.0; // Approximate header height
            final daysOfWeekHeight = 32.0;
            final remainingHeight = availableHeight - headerHeight - daysOfWeekHeight;
            final numberOfWeeks = 6; // Maximum weeks in a month view
            final calculatedRowHeight = (remainingHeight / numberOfWeeks).clamp(80.0, 140.0);
            
            return Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TableCalendar<Projection>(
                  firstDay: DateTime.utc(2018, 1, 1),
                  lastDay: DateTime.utc(2032, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                  eventLoader: _eventsForDay,
                  calendarFormat: CalendarFormat.month,
                  // Make row height responsive to available space
                  rowHeight: calculatedRowHeight,
                  daysOfWeekHeight: daysOfWeekHeight,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    _openListSheet(selected);
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    context.read<ProjectionsBloc>().add(LoadProjectionsForMonth(focusedDay));
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ) ?? const TextStyle(),
                    // Use Bosnian month/year while keeping default centering
                    titleTextFormatter: (date, locale) => formatBsMonthYear(date),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ) ?? const TextStyle(),
                    weekendStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ) ?? const TextStyle(),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    cellPadding: EdgeInsets.zero,
                    defaultDecoration: const BoxDecoration(),
                    weekendDecoration: const BoxDecoration(),
                    holidayDecoration: const BoxDecoration(),
                    selectedDecoration: const BoxDecoration(),
                    todayDecoration: const BoxDecoration(),
                    markerDecoration: const BoxDecoration(),
                    rowDecoration: const BoxDecoration(),
                  ),
                  calendarBuilders: CalendarBuilders(
                    // Bosnian days-of-week labels
                    dowBuilder: (ctx, day) {
                      final colorScheme = Theme.of(ctx).colorScheme;
                      final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                      return Center(
                        child: Text(
                          bsWeekdayShort(day.weekday),
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                                color: isWeekend ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    },
                    defaultBuilder: (ctx, day, focusedDay) => _buildDayCell(ctx, day, calculatedRowHeight, isWeekend: _isWeekend(day)),
                    todayBuilder: (ctx, day, _) => _buildDayCell(ctx, day, calculatedRowHeight, isToday: true, isWeekend: _isWeekend(day)),
                    selectedBuilder: (ctx, day, _) => _buildDayCell(ctx, day, calculatedRowHeight, isSelected: true, isWeekend: _isWeekend(day)),
                    outsideBuilder: (ctx, day, focusedDay) => _buildDayCell(ctx, day, calculatedRowHeight, isOutside: true, isWeekend: _isWeekend(day)),
                    markerBuilder: (ctx, day, events) => const SizedBox.shrink(), // We handle markers in _buildDayCell
                  ),
                ),
              ),
                    ),
                  ),
                  if (isLoadingForFocusedMonth)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  if (isErrorForFocusedMonth)
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 16,
                      child: Material(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Greška pri učitavanju projekcija',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.read<ProjectionsBloc>().add(LoadProjectionsForMonth(_focusedDay)),
                                child: Text('Pokušaj ponovo', style: TextStyle(color: colorScheme.onErrorContainer)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
          },
        );
      },
    );
  }

  Widget _buildDayCell(BuildContext ctx, DateTime day, double rowHeight, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
    bool isWeekend = false,
  }) {
    final events = _eventsForDay(day);
    final colorScheme = Theme.of(ctx).colorScheme;
    final textTheme = Theme.of(ctx).textTheme;

    // Determine cell colors and styling
    Color? backgroundColor;
    Color? borderColor;
    Color textColor = colorScheme.onSurface;

    if (isOutside) {
      textColor = colorScheme.onSurface.withOpacity(0.3);
      backgroundColor = colorScheme.surface.withOpacity(0.5);
    } else if (isSelected) {
      backgroundColor = colorScheme.primary.withOpacity(0.15);
      borderColor = colorScheme.primary;
      textColor = colorScheme.primary;
    } else if (isToday) {
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.3);
      borderColor = colorScheme.primary.withOpacity(0.5);
      textColor = colorScheme.onPrimaryContainer;
    } else if (isWeekend) {
      backgroundColor = colorScheme.surfaceVariant.withOpacity(0.3);
      textColor = colorScheme.primary;
    } else {
      backgroundColor = colorScheme.surface;
    }

    // Calculate max height based on row height minus margins
    final maxCellHeight = rowHeight - 4; // Account for vertical margins

    return Container(
      // Keep inner content within the TableCalendar rowHeight to avoid overflow
      constraints: BoxConstraints(
        minHeight: (rowHeight * 0.7).clamp(60.0, 100.0),
        maxHeight: maxCellHeight,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
          ? Border.all(color: borderColor, width: 2)
          : Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: events.isNotEmpty && !isOutside ? [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isOutside ? null : () {
            setState(() {
              _selectedDay = day;
              _focusedDay = day;
            });
            _openListSheet(day);
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate available space more conservatively
                final availableHeight = constraints.maxHeight - 8; // Account for padding
                final headerHeight = 24.0;
                final remainingHeight = availableHeight - headerHeight;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with day number and add button
                    SizedBox(
                      height: headerHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isToday
                                ? colorScheme.primary
                                : events.isNotEmpty && !isOutside
                                  ? colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${day.day}",
                              style: textTheme.titleSmall?.copyWith(
                                color: isToday
                                  ? colorScheme.onPrimary
                                  : events.isNotEmpty && !isOutside
                                    ? colorScheme.onPrimaryContainer
                                    : textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (!isOutside && !isBeforeTomorrow(day))
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _openCreateSheet(day),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 16,
                                    color: colorScheme.primary.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Events display - only if there's enough space
                    if (events.isNotEmpty && remainingHeight > 20)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: math.min(events.length, math.max(1, (remainingHeight / 16).floor())),
                            itemBuilder: (context, index) {
                              if (index < events.length && index < 2) {
                                final event = events[index];
                                return GestureDetector(
                                  onTap: () => _showEditProjectionModal(context, event),
                                  child: Container(
                                    height: 14,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _getEventColor(event, colorScheme).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 5,
                                          color: _getEventColor(event, colorScheme),
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            '${event.movieTitle} ${event.time.format(ctx)}',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: _getEventColor(event, colorScheme),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 8,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (events.length > 2) {
                                // Show "more" indicator - clickable to show all projections
                                return GestureDetector(
                                  onTap: () => _showAllProjectionsModal(context, events, day),
                                  child: Container(
                                    height: 12,
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "+${events.length - 2}",
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 7,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      )
                    else if (events.isNotEmpty)
                      // Just show a dot indicator if no space for events
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _getEventColor(Projection event, ColorScheme colorScheme) {
    // Generate consistent colors based on hall name
    final hash = event.hall.hashCode;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];
    return colors[hash.abs() % colors.length];
  }

  void _showAllProjectionsModal(BuildContext context, List<Projection> projections, DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<MoviesBloc>()),
          BlocProvider.value(value: context.read<ProjectionsBloc>()),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (sheetContext, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Projekcije - ${day.day}.${day.month}.${day.year}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Projections list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: projections.length,
                    itemBuilder: (listContext, index) {
                      final projection = projections[index];
                      final colorScheme = Theme.of(listContext).colorScheme;
                      final textTheme = Theme.of(listContext).textTheme;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(listContext).pop(); // Close current modal
                              // Use WidgetsBinding to schedule the edit modal after the frame
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _showEditProjectionModal(this.context, projection);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            splashColor: _getEventColor(projection, colorScheme).withOpacity(0.1),
                            highlightColor: _getEventColor(projection, colorScheme).withOpacity(0.05),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getEventColor(projection, colorScheme).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getEventColor(projection, colorScheme).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                              children: [
                                // Color indicator
                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getEventColor(projection, colorScheme),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Projection details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        projection.movieTitle,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            projection.time.format(context),
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.meeting_room_rounded,
                                            size: 16,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            projection.hall,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Price and edit indicator
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${projection.price.toStringAsFixed(2)} KM',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _getEventColor(projection, colorScheme),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProjectionModal(BuildContext context, Projection projection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<MoviesBloc>()),
          BlocProvider.value(value: context.read<ProjectionsBloc>()),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Uredi projekciju',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _ProjectionEditForm(projection: projection),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectionEditForm extends StatefulWidget {
  final Projection projection;

  const _ProjectionEditForm({required this.projection});

  @override
  State<_ProjectionEditForm> createState() => _ProjectionEditFormState();
}

class _ProjectionEditFormState extends State<_ProjectionEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;
  String? _selectedMovieId;
  String? _selectedHallId;

  @override
  void initState() {
    super.initState();
    // Prepopulate form with existing projection data
    _priceController = TextEditingController(text: widget.projection.price.toString());
    _selectedTime = widget.projection.time;
    _selectedDate = widget.projection.date;
    _selectedMovieId = widget.projection.movieId;
    _selectedHallId = widget.projection.hallId;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Movie Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.movie_rounded, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Film',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlocBuilder<MoviesBloc, MoviesState>(
                  builder: (context, state) {
                    if (state is MoviesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (state is MoviesError) {
                      return Text('Greška: ${state.message}');
                    }
                    
                    if (state is MoviesLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _selectedMovieId,
                        decoration: InputDecoration(
                          hintText: 'Odaberite film',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: state.movies.map((movie) {
                          return DropdownMenuItem<String>(
                            value: movie.id,
                            child: Text(movie.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMovieId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo odaberite film';
                          }
                          return null;
                        },
                      );
                    }
                    
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hall Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.meeting_room_rounded, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Sala',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlocBuilder<ProjectionsBloc, ProjectionsState>(
                  builder: (context, state) {
                    // Find the cinema that owns this projection using cinemaId
                    Cinema? projectionCinema;
                    final availableCinemas = state is ProjectionsLoaded 
                        ? state.availableCinemas
                        : state is ProjectionsLoading
                        ? state.availableCinemas
                        : <Cinema>[];
                    
                    if (widget.projection.cinemaId != null && availableCinemas.isNotEmpty) {
                      try {
                        projectionCinema = availableCinemas.firstWhere(
                          (cinema) => cinema.id == widget.projection.cinemaId,
                        );
                      } catch (e) {
                        // Cinema not found, will fall back to current selection or empty
                      }
                    }
                    
                    // Get halls from the projection's cinema, fallback to selected cinema, then empty
                    final halls = projectionCinema?.halls ?? 
                                 (state is ProjectionsLoaded ? state.selectedCinema?.halls ?? [] :
                                  state is ProjectionsLoading ? state.selectedCinema?.halls ?? [] : <Hall>[]);
                    
                    if (halls.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.meeting_room_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              widget.projection.hall,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedHallId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        prefixIcon: Icon(Icons.meeting_room_rounded, color: colorScheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: halls.map((hall) {
                        return DropdownMenuItem<String>(
                          value: hall.id,
                          child: Text(
                            hall.displayInfo,
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHallId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Molimo odaberite salu';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Date and Time Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Datum i vrijeme',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              _selectedTime = time;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime.format(context),
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money_rounded, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Cijena',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Unesite cijenu',
                    suffixText: 'KM',
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo unesite cijenu';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Molimo unesite validnu cijenu';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Column(
            children: [
              // Delete Button (separate row for emphasis)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showDeleteConfirmation,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                  icon: Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text('Obriši projekciju'),
                ),
              ),
              const SizedBox(height: 12),
              // Cancel and Update buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Otkaži'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProjection,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ažuriraj'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateProjection() {
    if (_formKey.currentState!.validate()) {
      final selectedMovie = context.read<MoviesBloc>().state;
      final projectionsState = context.read<ProjectionsBloc>().state;
      
      if (selectedMovie is MoviesLoaded) {
        final movie = selectedMovie.movies.firstWhere((m) => m.id == _selectedMovieId);
        
        // Get the selected hall from the cinema's halls
        String hallName = widget.projection.hall; // Default fallback
        final halls = projectionsState is ProjectionsLoaded 
            ? projectionsState.selectedCinema?.halls ?? []
            : projectionsState is ProjectionsLoading
            ? projectionsState.selectedCinema?.halls ?? []
            : <Hall>[];
            
        if (_selectedHallId != null && halls.isNotEmpty) {
          final selectedHall = halls.firstWhere(
            (hall) => hall.id == _selectedHallId,
            orElse: () => halls.first,
          );
          hallName = selectedHall.name;
        }
        
        final updatedProjection = Projection(
          id: widget.projection.id, // Keep the same ID for update
          movieId: _selectedMovieId!,
          movieTitle: movie.title,
          hallId: _selectedHallId ?? widget.projection.hallId, // Use selected hall ID
          hall: hallName, // Use selected hall name
          date: _selectedDate,
          time: _selectedTime,
          price: double.parse(_priceController.text),
          cinemaId: widget.projection.cinemaId,
        );

        context.read<ProjectionsBloc>().add(UpdateProjection(updatedProjection));
        Navigator.of(context).pop();
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Potvrdi brisanje',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Da li ste sigurni da želite obrisati ovu projekciju?',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.projection.movieTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.projection.time.format(context)} - ${widget.projection.hall}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${widget.projection.date.day}.${widget.projection.date.month}.${widget.projection.date.year}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ova akcija se ne može poništiti.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _deleteProjection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProjection() {
    if (widget.projection.id != null) {
      context.read<ProjectionsBloc>().add(DeleteProjection(widget.projection.id));
      Navigator.of(context).pop(); // Close edit modal
    }
  }
}