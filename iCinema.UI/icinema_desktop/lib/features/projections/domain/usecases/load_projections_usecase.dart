import 'package:injectable/injectable.dart';
import '../projection.dart';
import '../repositories/projections_repository.dart';

@lazySingleton
class LoadProjectionsUseCase {
  final ProjectionsRepository _repository;

  LoadProjectionsUseCase(this._repository);

  Future<List<Projection>> call({DateTime? date, bool disablePaging = true, String? cinemaId}) {
    return _repository.getProjections(date: date, disablePaging: disablePaging, cinemaId: cinemaId);
  }
}

