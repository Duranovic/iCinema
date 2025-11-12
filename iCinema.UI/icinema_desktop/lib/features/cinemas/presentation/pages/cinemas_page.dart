import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../bloc/cinemas_bloc.dart';
import '../bloc/cinemas_event.dart';
import '../bloc/cinemas_state.dart';
import '../widgets/cinema_search_bar.dart';
import '../widgets/cinema_list_view.dart';
import '../widgets/cinema_detail_view.dart';
import 'package:icinema_desktop/app/widgets/state_error_listener.dart';

class CinemasPage extends StatelessWidget {
  const CinemasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CinemasBloc>()..add(LoadCinemas()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upravljanje kinima'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: StateErrorListener<CinemasBloc, CinemasState>(
          errorSelector: (s) => s is CinemasError ? s.message : null,
          onClear: () => context.read<CinemasBloc>().add(LoadCinemas()),
          child: const CinemasPageContent(),
        ),
      ),
    );
  }
}

class CinemasPageContent extends StatelessWidget {
  const CinemasPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CinemasBloc, CinemasState>(
      builder: (context, state) {
        if (state is CinemasLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is CinemasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CinemasBloc>().add(LoadCinemas());
                  },
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          );
        }

        if (state is CinemasLoaded) {
          return Row(
            children: [
              // Left sidebar with search and cinema list
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CinemaSearchBar(),
                      Expanded(
                        child: CinemaListView(
                          cinemas: state.filteredCinemas,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side - empty state or detail view
              Expanded(
                flex: 2,
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_movies_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Odaberite kino za pregled detalja',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (state is CinemaSelected) {
          return Row(
            children: [
              // Left sidebar with search and cinema list
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CinemaSearchBar(),
                      Expanded(
                        child: CinemaListView(
                          cinemas: state.filteredCinemas,
                          selectedCinemaId: state.cinema.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side - cinema detail view
              Expanded(
                flex: 2,
                child: CinemaDetailView(cinema: state.cinema),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
