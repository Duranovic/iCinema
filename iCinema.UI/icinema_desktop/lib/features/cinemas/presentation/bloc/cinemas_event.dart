abstract class CinemasEvent {}

class LoadCinemas extends CinemasEvent {
  final String? successMessage;
  LoadCinemas({this.successMessage});
}

class LoadCities extends CinemasEvent {}

class SearchCinemas extends CinemasEvent {
  final String query;
  SearchCinemas(this.query);
}

class SelectCinema extends CinemasEvent {
  final String cinemaId;
  final String? successMessage;
  SelectCinema(this.cinemaId, {this.successMessage});
}

class CreateCinema extends CinemasEvent {
  final String name;
  final String address;
  final String? email;
  final String? phoneNumber;
  final String cityId;
  
  CreateCinema({
    required this.name,
    required this.address,
    this.email,
    this.phoneNumber,
    required this.cityId,
  });
}

class UpdateCinema extends CinemasEvent {
  final String cinemaId;
  final String name;
  final String address;
  final String? email;
  final String? phoneNumber;
  final String cityId;
  
  UpdateCinema({
    required this.cinemaId,
    required this.name,
    required this.address,
    this.email,
    this.phoneNumber,
    required this.cityId,
  });
}

class DeleteCinema extends CinemasEvent {
  final String cinemaId;
  DeleteCinema(this.cinemaId);
}

class CreateHall extends CinemasEvent {
  final String cinemaId;
  final String name;
  final int rowsCount;
  final int seatsPerRow;
  final String hallType;
  final String screenSize;
  final bool isDolbyAtmos;
  
  CreateHall({
    required this.cinemaId,
    required this.name,
    required this.rowsCount,
    required this.seatsPerRow,
    required this.hallType,
    required this.screenSize,
    required this.isDolbyAtmos,
  });
}

class UpdateHall extends CinemasEvent {
  final String cinemaId;
  final String hallId;
  final String name;
  final int rowsCount;
  final int seatsPerRow;
  final String hallType;
  final String screenSize;
  final bool isDolbyAtmos;
  
  UpdateHall({
    required this.cinemaId,
    required this.hallId,
    required this.name,
    required this.rowsCount,
    required this.seatsPerRow,
    required this.hallType,
    required this.screenSize,
    required this.isDolbyAtmos,
  });
}

class DeleteHall extends CinemasEvent {
  final String cinemaId;
  final String hallId;
  
  DeleteHall({
    required this.cinemaId,
    required this.hallId,
  });
}

class ClearSelection extends CinemasEvent {}

class ClearCinemasSuccessMessage extends CinemasEvent {}
