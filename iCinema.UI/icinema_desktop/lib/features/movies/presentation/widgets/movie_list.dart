import 'package:flutter/material.dart';
import 'package:icinema_desktop/widgets/heading.dart';
import '../../domain/movie.dart';

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
    return Column(
      children: [
        // Header and Add button
        Row(
          children: [
            const Expanded(child: Heading("Filmovi")),
            ElevatedButton.icon(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2, // 30% of screen width
            child: TextField(
              controller: _searchCtrl,
              onChanged: filterMovies,
              decoration: const InputDecoration(
                hintText: 'Pretraga',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12,),
        // Movie table
        Expanded(
          child: filteredMovies.isEmpty
              ? const Center(child: Text('Nema filmova.'))
              :
          ListView.separated(
            itemCount: filteredMovies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12), // space between items
            itemBuilder: (context, idx) => Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white, // Card background
                borderRadius: BorderRadius.circular(12), // Rounded corners
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(filteredMovies[idx].title),
                subtitle: Text('Godina: ${filteredMovies[idx].releaseDate?.year ?? "Nepoznato"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => widget.onEdit(idx),
                      tooltip: 'Uredi',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => widget.onDelete(idx),
                      tooltip: 'Obriši',
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
