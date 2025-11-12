class City {
  final String id;
  final String name;
  final String countryId;

  City({required this.id, required this.name, required this.countryId});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Nepoznato',
      countryId: json['countryId']?.toString() ?? '',
    );
  }
}
