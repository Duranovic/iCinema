import 'hall.dart';

class Cinema {
  final String? id;
  final String name;
  final String address;
  final String? email;
  final String? phoneNumber;
  final String? cityId;
  final String cityName;
  final String countryName;
  final List<Hall> halls;

  Cinema({
    this.id,
    required this.name,
    required this.address,
    this.email,
    this.phoneNumber,
    this.cityId,
    required this.cityName,
    required this.countryName,
    this.halls = const [],
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    final hallsList = json['halls'] as List<dynamic>? ?? [];
    final halls = hallsList.map((hallJson) => Hall.fromJson(hallJson as Map<String, dynamic>)).toList();
    
    return Cinema(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      cityId: json['cityId']?.toString(),
      cityName: json['cityName'] ?? '',
      countryName: json['countryName'] ?? '',
      halls: halls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (cityId != null) 'cityId': cityId,
      'cityName': cityName,
      'countryName': countryName,
      'halls': halls.map((hall) => hall.toJson()).toList(),
    };
  }

  String get displayLocation => '$cityName, $countryName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cinema && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Cinema(id: $id, name: $name, address: $address, city: $cityName)';
}
