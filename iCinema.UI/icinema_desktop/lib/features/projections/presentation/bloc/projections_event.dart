import 'package:icinema_desktop/features/projections/domain/projection.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';

abstract class ProjectionsEvent {}

class LoadProjections extends ProjectionsEvent {}

class LoadProjectionsForMonth extends ProjectionsEvent {
  final DateTime month; // any day within the target month
  final String? successMessage;
  LoadProjectionsForMonth(this.month, {this.successMessage});
}

class LoadCinemas extends ProjectionsEvent {}

class SelectCinema extends ProjectionsEvent {
  final Cinema? cinema; // null means "All Cinemas"
  SelectCinema(this.cinema);
}

class AddProjection extends ProjectionsEvent {
  final Projection projection;
  AddProjection(this.projection);
}

class UpdateProjection extends ProjectionsEvent {
  final Projection projection;
  UpdateProjection(this.projection);
}

class DeleteProjection extends ProjectionsEvent {
  final String? id;
  DeleteProjection(this.id);
}

class ClearProjectionsSuccessMessage extends ProjectionsEvent {}
