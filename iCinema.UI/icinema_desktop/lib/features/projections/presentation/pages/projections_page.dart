import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icinema_desktop/features/projections/presentation/widgets/projections_calendar.dart';

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
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ProjectionsCalendar(),
      ),
    );
  }
}