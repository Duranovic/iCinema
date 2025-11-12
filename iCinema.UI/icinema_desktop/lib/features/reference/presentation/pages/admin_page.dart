import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administracija'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Šifrarnici',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Države'),
                subtitle: const Text('Upravljanje listom država'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/admin/countries'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city_outlined),
                title: const Text('Gradovi'),
                subtitle: const Text('Upravljanje listom gradova'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/admin/cities'),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Žanrovi'),
              subtitle: const Text('Upravljanje listom žanrova'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin/genres'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.movie_creation_outlined),
              title: const Text('Režiseri'),
              subtitle: const Text('Upravljanje listom režisera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin/directors'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Glumci'),
              subtitle: const Text('Upravljanje listom glumaca'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin/actors'),
            ),
          ),
        ],
      ),
    ),
  );
}
}
