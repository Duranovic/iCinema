class City {
  final String id;
  final String name;
  final String countryName;

  City({
    required this.id,
    required this.name,
    required this.countryName,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      countryName: json['countryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryName': countryName,
    };
  }

  String get displayName => '$name, $countryName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City(id: $id, name: $name, country: $countryName)';
}
