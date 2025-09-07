import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_desktop/features/projections/presentation/widgets/projections_calendar.dart';
import 'package:icinema_desktop/features/projections/presentation/widgets/cinema_selector.dart';
import 'package:icinema_desktop/app/di/injection.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_bloc.dart';
import 'package:icinema_desktop/features/projections/presentation/bloc/projections_event.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:icinema_desktop/features/movies/presentation/bloc/movies_event.dart';

class ProjectionsPage extends StatefulWidget {
  const ProjectionsPage({super.key});

  @override
  State<ProjectionsPage> createState() => _ProjectionsPage();
}

class _ProjectionsPage extends State<ProjectionsPage> {
  int? editingIndex;
  bool isAdding = false;

  void openEdit(int index) => setState(() {
    editingIndex = index;
    isAdding = false;
  });

  void openAdd() => setState(() {
    editingIndex = null;
    isAdding = true;
  });

  void closePanel() => setState(() {
    editingIndex = null;
    isAdding = false;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<ProjectionsBloc>()
              ..add(LoadCinemas())
              ..add(LoadProjectionsForMonth(DateTime.now())),
          ),
          BlocProvider(
            create: (_) => getIt<MoviesBloc>()
              ..add(LoadMovies()),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              CinemaSelector(),
              Expanded(
                child: ProjectionsCalendar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}