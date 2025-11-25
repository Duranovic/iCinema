import '../projection.dart';

abstract class ProjectionsRepository {
  Future<List<Projection>> getProjections({DateTime? date, bool disablePaging = true, String? cinemaId});
  Future<Projection> addProjection(Projection projection);
  Future<Projection> updateProjection(Projection projection);
  Future<void> deleteProjection(String id);
}

