import '../models/projection_model.dart';
import '../services/projections_api_service.dart';

abstract class HomeRepository {
  Future<List<ProjectionModel>> getTodayProjections();
  Future<List<ProjectionModel>> getUpcomingProjections();
  Future<Map<String, List<ProjectionModel>>> getGroupedProjections();
}

class HomeRepositoryImpl implements HomeRepository {
  final ProjectionsApiService _apiService;

  HomeRepositoryImpl(this._apiService);

  @override
  Future<List<ProjectionModel>> getTodayProjections() async {
    try {
      final response = await _apiService.getTodayProjections();
      return response.items;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProjectionModel>> getUpcomingProjections() async {
    try {
      final response = await _apiService.getUpcomingProjections();
      return response.items;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, List<ProjectionModel>>> getGroupedProjections() async {
    try {
      // Get projections for the next 7 days
      final today = DateTime.now();
      final nextWeek = today.add(const Duration(days: 7));
      
      final response = await _apiService.getProjectionsInRange(
        startDate: today,
        endDate: nextWeek,
      );

      // Group projections by movie title
      final Map<String, List<ProjectionModel>> groupedProjections = {};
      
      for (final projection in response.items) {
        final movieTitle = projection.movieTitle;
        if (groupedProjections.containsKey(movieTitle)) {
          groupedProjections[movieTitle]!.add(projection);
        } else {
          groupedProjections[movieTitle] = [projection];
        }
      }

      // Sort projections within each movie group by start time
      for (final projections in groupedProjections.values) {
        projections.sort((a, b) => a.startTime.compareTo(b.startTime));
      }

      return groupedProjections;
    } catch (e) {
      rethrow;
    }
  }
}

// Helper class for organizing home page data
class HomePageData {
  final List<ProjectionModel> featuredProjections;
  final List<ProjectionModel> todayProjections;
  final List<ProjectionModel> upcomingProjections;
  final Map<String, List<ProjectionModel>> groupedProjections;

  const HomePageData({
    required this.featuredProjections,
    required this.todayProjections,
    required this.upcomingProjections,
    required this.groupedProjections,
  });

  factory HomePageData.empty() {
    return const HomePageData(
      featuredProjections: [],
      todayProjections: [],
      upcomingProjections: [],
      groupedProjections: {},
    );
  }

  HomePageData copyWith({
    List<ProjectionModel>? featuredProjections,
    List<ProjectionModel>? todayProjections,
    List<ProjectionModel>? upcomingProjections,
    Map<String, List<ProjectionModel>>? groupedProjections,
  }) {
    return HomePageData(
      featuredProjections: featuredProjections ?? this.featuredProjections,
      todayProjections: todayProjections ?? this.todayProjections,
      upcomingProjections: upcomingProjections ?? this.upcomingProjections,
      groupedProjections: groupedProjections ?? this.groupedProjections,
    );
  }
}
