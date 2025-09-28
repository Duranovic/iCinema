import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../../features/auth/presentation/widgets/login_sheet.dart';
import '../constants/navigation.dart';
import '../constants/route_paths.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const AppShell({
    required this.child,
    required this.currentLocation,
    super.key,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  late final NotificationsCubit _notificationsCubit;

  int get _selectedIndex {
    return routePaths
        .indexWhere((p) => widget.currentLocation.startsWith(p))
        .clamp(0, routePaths.length - 1);
  }

  int? get _selectedIndexOrNull {
    if (_selectedIndex >= mainNavigationItems.length) {
      return null;
    }
    return _selectedIndex;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Create notifications cubit once and load items
    _notificationsCubit = GetIt.I<NotificationsCubit>();
    _notificationsCubit.load(top: 50);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh badge when app returns to foreground
      _notificationsCubit.refresh();
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    // If tapping Profile and not authenticated, show login sheet without leaving current page
    final profileIndex = routePaths.indexOf('/profile');
    if (index == profileIndex) {
      final auth = GetIt.I<AuthService>();
      if (!auth.authState.isAuthenticated) {
        showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => const LoginSheet(),
        ).then((result) {
          if (GetIt.I<AuthService>().authState.isAuthenticated || result == true) {
            context.go('/profile');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Niste prijavljeni.')),
            );
          }
        });
        return; // stay on current page until login success
      }
    }
    context.go(routePaths[index]);
  }

  Widget _bellWithBadge() {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: _notificationsCubit,
      builder: (context, state) {
        int unread = 0;
        if (state is NotificationsLoaded) unread = state.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Obavijesti',
              icon: const Icon(Icons.notifications_none),
              onPressed: () => context.push('/notifications'),
            ),
            if (unread > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unread > 9 ? '9+' : unread.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iCinema'),
        actions: [
          _bellWithBadge(),
        ],
      ),
      body: SafeArea(
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndexOrNull ?? 0,
        onTap: (index) => _onItemTapped(context, index),
        items: mainNavigationItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
