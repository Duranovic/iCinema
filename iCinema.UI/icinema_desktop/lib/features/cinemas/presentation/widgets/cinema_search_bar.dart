import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cinemas_bloc.dart';
import '../bloc/cinemas_event.dart';
import '../bloc/cinemas_state.dart';
import '../../domain/city.dart';
import 'cinema_form_dialog.dart';

class CinemaSearchBar extends StatefulWidget {
  const CinemaSearchBar({super.key});

  @override
  State<CinemaSearchBar> createState() => _CinemaSearchBarState();
}

class _CinemaSearchBarState extends State<CinemaSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pretraži kina...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CinemasBloc>().add(SearchCinemas(''));
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
            ),
            onChanged: (value) {
              context.read<CinemasBloc>().add(SearchCinemas(value));
              setState(() {}); // Update to show/hide clear button
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCreateCinemaDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo kino'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateCinemaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CinemasBloc>(),
        child: const CinemaFormDialog(), // Use the new reusable dialog
      ),
    );
  }
}

