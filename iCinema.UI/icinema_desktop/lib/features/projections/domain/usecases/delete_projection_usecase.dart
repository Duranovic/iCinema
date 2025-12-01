import 'package:injectable/injectable.dart';
import '../repositories/projections_repository.dart';

@lazySingleton
class DeleteProjectionUseCase {
  final ProjectionsRepository _repository;

  DeleteProjectionUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteProjection(id);
  }
}



