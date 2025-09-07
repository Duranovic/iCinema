import 'package:flutter/material.dart';

class Projection {
  final String? id;
  final String movieTitle;
  final String hall;
  final TimeOfDay time;
  final DateTime date; // normalized day (no time component)
  final String? cinemaId;
  final String? hallId;
  final String? movieId;
  final double price;
  final bool isActive;

  Projection({
    required this.movieTitle, 
    required this.hall, 
    required this.time, 
    required this.date, 
    required this.price,
    this.id,
    this.cinemaId,
    this.hallId,
    this.movieId,
    this.isActive = true, // Default to true as requested
  });

  factory Projection.fromJson(Map<String, dynamic> json) => Projection(
    id: json['id'],
    movieTitle: json['movieTitle'] ?? '',
    hall: json['hallName'] ?? '', // Use hallName from backend
    time: _parseTimeOfDay(json),
    date: _parseDateOnly(json),
    cinemaId: json['cinemaId']?.toString(),
    hallId: json['hallId']?.toString(),
    movieId: json['movieId']?.toString(),
    price: (json['price'] ?? 0.0).toDouble(),
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() {
    // Combine date and time into a single DateTime for startTime
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    return {
      if (id != null) 'id': id,
      'movieTitle': movieTitle,
      'hall': hall,
      'startTime': startTime.toIso8601String(),
      if (cinemaId != null) 'cinemaId': cinemaId,
      if (hallId != null) 'hallId': hallId,
      if (movieId != null) 'movieId': movieId,
      'price': price,
      'isActive': isActive,
    };
  }
}

TimeOfDay _parseTimeOfDay(Map<String, dynamic> json) {
  final raw = json['startTime'] ?? json['time'] ?? json['date'] ?? json['startsAt'];
  if (raw is String) {
    final dt = DateTime.tryParse(raw);
    if (dt != null) return TimeOfDay.fromDateTime(dt);
  }
  return const TimeOfDay(hour: 0, minute: 0);
}

DateTime _parseDateOnly(Map<String, dynamic> json) {
  final raw = json['startTime'] ?? json['time'] ?? json['date'] ?? json['startsAt'];
  if (raw is String) {
    final dt = DateTime.tryParse(raw);
    if (dt != null) return DateUtils.dateOnly(dt);
  }
  return DateUtils.dateOnly(DateTime.now());
}