import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../home/data/models/projection_model.dart';
import '../../data/models/movie_model.dart';
import '../bloc/movies_cubit.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late DateTime _selectedDate;
  late DateTime _windowStart; // start of 5-day window (fallback)
  late final PageController _datesController; // controls window pages
  int _windowIndex = 0; // current window page index

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _windowStart = _selectedDate;
    _datesController = PageController();
  }

  List<DateTime> _datesInWindowFrom(DateTime start, DateTime to) {
    return List.generate(5, (i) {
      final d = start.add(Duration(days: i));
      if (d.isAfter(to)) return start; // clamp; will be filtered by caller
      return DateTime(d.year, d.month, d.day);
    });
  }

  void _shiftWindowByPages(int delta, int maxWindows) {
    final target = (_windowIndex + delta).clamp(0, maxWindows - 1);
    if (target == _windowIndex) return;
    setState(() => _windowIndex = target);
    _datesController.animateToPage(
      _windowIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onDateTap(DateTime d) {
    setState(() => _selectedDate = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repertoar'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: BlocBuilder<MoviesCubit, MoviesState>(
        builder: (context, state) {
          if (state is MoviesInitial || state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MoviesError) {
            return _buildErrorState(context, state.message);
          }
          if (state is MoviesLoaded) {
            // Filter projections by selected day
            final dayStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
            final dayEnd = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
            final todaysProjections = state.projections.where((p) {
              return p.startTime.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                     p.startTime.isBefore(dayEnd.add(const Duration(seconds: 1)));
            }).toList();

            final movieIdsForDay = todaysProjections.map((p) => p.movieId).toSet();
            final movies = movieIdsForDay
                .map((id) => state.moviesById[id])
                .whereType<MovieModel>()
                .toList()
              ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

            // Helper to get projections for a movie (for details page)
            List<ProjectionModel> projectionsFor(String movieId) => todaysProjections
                .where((p) => p.movieId == movieId)
                .toList();

            return RefreshIndicator(
              onRefresh: () => context.read<MoviesCubit>().loadRepertoire(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                itemCount: movies.length + 2,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, state),
                        const SizedBox(height: 12),
                        _buildDatePicker(context, state),
                        const SizedBox(height: 12),
                        if (movies.isEmpty) _buildDayEmptyState(context),
                      ],
                    );
                  }
                  if (index == 1) {
                    // Spacer between date picker and first item
                    return const SizedBox.shrink();
                  }
                  final movie = movies[index - 2];
                  final movieProjections = projectionsFor(movie.id);
                  return _MovieListItem(
                    movie: movie,
                    onTap: () {
                      final encodedId = Uri.encodeComponent(movie.id);
                      context.push('/movie-details/$encodedId', extra: movieProjections);
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MoviesLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gledaj na repertoaru',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<MoviesCubit>().loadRepertoire(),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 48),
            const SizedBox(height: 12),
            Text(
              'Trenutno nema dostupnih projekcija.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRange(DateTime from, DateTime to) {
    return '${_formatDate(from)} - ${_formatDate(to)}';
  }

  String _formatDate(DateTime d) {
    return '${d.day}.${d.month}.${d.year}';
  }

  String _fullDayName(DateTime d) {
    const names = ['Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 'Petak', 'Subota', 'Nedjelja'];
    return names[d.weekday - 1];
  }

  Widget _buildDayEmptyState(BuildContext context) {
    final d = _selectedDate;
    final label = _fullDayName(d);
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Nema dostupnih projekcija za $label ${d.day}.${d.month}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, MoviesLoaded state) {
    // Compute windows from overall range [from..to]
    final totalDays = state.to.difference(state.from).inDays + 1;
    final maxWindows = (totalDays / 5).ceil();
    _windowIndex = _windowIndex.clamp(0, maxWindows - 1);

    return Row(
      children: [
        _navButton(context, Icons.chevron_left, () => _shiftWindowByPages(-1, maxWindows)),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SizedBox(
              height: 64,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth;
                  const cardsPerWindow = 5;
                  const spacing = 6.0;
                  final totalSpacing = spacing * (cardsPerWindow - 1);
                  final cardWidth = (contentWidth - totalSpacing) / cardsPerWindow;

                  return PageView.builder(
                    controller: _datesController,
                    itemCount: maxWindows,
                    onPageChanged: (i) => setState(() => _windowIndex = i),
                    pageSnapping: true,
                    physics: const PageScrollPhysics(),
                    itemBuilder: (context, pageIndex) {
                      final start = state.from.add(Duration(days: pageIndex * 5));
                      final dates = _datesInWindowFrom(start, state.to)
                          .where((d) => !d.isAfter(state.to))
                          .toList();
                      return Row(
                        children: [
                          for (int i = 0; i < dates.length; i++) ...[
                            _buildDateCard(
                              context,
                              dates[i],
                              dates[i].year == _selectedDate.year &&
                                  dates[i].month == _selectedDate.month &&
                                  dates[i].day == _selectedDate.day,
                              width: cardWidth,
                            ),
                            if (i < dates.length - 1) SizedBox(width: spacing),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _navButton(context, Icons.chevron_right, () => _shiftWindowByPages(1, maxWindows)),
      ],
    );
  }

  Widget _navButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 28,
          height: 64,
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, DateTime date, bool isSelected, {double? width}) {
    return GestureDetector(
      onTap: () => _onDateTap(date),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: isSelected ? 1.06 : 1.0,
        child: Container(
          width: width ?? 58,
          margin: width != null
              ? const EdgeInsets.symmetric(vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(isSelected ? 14 : 12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            boxShadow: null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _dayLabel(date),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${date.day}.${date.month}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Danas';
    if (d == tomorrow) return 'Sutra';
    const names = ['Pon.', 'Uto.', 'Sri.', 'Čet.', 'Pet.', 'Sub.', 'Ned.'];
    return names[d.weekday - 1];
  }
}

class _MovieListItem extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const _MovieListItem({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left image placeholder / poster
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 120,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.white.withOpacity(0.9),
                    size: 44,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right centered details
            Expanded(
              child: SizedBox(
                height: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (movie.genres.isNotEmpty)
                      Text(
                        movie.formattedGenres,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          movie.formattedDuration,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 6),
                        Text(movie.releaseYear),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

