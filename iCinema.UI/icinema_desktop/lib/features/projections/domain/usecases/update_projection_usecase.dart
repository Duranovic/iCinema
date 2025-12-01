import 'package:injectable/injectable.dart';
import '../projection.dart';
import '../repositories/projections_repository.dart';

@lazySingleton
class UpdateProjectionUseCase {
  final ProjectionsRepository _repository;

  UpdateProjectionUseCase(this._repository);

  Future<Projection> call(Projection projection) {
    return _repository.updateProjection(projection);
  }
}



