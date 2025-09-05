import 'package:flutter/material.dart';
import 'package:icinema_desktop/features/projections/domain/projection.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';
import 'dart:math' as math;
import 'package:icinema_desktop/app/utils/bs_calendar_labels.dart';
import 'package:icinema_desktop/app/utils/date_gates.dart';

class ProjectionsCalendar extends StatefulWidget {
  const ProjectionsCalendar({super.key});

  @override
  State<ProjectionsCalendar> createState() => _ProjectionsCalendarState();
}

class _ProjectionsCalendarState extends State<ProjectionsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map of day -> list of projections (use SplayTreeMap to keep days sorted)
  final SplayTreeMap<DateTime, List<Projection>> _data =
  SplayTreeMap<DateTime, List<Projection>>(
        (a, b) => DateUtils.dateOnly(a).compareTo(DateUtils.dateOnly(b)),
  );

  @override
  void initState() {
    super.initState();
    // seed demo data
    final today = DateUtils.dateOnly(DateTime.now());
    _data[today.subtract(const Duration(days: 1))] = [
      Projection(movieTitle: "Dune: Part 2", hall: "Dvorana 1", time: const TimeOfDay(hour: 19, minute: 0)),
      Projection(movieTitle: "IF", hall: "Dvorana 2", time: const TimeOfDay(hour: 21, minute: 0)),
    ];
    _data[today] = [
      Projection(movieTitle: "Inside Out 2", hall: "Dvorana 1", time: const TimeOfDay(hour: 20, minute: 0)),
    ];
  }

  List<Projection> _eventsForDay(DateTime day) {
    return _data[DateUtils.dateOnly(day)] ?? const [];
  }

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
                      // open detail/edit if you want
                      Navigator.pop(ctx);
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
    final titleCtrl = TextEditingController();
    TimeOfDay selected = const TimeOfDay(hour: 20, minute: 0);
    String hall = "Dvorana 1";
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
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => Column(
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

                // Form fields
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: "Naziv filma",
                    hintText: "Unesite naziv filma",
                    prefixIcon: const Icon(Icons.movie_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: hall,
                        items: const [
                          DropdownMenuItem(value: "Dvorana 1", child: Text("Dvorana 1")),
                          DropdownMenuItem(value: "Dvorana 2", child: Text("Dvorana 2")),
                          DropdownMenuItem(value: "Dvorana 3", child: Text("Dvorana 3")),
                        ],
                        onChanged: (v) => setSheetState(() => hall = v ?? hall),
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
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
                    ),
                  ],
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
                          final list = _data.putIfAbsent(DateUtils.dateOnly(day), () => []);
                          list.add(Projection(
                            movieTitle: titleCtrl.text.isEmpty ? "Nepoznato" : titleCtrl.text,
                            hall: hall,
                            time: selected,
                          ));
                          setState(() {}); // refresh calendar
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
        child: TableCalendar<Projection>(
          firstDay: DateTime.utc(2018, 1, 1),
          lastDay: DateTime.utc(2032, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          eventLoader: _eventsForDay,
          calendarFormat: CalendarFormat.month,
          // Make each date tile taller
          rowHeight: 160,
          daysOfWeekHeight: 32,
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
            cellMargin: const EdgeInsets.all(8),
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
            defaultBuilder: (ctx, day, focusedDay) => _buildDayCell(ctx, day, isWeekend: _isWeekend(day)),
            todayBuilder: (ctx, day, _) => _buildDayCell(ctx, day, isToday: true, isWeekend: _isWeekend(day)),
            selectedBuilder: (ctx, day, _) => _buildDayCell(ctx, day, isSelected: true, isWeekend: _isWeekend(day)),
            outsideBuilder: (ctx, day, focusedDay) => _buildDayCell(ctx, day, isOutside: true, isWeekend: _isWeekend(day)),
            markerBuilder: (ctx, day, events) => const SizedBox.shrink(), // We handle markers in _buildDayCell
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext ctx, DateTime day, {
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

    return Container(
      // Keep inner content within the TableCalendar rowHeight to avoid overflow
      constraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 150,
      ),
      margin: const EdgeInsets.all(8),
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
                final availableHeight = constraints.maxHeight - 12; // Account for padding
                final headerHeight = 26.0;
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
                    if (events.isNotEmpty && remainingHeight > 25)
                      SizedBox(
                        height: math.min(remainingHeight, events.length * 18.0 + 4),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: math.min(events.length, math.max(1, (remainingHeight / 18).floor())),
                            itemBuilder: (context, index) {
                              if (index < events.length && index < 2) {
                                final event = events[index];
                                return Container(
                                  height: 16,
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getEventColor(event, colorScheme).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: _getEventColor(event, colorScheme),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.time.format(ctx),
                                          style: textTheme.labelSmall?.copyWith(
                                            color: _getEventColor(event, colorScheme),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 9,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (events.length > 2) {
                                // Show "more" indicator
                                return Container(
                                  height: 14,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                                        fontSize: 8,
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

  // --- Bosnian labels helpers ---
  String _formatBsMonthYear(DateTime d) {
    return "${_bsMonthName(d.month)} ${d.year}";
  }

  String _bsMonthName(int month) {
    const months = [
      'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Juni', 'Juli', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  // e.g., "Čet, 11. sep"
  String _formatBsMediumDate(DateTime d) {
    return "${_bsWeekdayShort(d.weekday)}, ${d.day}. ${_bsMonthShort(d.month)}";
  }

  String _bsMonthShort(int month) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'avg', 'sep', 'okt', 'nov', 'dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  String _bsWeekdayShort(int weekday) {
    // Monday=1 ... Sunday=7
    const days = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];
    return days[(weekday - 1).clamp(0, 6)];
  }
}