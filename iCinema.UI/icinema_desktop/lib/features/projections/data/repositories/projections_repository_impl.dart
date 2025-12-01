import 'package:injectable/injectable.dart';
import '../../domain/projection.dart';
import '../../domain/repositories/projections_repository.dart';
import '../projection_service.dart';

@LazySingleton(as: ProjectionsRepository)
class ProjectionsRepositoryImpl implements ProjectionsRepository {
  final ProjectionService _service;

  ProjectionsRepositoryImpl(this._service);

  @override
  Future<List<Projection>> getProjections({DateTime? date, bool disablePaging = true, String? cinemaId}) =>
      _service.fetchProjections(date: date, disablePaging: disablePaging, cinemaId: cinemaId);

  @override
  Future<Projection> addProjection(Projection projection) =>
      _service.addProjection(projection);

  @override
  Future<Projection> updateProjection(Projection projection) =>
      _service.updateProjection(projection);

  @override
  Future<void> deleteProjection(String id) =>
      _service.deleteProjection(id);
}



