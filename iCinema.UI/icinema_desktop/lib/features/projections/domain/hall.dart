class Hall {
  final String? id;
  final String name;
  final int rowsCount;
  final int seatsPerRow;
  final String hallType;
  final String screenSize;
  final bool isDolbyAtmos;
  final String? cinemaId;
  final String cinemaName;

  Hall({
    this.id,
    required this.name,
    required this.rowsCount,
    required this.seatsPerRow,
    required this.hallType,
    required this.screenSize,
    required this.isDolbyAtmos,
    this.cinemaId,
    required this.cinemaName,
  });

  int get capacity => rowsCount * seatsPerRow;

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      rowsCount: json['rowsCount'] ?? 0,
      seatsPerRow: json['seatsPerRow'] ?? 0,
      hallType: json['hallType'] ?? '',
      screenSize: json['screenSize'] ?? '',
      isDolbyAtmos: json['isDolbyAtmos'] ?? false,
      cinemaId: json['cinemaId']?.toString(),
      cinemaName: json['cinemaName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'rowsCount': rowsCount,
      'seatsPerRow': seatsPerRow,
      'capacity': capacity, // Include calculated capacity
      'hallType': hallType,
      'screenSize': screenSize,
      'isDolbyAtmos': isDolbyAtmos,
      if (cinemaId != null) 'cinemaId': cinemaId,
      'cinemaName': cinemaName,
    };
  }

  String get displayInfo {
    return '$name - $capacity mjesta';
  }

  String get displayInfoDetailed {
    final features = <String>[];
    if (isDolbyAtmos) features.add('Dolby Atmos');
    if (screenSize.isNotEmpty) features.add(screenSize);
    if (hallType.isNotEmpty) features.add(hallType);
    
    final featuresText = features.isNotEmpty ? ' (${features.join(', ')})' : '';
    return '$name - $capacity mjesta$featuresText';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hall && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Hall(id: $id, name: $name, capacity: $capacity, cinema: $cinemaName)';
}
