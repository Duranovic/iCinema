import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import '../widgets/movie_list.dart';
import '../widgets/movie_edit_form.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje filmovima'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MoviesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Greška pri učitavanju filmova',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (state is MoviesLoaded) {
            final movies = state.movies;
            const double sidebarWidth = 500;
            final bool showSidebar = editingIndex != null || isAdding;
            
            return Row(
              children: [
                // Main content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: MovieList(
                      movies: movies,
                      onEdit: openEdit,
                      onDelete: (index) {
                        final movie = movies[index];
                        context.read<MoviesBloc>().add(DeleteMovie(movie.id));
                        // Optionally, show snackbar, reset editing if deleting current
                        if (editingIndex == index) closePanel();
                      },
                      onAdd: openAdd,
                    ),
                  ),
                ),
                // Sidebar - appears/disappears instantly
                if (showSidebar)
                  Material(
                    color: colorScheme.surface,
                    elevation: 0,
                    shadowColor: colorScheme.shadow,
                    child: Container(
                      width: sidebarWidth,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                      ),
                      child: MovieEditForm(
                        key: ValueKey('form_${editingIndex}_${isAdding}'),
                        movie: editingIndex != null ? movies[editingIndex!] : null,
                        genres: state.genres,
                        ageRatings: state.ageRatings,
                        onClose: closePanel,
                        onSave: (movie, posterPath, mimeType) {
                          if (isAdding) {
                            context
                                .read<MoviesBloc>()
                                .add(AddMovie(movie, posterPath: posterPath, mimeType: mimeType));
                          } else {
                            context
                                .read<MoviesBloc>()
                                .add(UpdateMovie(movie, posterPath: posterPath, mimeType: mimeType));
                          }
                          closePanel();
                        },
                      ),
                    ),
                  ),
              ],
            );
          }
          // Initial or unknown state
          return const SizedBox();
        },
      ),
      floatingActionButton: null, // All actions in the UI itself
    );
  }
}