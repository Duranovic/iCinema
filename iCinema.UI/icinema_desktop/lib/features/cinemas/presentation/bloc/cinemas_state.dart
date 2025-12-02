import '../../../projections/domain/cinema.dart';
import '../../domain/city.dart';

abstract class CinemasState {}

class CinemasInitial extends CinemasState {}

class CinemasLoading extends CinemasState {}

class CinemasLoaded extends CinemasState {
  final List<Cinema> cinemas;
  final List<Cinema> filteredCinemas;
  final List<City> cities;
  final String searchQuery;
  final String? successMessage;
  final String? errorMessage;
  
  CinemasLoaded({
    required this.cinemas,
    List<Cinema>? filteredCinemas,
    this.cities = const [],
    this.searchQuery = '',
    this.successMessage,
    this.errorMessage,
  }) : filteredCinemas = filteredCinemas ?? cinemas;
  
  CinemasLoaded copyWith({
    List<Cinema>? cinemas,
    List<Cinema>? filteredCinemas,
    List<City>? cities,
    String? searchQuery,
    String? successMessage,
    String? errorMessage,
  }) {
    return CinemasLoaded(
      cinemas: cinemas ?? this.cinemas,
      filteredCinemas: filteredCinemas ?? this.filteredCinemas,
      cities: cities ?? this.cities,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

class CinemaSelected extends CinemasState {
  final Cinema cinema;
  final List<Cinema> allCinemas;
  final List<Cinema> filteredCinemas;
  final List<City> cities;
  final String searchQuery;
  final String? successMessage;
  final String? errorMessage;
  
  CinemaSelected({
    required this.cinema,
    required this.allCinemas,
    List<Cinema>? filteredCinemas,
    this.cities = const [],
    this.searchQuery = '',
    this.successMessage,
    this.errorMessage,
  }) : filteredCinemas = filteredCinemas ?? allCinemas;
  
  CinemaSelected copyWith({
    Cinema? cinema,
    List<Cinema>? allCinemas,
    List<Cinema>? filteredCinemas,
    List<City>? cities,
    String? searchQuery,
    String? successMessage,
    String? errorMessage,
  }) {
    return CinemaSelected(
      cinema: cinema ?? this.cinema,
      allCinemas: allCinemas ?? this.allCinemas,
      filteredCinemas: filteredCinemas ?? this.filteredCinemas,
      cities: cities ?? this.cities,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

class CinemasError extends CinemasState {
  final String message;
  CinemasError(this.message);
}
