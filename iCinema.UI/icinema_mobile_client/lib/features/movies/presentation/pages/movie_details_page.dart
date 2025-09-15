import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeSelectedDate(widget.projections);
    // Load movie details when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailsCubit>().loadMovieDetails(widget.movieId, widget.projections);
    });
  }

  void _initializeSelectedDate(List<ProjectionModel> projections) {
    if (projections.isNotEmpty) {
      // Group projections by date
      final dateGroups = _groupProjectionsByDate(projections);
      final sortedDates = dateGroups.keys.toList()..sort();
      
      // Select the first available date
      if (sortedDates.isNotEmpty) {
        selectedDate = sortedDates.first;
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
          builder: (context, state) {
            if (state is MovieDetailsLoading) {
              return _buildLoadingState();
            } else if (state is MovieDetailsError) {
              return _buildErrorState(state.message);
            } else if (state is MovieDetailsLoaded) {
              final projections = state.projections;
              // Ensure selected date is initialized when data arrives (e.g., from Search)
              if (selectedDate == null && projections.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _initializeSelectedDate(projections));
                });
              }
              return Column(
                children: [
                  // Header with back button and title
                  _buildHeader(state.movie),
                  
                  // Movie poster and info section
                  _buildMovieInfoSection(state.movie),
                  
                  // Available dates horizontal slider
                  _buildDateSlider(projections),
                  
                  // Projection times for selected date
                  Expanded(
                    child: _buildProjectionTimes(),
                  ),
                ],
              );
            } else {
              return _buildLoadingState();
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(MovieModel movie) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              movie.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfoSection(MovieModel movie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie poster placeholder
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  Theme.of(context).colorScheme.primary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Movie information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Movie stats with real data
                _buildMovieStats(movie),
                
                const SizedBox(height: 16),
                
                // Real movie description
                Text(
                  movie.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
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
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableDates.length,
              itemBuilder: (context, index) {
                final date = availableDates[index];
                final isSelected = selectedDate != null && 
                    date.year == selectedDate!.year &&
                    date.month == selectedDate!.month &&
                    date.day == selectedDate!.day;
                
                return _buildDateCard(date, isSelected, dateGroups[date]?.length ?? 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(DateTime date, bool isSelected, int projectionsCount) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    String dayLabel;
    if (date == today) {
      dayLabel = 'Danas';
    } else if (date == tomorrow) {
      dayLabel = 'Sutra';
    } else {
      dayLabel = _getDayName(date.weekday);
    }

    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}.${date.month}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$projectionsCount term.',
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? Colors.white.withOpacity(0.8)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
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
        final dateGroups = _groupProjectionsByDate(projections);
        final currentDate = selectedDate;
        final list = currentDate != null ? (dateGroups[currentDate] ?? []) : <ProjectionModel>[];
        if (list.isEmpty) {
      return Center(
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
              'Nema dostupnih projekcija za odabrani datum',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Rezerviši',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
