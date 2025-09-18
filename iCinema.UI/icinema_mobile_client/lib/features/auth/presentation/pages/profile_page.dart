import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/services/auth_service.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/models/user_me.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final fallbackEmail = auth.authState.email ?? 'email@domena.com';
    final meFuture = getIt<AuthApiService>().getMe();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Odjava',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/home');
            },
          ),
        ],
        ),
        body: FutureBuilder<UserMe>(
          future: meFuture,
          builder: (context, snap) {
            final loading = snap.connectionState == ConnectionState.waiting;
            final me = snap.data;
            final userName = me?.fullName.isNotEmpty == true ? me!.fullName : 'Korisnik';
            final email = me?.email.isNotEmpty == true ? me!.email : fallbackEmail;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loading) const LinearProgressIndicator(minHeight: 2),
                  if (loading) const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (me != null && me.roles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: me.roles
                          .map((r) => Chip(
                                label: Text(r),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 160,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('Uredi profil'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Aktivne'),
                        Tab(text: 'Prošle'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: const [
                        _ReservationList(active: true),
                        _ReservationList(active: false),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  const _ReservationList({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    // Placeholder cards matching mockup
    final items = [
      ('Film Jocker', '13.08.2025', '19:30', '5 karata'),
      ('Film Dedi', '12.08.2025', '18:00', '4 karte'),
    ];
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final it = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(it.$2),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Text(it.$3),
                    const SizedBox(width: 12),
                    const Icon(Icons.local_activity, size: 16),
                    const SizedBox(width: 6),
                    Text(it.$4),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(active ? 'Detalji' : 'Ponovo rezerviši'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
