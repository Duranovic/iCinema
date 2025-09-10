import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/home_service.dart';
import '../../data/home_kpis_dto.dart';

part 'home_kpis_state.dart';

@injectable
class HomeKpisCubit extends Cubit<HomeKpisState> {
  final HomeService _service;
  HomeKpisCubit(this._service) : super(HomeKpisLoading());

  Future<void> load() async {
    emit(HomeKpisLoading());
    try {
      final dto = await _service.getKpis();
      emit(HomeKpisLoaded(dto));
    } catch (e) {
      emit(HomeKpisError(e.toString()));
    }
  }
}
