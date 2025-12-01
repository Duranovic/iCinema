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
  
  CinemasLoaded({
    required this.cinemas,
    List<Cinema>? filteredCinemas,
    this.cities = const [],
    this.searchQuery = '',
    this.successMessage,
  }) : filteredCinemas = filteredCinemas ?? cinemas;
  
  CinemasLoaded copyWith({
    List<Cinema>? cinemas,
    List<Cinema>? filteredCinemas,
    List<City>? cities,
    String? searchQuery,
    String? successMessage,
  }) {
    return CinemasLoaded(
      cinemas: cinemas ?? this.cinemas,
      filteredCinemas: filteredCinemas ?? this.filteredCinemas,
      cities: cities ?? this.cities,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: successMessage ?? this.successMessage,
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
  
  CinemaSelected({
    required this.cinema,
    required this.allCinemas,
    List<Cinema>? filteredCinemas,
    this.cities = const [],
    this.searchQuery = '',
    this.successMessage,
  }) : filteredCinemas = filteredCinemas ?? allCinemas;
  
  CinemaSelected copyWith({
    Cinema? cinema,
    List<Cinema>? allCinemas,
    List<Cinema>? filteredCinemas,
    List<City>? cities,
    String? searchQuery,
    String? successMessage,
  }) {
    return CinemaSelected(
      cinema: cinema ?? this.cinema,
      allCinemas: allCinemas ?? this.allCinemas,
      filteredCinemas: filteredCinemas ?? this.filteredCinemas,
      cities: cities ?? this.cities,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class CinemasError extends CinemasState {
  final String message;
  CinemasError(this.message);
}
