import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/search_cubit.dart';
import '../../data/models/movie_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent * 0.8) {
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pretraga'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (q) => context.read<SearchCubit>().onQueryChanged(q),
                decoration: InputDecoration(
                  hintText: 'Traži filmove…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildRecentSearches();
                  }
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SearchEmpty) {
                    return Center(
                      child: Text(
                        "Nema rezultata za '${state.query}'.",
                        style: TextStyle(color: color.onSurface.withOpacity(0.7)),
                      ),
                    );
                  }
                  if (state is SearchError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.read<SearchCubit>().retry(),
                            child: const Text('Pokušaj ponovo'),
                          )
                        ],
                      ),
                    );
                  }
                  if (state is SearchLoaded) {
                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final movie = state.items[index];
                        return _MovieResultTile(movie: movie);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    // Placeholder for future recent searches integration
    return Center(
      child: Text(
        'Unesite pojam za pretragu',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MovieResultTile extends StatelessWidget {
  final MovieModel movie;
  const _MovieResultTile({required this.movie});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: color.primary,
        child: const Icon(Icons.movie, color: Colors.white),
      ),
      title: Text(movie.title),
      subtitle: Text(
        [
          if (movie.genres.isNotEmpty) movie.formattedGenres,
          if (movie.releaseDate != null && movie.releaseDate!.year > 0) movie.releaseYear,
          if (movie.duration != null) movie.formattedDuration,
        ].join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        if (movie.id == null) return;
        context.push('/movie-details/${Uri.encodeComponent(movie.id!)}');
      },
    );
  }
}
