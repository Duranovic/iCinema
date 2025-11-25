import 'package:injectable/injectable.dart';
import '../projection.dart';
import '../repositories/projections_repository.dart';

@lazySingleton
class AddProjectionUseCase {
  final ProjectionsRepository _repository;

  AddProjectionUseCase(this._repository);

  Future<Projection> call(Projection projection) {
    return _repository.addProjection(projection);
  }
}

