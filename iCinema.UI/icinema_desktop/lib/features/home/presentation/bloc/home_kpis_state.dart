part of 'home_kpis_cubit.dart';

abstract class HomeKpisState {}

class HomeKpisLoading extends HomeKpisState {}

class HomeKpisLoaded extends HomeKpisState {
  final HomeKpisDto data;
  HomeKpisLoaded(this.data);
}

class HomeKpisError extends HomeKpisState {
  final String message;
  HomeKpisError(this.message);
}
