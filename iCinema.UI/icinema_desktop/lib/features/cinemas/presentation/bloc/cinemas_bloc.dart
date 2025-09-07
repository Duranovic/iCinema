import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../projections/data/cinema_service.dart';
import '../../../projections/domain/cinema.dart';
import '../../../projections/domain/hall.dart';
import '../../data/city_service.dart';
import '../../domain/city.dart';
import 'cinemas_event.dart';
import 'cinemas_state.dart';

@injectable
class CinemasBloc extends Bloc<CinemasEvent, CinemasState> {
  final CinemaService cinemaService;
  final CityService cityService;

  CinemasBloc(this.cinemaService, this.cityService) : super(CinemasInitial()) {
    on<LoadCinemas>((event, emit) async {
      emit(CinemasLoading());
      try {
        final results = await Future.wait([
          cinemaService.fetchCinemas(),
          cityService.fetchCities(),
        ]);
        
        final cinemas = results[0] as List<Cinema>;
        final cities = results[1] as List<City>;
        
        emit(CinemasLoaded(cinemas: cinemas, cities: cities));
      } catch (e) {
        emit(CinemasError('Greška pri učitavanju kina: $e'));
      }
    });

    on<LoadCities>((event, emit) async {
      if (state is CinemasLoaded) {
        final currentState = state as CinemasLoaded;
        try {
          final cities = await cityService.fetchCities();
          emit(currentState.copyWith(cities: cities));
        } catch (e) {
          emit(CinemasError('Greška pri učitavanju gradova: $e'));
        }
      }
    });

    on<SearchCinemas>((event, emit) async {
      if (state is CinemasLoaded) {
        final currentState = state as CinemasLoaded;
        final filteredCinemas = _filterCinemas(currentState.cinemas, event.query);
        emit(currentState.copyWith(
          filteredCinemas: filteredCinemas,
          searchQuery: event.query,
        ));
      } else if (state is CinemaSelected) {
        // Keep details open and only update the list filter + query
        final currentState = state as CinemaSelected;
        final filtered = _filterCinemas(currentState.allCinemas, event.query);
        emit(currentState.copyWith(
          filteredCinemas: filtered,
          searchQuery: event.query,
        ));
      }
    });

    on<SelectCinema>((event, emit) async {
      if (state is CinemasLoaded) {
        final currentState = state as CinemasLoaded;
        final selectedCinema = currentState.cinemas.firstWhere(
          (cinema) => cinema.id == event.cinemaId,
        );
        emit(CinemaSelected(
          cinema: selectedCinema,
          allCinemas: currentState.cinemas,
          filteredCinemas: currentState.filteredCinemas,
          cities: currentState.cities,
          searchQuery: currentState.searchQuery,
        ));
      } else if (state is CinemaSelected) {
        final currentState = state as CinemaSelected;
        final selectedCinema = currentState.allCinemas.firstWhere(
          (cinema) => cinema.id == event.cinemaId,
        );
        emit(CinemaSelected(
          cinema: selectedCinema,
          allCinemas: currentState.allCinemas,
          filteredCinemas: currentState.filteredCinemas,
          cities: currentState.cities,
          searchQuery: currentState.searchQuery,
        ));
      }
    });

    on<CreateCinema>((event, emit) async {
      emit(CinemasLoading());
      try {
        final newCinema = Cinema(
          name: event.name,
          address: event.address,
          email: event.email,
          phoneNumber: event.phoneNumber,
          cityId: event.cityId,
          cityName: '', // Will be populated by backend response
          countryName: '', // Will be populated by backend response
        );
        
        await cinemaService.createCinema(newCinema);
        add(LoadCinemas()); // Reload to get updated list
      } catch (e) {
        emit(CinemasError('Greška pri kreiranju kina: $e'));
      }
    });

    on<UpdateCinema>((event, emit) async {
      if (state is CinemaSelected) {
        final currentState = state as CinemaSelected;
        emit(CinemasLoading());
        try {
          final updatedCinema = currentState.cinema.copyWith(
            name: event.name,
            address: event.address,
            email: event.email,
            phoneNumber: event.phoneNumber,
            cityId: event.cityId,
          );
          
          await cinemaService.updateCinema(updatedCinema);
          
          // Reload cinemas and then re-select the same cinema to stay in details view
          final results = await Future.wait([
            cinemaService.fetchCinemas(),
            cityService.fetchCities(),
          ]);
          
          final cinemas = results[0] as List<Cinema>;
          final cities = results[1] as List<City>;
          
          // Find the updated cinema and re-select it
          final refreshedCinema = cinemas.firstWhere(
            (cinema) => cinema.id == event.cinemaId,
          );
          
          emit(CinemaSelected(
            cinema: refreshedCinema,
            allCinemas: cinemas,
            filteredCinemas: _filterCinemas(cinemas, currentState.searchQuery),
            cities: cities,
            searchQuery: currentState.searchQuery,
          ));
        } catch (e) {
          emit(CinemasError('Greška pri ažuriranju kina: $e'));
        }
      }
    });

    on<DeleteCinema>((event, emit) async {
      emit(CinemasLoading());
      try {
        await cinemaService.deleteCinema(event.cinemaId);
        add(LoadCinemas()); // Reload to get updated list
      } catch (e) {
        emit(CinemasError('Greška pri brisanju kina: $e'));
      }
    });

    on<CreateHall>((event, emit) async {
      if (state is CinemaSelected) {
        final currentState = state as CinemaSelected;
        emit(CinemasLoading());
        try {
          final newHall = Hall(
            name: event.name,
            rowsCount: event.rowsCount,
            seatsPerRow: event.seatsPerRow,
            hallType: event.hallType,
            screenSize: event.screenSize,
            isDolbyAtmos: event.isDolbyAtmos,
            cinemaName: currentState.cinema.name,
          );
          
          await cinemaService.createHall(event.cinemaId, newHall);
          
          // Reload cinemas and then re-select the same cinema to stay in details view
          final results = await Future.wait([
            cinemaService.fetchCinemas(),
            cityService.fetchCities(),
          ]);
          
          final cinemas = results[0] as List<Cinema>;
          final cities = results[1] as List<City>;
          
          // Find the updated cinema and re-select it
          final refreshedCinema = cinemas.firstWhere(
            (cinema) => cinema.id == event.cinemaId,
          );
          
          emit(CinemaSelected(
            cinema: refreshedCinema,
            allCinemas: cinemas,
            cities: cities,
            searchQuery: currentState.searchQuery,
          ));
        } catch (e) {
          emit(CinemasError('Greška pri kreiranju sale: $e'));
        }
      }
    });

    on<UpdateHall>((event, emit) async {
      if (state is CinemaSelected) {
        final currentState = state as CinemaSelected;
        emit(CinemasLoading());
        try {
          final updatedHall = Hall(
            id: event.hallId,
            name: event.name,
            rowsCount: event.rowsCount,
            seatsPerRow: event.seatsPerRow,
            hallType: event.hallType,
            screenSize: event.screenSize,
            isDolbyAtmos: event.isDolbyAtmos,
            cinemaId: event.cinemaId,
            cinemaName: currentState.cinema.name,
          );
          
          await cinemaService.updateHall(event.cinemaId, updatedHall);
          
          // Reload cinemas and then re-select the same cinema to stay in details view
          final results = await Future.wait([
            cinemaService.fetchCinemas(),
            cityService.fetchCities(),
          ]);
          
          final cinemas = results[0] as List<Cinema>;
          final cities = results[1] as List<City>;
          
          // Find the updated cinema and re-select it
          final refreshedCinema = cinemas.firstWhere(
            (cinema) => cinema.id == event.cinemaId,
          );
          
          emit(CinemaSelected(
            cinema: refreshedCinema,
            allCinemas: cinemas,
            cities: cities,
            searchQuery: currentState.searchQuery,
          ));
        } catch (e) {
          emit(CinemasError('Greška pri ažuriranju sale: $e'));
        }
      }
    });

    on<DeleteHall>((event, emit) async {
      if (state is CinemaSelected) {
        final currentState = state as CinemaSelected;
        emit(CinemasLoading());
        try {
          await cinemaService.deleteHall(event.cinemaId, event.hallId);
          
          // Reload cinemas and then re-select the same cinema to stay in details view
          final results = await Future.wait([
            cinemaService.fetchCinemas(),
            cityService.fetchCities(),
          ]);
          
          final cinemas = results[0] as List<Cinema>;
          final cities = results[1] as List<City>;
          
          // Find the updated cinema and re-select it
          final updatedCinema = cinemas.firstWhere(
            (cinema) => cinema.id == event.cinemaId,
          );
          
          emit(CinemaSelected(
            cinema: updatedCinema,
            allCinemas: cinemas,
            filteredCinemas: _filterCinemas(cinemas, currentState.searchQuery),
            cities: cities,
            searchQuery: currentState.searchQuery,
          ));
        } catch (e) {
          emit(CinemasError('Greška pri brisanju sale: $e'));
        }
      }
    });

    on<ClearSelection>((event, emit) async {
      if (state is CinemaSelected) {
        final currentState = state as CinemaSelected;
        emit(CinemasLoaded(
          cinemas: currentState.allCinemas,
          cities: currentState.cities,
          filteredCinemas: _filterCinemas(currentState.allCinemas, currentState.searchQuery),
          searchQuery: currentState.searchQuery,
        ));
      }
    });
  }

  List<Cinema> _filterCinemas(List<Cinema> cinemas, String query) {
    if (query.isEmpty) return cinemas;
    
    final lowerQuery = query.toLowerCase();
    return cinemas.where((cinema) {
      return cinema.name.toLowerCase().contains(lowerQuery) ||
             cinema.address.toLowerCase().contains(lowerQuery) ||
             cinema.cityName.toLowerCase().contains(lowerQuery) ||
             cinema.countryName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
