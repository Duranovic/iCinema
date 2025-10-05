import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/config/url_utils.dart';
import '../../../../app/services/auth_service.dart';
import '../bloc/similar_movies_cubit.dart';
import '../../data/services/recommendations_api_service.dart';
import '../../data/models/movie_score_dto.dart';
import '../../../home/data/models/projection_model.dart';
import '../../data/models/movie_model.dart';
import '../bloc/movie_details_cubit.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;
  final List<ProjectionModel> projections;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    required this.projections,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  DateTime? selectedDate;
  late final PageController _datesController;
  int _windowIndex = 0;
  // Similar movies slider
  final PageController _similarController = PageController();
  int _similarPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeSelectedDate(widget.projections);
    _datesController = PageController();
    // Load movie details when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailsCubit>().loadMovieDetails(widget.movieId, widget.projections);
      // Load my rating if authenticated
      final auth = getIt<AuthService>().authState;
      if (auth.isAuthenticated) {
        context.read<MovieDetailsCubit>().loadMyRating(widget.movieId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MovieDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If movieId or incoming projections changed, reset selection
    if (oldWidget.movieId != widget.movieId || oldWidget.projections != widget.projections) {
      selectedDate = null;
      _windowIndex = 0;
      _initializeSelectedDate(widget.projections);
    }
  }

  Widget _buildSimilarCard(MovieScoreDto item, {required double width}) {
    return GestureDetector(
      onTap: () {
        final id = Uri.encodeComponent(item.movieId);
        context.push('/movie-details/$id');
      },
      child: Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.posterUrl != null && item.posterUrl!.isNotEmpty
                    ? Image.network(
                        resolveImageUrl(item.posterUrl)!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _similarPosterPlaceholder(),
                      )
                    : _similarPosterPlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _secondarySimilarText(item.genres, item.director),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SimilarMoviesCubit>(
      create: (_) => SimilarMoviesCubit(getIt<RecommendationsApiService>())
        ..loadSimilar(widget.movieId, top: 10),
      child: Scaffold(
        body: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
          builder: (context, state) {
            if (state is MovieDetailsLoading) {
              return _buildLoadingState();
            } else if (state is MovieDetailsError) {
              return _buildErrorState(state.message);
            } else if (state is MovieDetailsLoaded) {
              final projections = state.projections;
              // Ensure selected date is valid: prefer earliest future date; fallback to earliest overall
              if (projections.isNotEmpty) {
                final groups = _groupProjectionsByDate(projections);
                final sortedDates = groups.keys.toList()..sort();
                DateTime? earliestFuture;
                final today = DateTime.now();
                for (final d in sortedDates) {
                  if (!d.isBefore(DateTime(today.year, today.month, today.day))) {
                    earliestFuture = d;
                    break;
                  }
                }
                final preferred = earliestFuture ?? sortedDates.first;
                final selectedKey = selectedDate == null
                    ? null
                    : DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
                if (selectedKey == null || !groups.containsKey(selectedKey)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => selectedDate = preferred);
                  });
                }
              } else {
                // No projections at all for this movie
                if (selectedDate != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => selectedDate = null);
                  });
                }
              }

              return SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full-width hero image with overlay back button
                      _buildHeroImageSection(state.movie),

                      // Movie details (title, stats, description)
                      const SizedBox(height: 16),
                      _buildDetailsSection(state.movie),

                      // Available dates horizontal slider
                      _buildDateSlider(projections),

                      // Projection times for selected date (non-scrollable list inside page scroll)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildProjectionTimes(),
                      ),

                      // Similar movies section
                      const SizedBox(height: 8),
                      _buildSimilarMoviesSection(),
                    ],
                  ),
                ),
              );
            } else {
              return _buildLoadingState();
            }
          },
        ),
      ),
    );
  }

  // ========================
  // Slični filmovi section
  // ========================
  Widget _buildSimilarMoviesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Slični filmovi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<SimilarMoviesCubit, SimilarMoviesState>(
            builder: (context, state) {
              if (state is SimilarMoviesLoading || state is SimilarMoviesInitial) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is SimilarMoviesError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Greška pri dohvaćanju sličnih filmova. Pokušajte ponovo.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.read<SimilarMoviesCubit>().loadSimilar(widget.movieId, top: 10),
                      child: const Text('Pokušaj ponovo'),
                    ),
                  ],
                );
              }
              if (state is SimilarMoviesLoaded) {
                final items = state.items;
                if (items.isEmpty) {
                  return const Text(
                    'Trenutno nema sličnih naslova.',
                    style: TextStyle(fontSize: 14),
                  );
                }

                const cardsPerPage = 2;
                final pageCount = (items.length / cardsPerPage).ceil();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _navButton(context, Icons.chevron_left, () {
                          final target = (_similarPage - 1).clamp(0, pageCount - 1);
                          if (target != _similarPage) {
                            setState(() => _similarPage = target);
                            _similarController.animateToPage(
                              _similarPage,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        }),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 240,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 10.0;
                                const horizontalPadding = 0.0; // already padded outside
                                final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
                                final cardWidth = (availableWidth - (spacing * (cardsPerPage - 1))) / cardsPerPage;

                                return PageView.builder(
                                  controller: _similarController,
                                  itemCount: pageCount,
                                  onPageChanged: (i) => setState(() => _similarPage = i),
                                  itemBuilder: (context, pageIndex) {
                                    final start = pageIndex * cardsPerPage;
                                    final pageItems = items.skip(start).take(cardsPerPage).toList();
                                    return Row(
                                      children: [
                                        for (int i = 0; i < pageItems.length; i++) ...[
                                          _buildSimilarCard(pageItems[i], width: cardWidth),
                                          if (i < pageItems.length - 1) const SizedBox(width: spacing),
                                        ],
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _navButton(context, Icons.chevron_right, () {
                          final target = (_similarPage + 1).clamp(0, pageCount - 1);
                          if (target != _similarPage) {
                            setState(() => _similarPage = target);
                            _similarController.animateToPage(
                              _similarPage,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        }),
                      ],
                    ),
                    if (pageCount > 1) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pageCount, (i) {
                          final selected = i == _similarPage;
                          return Container(
                            width: selected ? 20 : 8,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _similarPosterPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.movie,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _secondarySimilarText(List<String> genres, String? director) {
    if (genres.isNotEmpty) {
      return genres.join(' • ');
    }
    return director == null || director.isEmpty ? 'Nepoznat' : director;
  }

  void _initializeSelectedDate(List<ProjectionModel> projections) {
    if (projections.isNotEmpty) {
      // Group projections by date
      final dateGroups = _groupProjectionsByDate(projections);
      final sortedDates = dateGroups.keys.toList()..sort();
      if (sortedDates.isEmpty) return;
      // Prefer earliest future date, else earliest overall
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime? pick;
      for (final d in sortedDates) {
        if (!d.isBefore(today)) {
          pick = d;
          break;
        }
      }
      selectedDate = pick ?? sortedDates.first;
    } else {
      selectedDate = null;
    }
  }

  Map<DateTime, List<ProjectionModel>> _groupProjectionsByDate(List<ProjectionModel> projections) {
    final Map<DateTime, List<ProjectionModel>> groups = {};
    
    for (final projection in projections) {
      final date = DateTime(
        projection.startTime.year,
        projection.startTime.month,
        projection.startTime.day,
      );
      
      if (groups.containsKey(date)) {
        groups[date]!.add(projection);
      } else {
        groups[date] = [projection];
      }
    }
    
    // Sort projections within each date by start time
    for (final projections in groups.values) {
      projections.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    
    return groups;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  Widget _buildHeroImageSection(MovieModel movie) {
    final url = movie.posterUrl;
    final hasPoster = url != null && url.isNotEmpty;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 260,
          child: hasPoster
              ? Image.network(
                  resolveImageUrl(url)!,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => _heroGradientTitle(movie.title),
                )
              : _heroGradientTitle(movie.title),
        ),
        // Gradient overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.45),
                ],
              ),
            ),
          ),
        ),
        // Back button overlay
        Positioned(
          top: 12,
          left: 12,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroGradientTitle(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.primary,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(MovieModel movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildMovieStats(movie),
          const SizedBox(height: 12),
          _buildRatingsSection(movie),
          const SizedBox(height: 16),
          Text(
            movie.description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(MovieModel movie) {
    final state = context.watch<MovieDetailsCubit>().state;
    double? myRating;
    bool canRate = false;
    if (state is MovieDetailsLoaded) {
      myRating = state.myRating;
      canRate = state.canRate;
    }
    final avg = movie.averageRating ?? 0.0;
    final count = movie.ratingsCount ?? 0;

    // If user cannot rate and has no existing rating, hide the whole section
    if (!canRate && (myRating == null || myRating == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating row
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 6),
            Text(
              avg > 0 ? avg.toStringAsFixed(1) : 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text('(${count.toString()} ocjena${count == 1 ? '' : ''})',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 8),
        // My rating row
        Text(
          'Moja ocjena',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            final filled = (myRating ?? 0).round() >= starIndex;
            final color = canRate ? Colors.amber : Theme.of(context).disabledColor;
            return IconButton(
              tooltip: '$starIndex',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: color,
              ),
              onPressed: () {
                final auth = getIt<AuthService>().authState;
                if (!auth.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prijavite se da ocijenite film.')));
                  return;
                }
                if (!canRate) return; // read-only when not allowed
                context.read<MovieDetailsCubit>().saveMyRating(
                      movieId: movie.id,
                      rating: starIndex.toDouble(),
                    );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMovieStats(MovieModel movie) {
    final cubitState = context.read<MovieDetailsCubit>().state;
    final projections = cubitState is MovieDetailsLoaded ? cubitState.projections : <ProjectionModel>[];
    final totalProjections = projections.length;
    final uniqueCinemas = projections
        .map((p) => p.cinemaName)
        .toSet()
        .length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow(Icons.access_time, movie.formattedDuration),
        const SizedBox(height: 4),
        _buildStatRow(Icons.calendar_today, movie.releaseYear),
        const SizedBox(height: 4),
        _buildStatRow(Icons.category, movie.formattedGenres),
        const SizedBox(height: 4),
        _buildStatRow(Icons.movie, '$totalProjections projekcija'),
        const SizedBox(height: 4),
        _buildStatRow(Icons.location_on, '$uniqueCinemas kina'),
        const SizedBox(height: 4),
        if (projections.isNotEmpty)
          _buildStatRow(
            Icons.attach_money,
            '${projections.first.price.toStringAsFixed(0)} KM',
          ),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSlider(List<ProjectionModel> projections) {
    final dateGroups = _groupProjectionsByDate(projections);
    final availableDates = dateGroups.keys.toList()..sort();

    if (availableDates.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure selected date is one of available and visible
    if (selectedDate == null) {
      // Prefer earliest future, fallback to first
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime? future;
      for (final d in availableDates) {
        if (!d.isBefore(today)) { future = d; break; }
      }
      selectedDate = future ?? availableDates.first;
    }

    // Build snapping windows of up to 5 dates each
    const cardsPerWindow = 5;
    final maxWindows = (availableDates.length / cardsPerWindow).ceil();
    _windowIndex = _windowIndex.clamp(0, maxWindows - 1);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Dostupni termini',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                _navButton(context, Icons.chevron_left, () {
                  final target = (_windowIndex - 1).clamp(0, maxWindows - 1);
                  if (target != _windowIndex) {
                    setState(() => _windowIndex = target);
                    _datesController.animateToPage(
                      _windowIndex,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                }),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: SizedBox(
                      height: 64,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final contentWidth = constraints.maxWidth;
                          const double spacing = 6.0;
                          const int cardsPerWindow = 5;
                          final totalSpacing = spacing * (cardsPerWindow - 1);
                          final cardWidth = (contentWidth - totalSpacing) / cardsPerWindow;

                          return PageView.builder(
                            controller: _datesController,
                            itemCount: maxWindows,
                            onPageChanged: (i) => setState(() => _windowIndex = i),
                            pageSnapping: true,
                            physics: const PageScrollPhysics(),
                            itemBuilder: (context, pageIndex) {
                              final start = pageIndex * cardsPerWindow;
                              final dates = availableDates.skip(start).take(cardsPerWindow).toList();
                              return Row(
                                children: [
                                  for (int i = 0; i < dates.length; i++) ...[
                                    _buildDateCard(
                                      dates[i],
                                      _isSameDay(dates[i], selectedDate),
                                      width: cardWidth,
                                    ),
                                    if (i < dates.length - 1) const SizedBox(width: spacing),
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
                _navButton(context, Icons.chevron_right, () {
                  final target = (_windowIndex + 1).clamp(0, maxWindows - 1);
                  if (target != _windowIndex) {
                    setState(() => _windowIndex = target);
                    _datesController.animateToPage(
                      _windowIndex,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateCard(DateTime date, bool isSelected, {double? width}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    String dayLabel;
    if (date == today) {
      dayLabel = 'Danas';
    } else if (date == tomorrow) {
      dayLabel = 'Sutra';
    } else {
      const names = ['Pon.', 'Uto.', 'Sri.', 'Čet.', 'Pet.', 'Sub.', 'Ned.'];
      dayLabel = names[date.weekday - 1];
    }

    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: isSelected ? 1.06 : 1.0,
        child: Container(
          width: width ?? 64,
          margin: width != null
              ? const EdgeInsets.symmetric(vertical: 2)
              : const EdgeInsets.only(right: 12, top: 2, bottom: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
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
                dayLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}.${date.month}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 64,
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildProjectionTimes() {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        if (state is! MovieDetailsLoaded) {
          return const SizedBox.shrink();
        }
        final projections = state.projections;
        if (projections.isEmpty) {
          // No projections at all for this movie
          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Trenutno nema dostupnih projekcija za ovaj film.',
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
          );
        }
        final dateGroups = _groupProjectionsByDate(projections);
        final currentDate = selectedDate;
        final list = currentDate != null ? (dateGroups[currentDate] ?? []) : <ProjectionModel>[];
        if (list.isEmpty) {
          final d = selectedDate ?? DateTime.now();
          final label = _getDayName(d.weekday);
          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Termini za ${_formatSelectedDate()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final projection = list[index];
                  return _buildProjectionCard(projection);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectionCard(ProjectionModel projection) {
    final now = DateTime.now();
    final canReserve = projection.startTime.isAfter(now.add(const Duration(minutes: 10)));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatTime(projection.startTime),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Cinema and hall info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projection.cinemaName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  projection.hallName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${projection.price.toStringAsFixed(0)} KM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              FilledButton(
                onPressed: canReserve
                    ? () {
                        final id = Uri.encodeComponent(projection.id);
                        context.push('/projections/$id/reserve');
                      }
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: canReserve ? null : Theme.of(context).disabledColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Rezerviši',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatSelectedDate() {
    if (selectedDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    if (selectedDate == today) {
      return 'danas';
    } else if (selectedDate == tomorrow) {
      return 'sutra';
    } else {
      return '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}';
    }
  }

  String _getDayName(int weekday) {
    const days = [
      'Ponedjeljak',
      'Utorak', 
      'Srijeda',
      'Četvrtak',
      'Petak',
      'Subota',
      'Nedjelja'
    ];
    return days[weekday - 1];
  }

  // State handling methods
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Učitavamo detalje filma...',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Greška',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<MovieDetailsCubit>().loadMovieDetails(
                  widget.movieId, 
                  widget.projections,
                );
              },
              child: const Text('Pokušaj ponovo'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nazad'),
            ),
          ],
        ),
      ),
    );
  }
}
