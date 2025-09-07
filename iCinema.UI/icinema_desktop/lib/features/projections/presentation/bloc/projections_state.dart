import 'package:icinema_desktop/features/projections/domain/projection.dart';
import 'package:icinema_desktop/features/projections/domain/cinema.dart';

abstract class ProjectionsState {}

class ProjectionsInitial extends ProjectionsState {}

class ProjectionsLoading extends ProjectionsState {
  final DateTime month;
  final List<Cinema> availableCinemas;
  final Cinema? selectedCinema;
  
  ProjectionsLoading(this.month, {this.availableCinemas = const [], this.selectedCinema});
}

class ProjectionsLoaded extends ProjectionsState {
  final List<Projection> projections;
  final DateTime month;
  final List<Cinema> availableCinemas;
  final Cinema? selectedCinema;
  
  ProjectionsLoaded(this.projections, this.month, {this.availableCinemas = const [], this.selectedCinema});
}

class ProjectionsError extends ProjectionsState {
  final String message;
  final DateTime month;
  final List<Cinema> availableCinemas;
  final Cinema? selectedCinema;
  
  ProjectionsError(this.message, this.month, {this.availableCinemas = const [], this.selectedCinema});
}