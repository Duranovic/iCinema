// Simple date gating helpers used by the calendar UI
import 'package:flutter/material.dart';

/// Returns true if [day] is before the current day (i.e., in the past).
bool isPastDay(DateTime day) {
  final d = DateUtils.dateOnly(day);
  final today = DateUtils.dateOnly(DateTime.now());
  return d.isBefore(today);
}

/// Returns true if [day] is before tomorrow (covers past days and today).
/// Useful when creation should only be allowed starting from tomorrow.
bool isBeforeTomorrow(DateTime day) {
  final d = DateUtils.dateOnly(day);
  final tomorrow = DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  return d.isBefore(tomorrow);
}
