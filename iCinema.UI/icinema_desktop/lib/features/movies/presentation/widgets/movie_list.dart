import 'package:flutter/material.dart';
import 'package:icinema_desktop/widgets/heading.dart';
import '../../domain/movie.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class MovieList extends StatefulWidget {
  final List<Movie> movies;
  final void Function(int) onEdit;
  final void Function(int) onDelete;
  final VoidCallback onAdd;

  const MovieList({
    super.key,
    required this.movies,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  late final TextEditingController _searchCtrl;
  late List<Movie> filteredMovies = widget.movies;

  void filterMovies(String key) {
    final query = _searchCtrl.text.trim().toLowerCase();

    setState(() {
      filteredMovies = query.isEmpty
          ? widget.movies
          : widget.movies.where((m) {
        final inTitle = m.title.toLowerCase().contains(query);
        final inDesc = (m.description).toLowerCase().contains(query);
        final inGenres = m.genres
            .any((g) => g.toLowerCase().contains(query));

        return inTitle || inDesc || inGenres;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header and Add button
        Row(
          children: [
            Expanded(
              child: Text(
                'Filmovi',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj film'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Pretraži filmove',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 400,
          child: TextField(
            controller: _searchCtrl,
            onChanged: filterMovies,
            decoration: InputDecoration(
              hintText: 'Pretraži po nazivu, opisu ili žanru...',
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              isDense: true,
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Movie list
        Expanded(
          child: filteredMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nema filmova',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dodajte prvi film klikom na dugme "Dodaj film"',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filteredMovies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) => Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: _PosterThumb(url: filteredMovies[idx].posterUrl),
                      title: Text(
                        filteredMovies[idx].title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Godina: ${filteredMovies[idx].releaseDate?.year ?? "Nepoznato"}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          if (filteredMovies[idx].genres.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              children: filteredMovies[idx].genres.take(3).map((genre) => 
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    genre,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                            onPressed: () => widget.onEdit(idx),
                            tooltip: 'Uredi film',
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colorScheme.error),
                            onPressed: () => widget.onDelete(idx),
                            tooltip: 'Obriši film',
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PosterThumb extends StatelessWidget {
  final String? url;
  const _PosterThumb({this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double w = 56; // compact thumbnail
    const double h = 80; // ~1.42 ratio

    Widget placeholder = Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: cs.onSurface.withOpacity(0.5)),
    );

    if (url == null || url!.isEmpty) return placeholder;

    // Build absolute URL using Dio baseUrl if needed
    String buildAbsoluteUrl(String input) {
      if (input.startsWith('http://') || input.startsWith('https://')) return input;
      try {
        if (GetIt.I.isRegistered<Dio>()) {
          final base = GetIt.I<Dio>().options.baseUrl;
          if (base.isNotEmpty) {
            return Uri.parse(base).resolve(input.startsWith('/') ? input.substring(1) : input).toString();
          }
        }
      } catch (_) {}
      return input; // fallback
    }

    final resolvedUrl = buildAbsoluteUrl(url!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        resolvedUrl,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: w,
            height: h,
            color: cs.surfaceVariant.withOpacity(0.3),
            alignment: Alignment.center,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}
