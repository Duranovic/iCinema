import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async' show unawaited;
import '../../../../app/di/injection.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/router/app_router.dart' show routeObserver; // for RouteAware refresh
import '../../../../app/config/url_utils.dart';
import '../../data/reservations_refresh_bus.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/models/user_me.dart';
import '../../data/models/reservation.dart';
import '../bloc/reservations_cubit.dart';
import '../bloc/reservations_state.dart';
import '../bloc/profile_edit_cubit.dart';
import '../widgets/edit_profile_sheet.dart';
import '../../../reservations/presentation/details/reservation_details_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserMe> _meFuture;

  @override
  void initState() {
    super.initState();
    _meFuture = getIt<AuthApiService>().getMe();
  }

  void _refreshProfile() {
    setState(() {
      _meFuture = getIt<AuthApiService>().getMe();
    });
  }

  Future<void> _openEditProfile(UserMe currentUser) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => ProfileEditCubit(getIt<AuthApiService>()),
        child: EditProfileSheet(currentUser: currentUser),
      ),
    );

    if (result == true && mounted) {
      _refreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final fallbackEmail = auth.authState.email ?? 'email@domena.com';

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
          future: _meFuture,
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
                      onPressed: me != null && !loading
                          ? () => _openEditProfile(me)
                          : null,
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
                        _ReservationsTab(status: 'Active'),
                        _ReservationsTab(status: 'Past'),
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

class _ReservationsTab extends StatefulWidget {
  const _ReservationsTab({required this.status});
  final String status;

  @override
  State<_ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<_ReservationsTab> with RouteAware {
  late final ReservationsCubit _cubit;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!getIt.isRegistered<ReservationsCubit>()) {
      // Fallback if DI not yet registered (hot-reload safety)
      try {
        _cubit = getIt<ReservationsCubit>(param1: widget.status);
      } catch (_) {
        _cubit = ReservationsCubit(getIt<AuthApiService>(), status: widget.status);
      }
    } else {
      _cubit = getIt<ReservationsCubit>(param1: widget.status);
    }
    _cubit.loadInitial();
    _scroll.addListener(_onScroll);
    // Subscribe to reservations refresh events (e.g., cancel elsewhere)
    if (getIt.isRegistered<ReservationsRefreshBus>()) {
      getIt<ReservationsRefreshBus>().stream.listen((_) {
        if (mounted) {
          _cubit.loadInitial(pageSize: _cubit.state.pageSize);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to refresh when returning to this page
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final threshold = 200.0;
    final max = _scroll.position.maxScrollExtent;
    final curr = _scroll.position.pixels;
    if (max - curr <= threshold) {
      _cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    // Unsubscribe from route observer
    routeObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this tab from another page
    unawaited(_cubit.loadInitial(pageSize: _cubit.state.pageSize));
  }

  Future<void> _refresh() async {
    await _cubit.loadInitial(pageSize: _cubit.state.pageSize);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ReservationsCubit, ReservationsState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Greška pri učitavanju rezervacija: ${state.error}'),
              ),
            );
          }
          if (state.items.isEmpty) {
            return Center(
              child: Text(widget.status == 'Active' ? 'Nemate aktivnih rezervacija.' : 'Nema prošlih rezervacija.'),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final r = state.items[index];
                final date = _fmtDate(r.startTime);
                final time = _fmtTime(r.startTime);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      final idEnc = Uri.encodeComponent(r.reservationId);
                      final header = ReservationHeader(
                        reservationId: r.reservationId,
                        isCanceled: r.isCanceled,
                        totalPrice: null,
                        ticketsCount: r.ticketsCount,
                        startTime: r.startTime,
                        hallName: r.hallName,
                        cinemaName: r.cinemaName,
                        movieTitle: r.movieTitle,
                        posterUrl: r.posterUrl,
                      );
                      final result = await context.push('/reservations/$idEnc', extra: header);
                      if (result == true && context.mounted) {
                        // Use this tab's cubit instance for optimistic move and silent refresh
                        _cubit.markCanceledAndMove(r.reservationId);
                        unawaited(_cubit.loadInitial(pageSize: _cubit.state.pageSize));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (r.posterUrl != null && r.posterUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                resolveImageUrl(r.posterUrl)!,
                                width: 56,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 56,
                              height: 80,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.movie, size: 28),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.movieTitle,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 6), Text(date)]),
                                    Row(children: [const Icon(Icons.schedule, size: 16), const SizedBox(width: 6), Text(time)]),
                                    Row(children: [const Icon(Icons.local_activity, size: 16), const SizedBox(width: 6), Text('${r.ticketsCount} karata')]),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('${r.cinemaName} • ${r.hallName}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String _fmtDate(DateTime dt) {
  final d = dt.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd.$mm.$yyyy';
}

String _fmtTime(DateTime dt) {
  final d = dt.toLocal();
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$hh:$min';
}
