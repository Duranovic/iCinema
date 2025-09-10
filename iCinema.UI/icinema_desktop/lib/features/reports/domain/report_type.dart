enum ReportType {
  movieReservations,
  movieSales,
  hallReservations,
  cinemaReservations,
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.movieReservations:
        return 'Rezervacije po filmu';
      case ReportType.movieSales:
        return 'Prodaja po filmu';
      case ReportType.hallReservations:
        return 'Rezervacije po sali';
      case ReportType.cinemaReservations:
        return 'Rezervacije po kinu';
    }
  }

  String get apiValue {
    switch (this) {
      case ReportType.movieReservations:
        return 'movieReservations';
      case ReportType.movieSales:
        return 'movieSales';
      case ReportType.hallReservations:
        return 'hallReservations';
      case ReportType.cinemaReservations:
        return 'cinemaReservations';
    }
  }
}

ReportType reportTypeFromString(String value) {
  return ReportType.values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => ReportType.movieReservations,
  );
}
