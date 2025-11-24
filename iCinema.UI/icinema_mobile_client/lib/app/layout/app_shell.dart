import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../../features/auth/presentation/widgets/login_sheet.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/auth/data/models/user_me.dart';
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
  UserMe? _currentUser;
  bool _isLoadingUser = false;

  List<BottomNavigationBarItem> get _visibleNavigationItems {
    final isStaff = _currentUser?.roles.any((role) => 
      role.toLowerCase() == 'staff' ||
      role.toLowerCase() == 'admin'
    ) ?? false;

    if (isStaff) {
      return mainNavigationItems; // Show all including Validacija
    } else {
      // Hide Validacija tab (index 2)
      return [
        mainNavigationItems[0], // Početna
        mainNavigationItems[1], // Repertoar
        mainNavigationItems[3], // Profil (skip Validacija at index 2)
      ];
    }
  }

  List<String> get _visibleRoutePaths {
    final isStaff = _currentUser?.roles.any((role) =>
      role.toLowerCase() == 'staff' ||
      role.toLowerCase() == 'admin'
    ) ?? false;

    if (isStaff) {
      return routePaths;
    } else {
      // Remove /validation from paths
      return [
        routePaths[0], // /home
        routePaths[1], // /movies
        routePaths[3], // /profile (skip /validation at index 2)
        routePaths[4], // /login
      ];
    }
  }

  int get _selectedIndex {
    return _visibleRoutePaths
        .indexWhere((p) => widget.currentLocation.startsWith(p))
        .clamp(0, _visibleRoutePaths.length - 1);
  }

  int? get _selectedIndexOrNull {
    if (_selectedIndex >= _visibleNavigationItems.length) {
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
    // Load user info to check roles
    _loadUserInfo();
    // Listen to auth state changes
    GetIt.I<AuthService>().authState.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    // When auth state changes (login/logout), reload user info
    if (GetIt.I<AuthService>().authState.isAuthenticated) {
      _loadUserInfo();
    } else {
      // User logged out, clear user info
      if (mounted) {
        setState(() {
          _currentUser = null;
        });
      }
    }
  }

  Future<void> _loadUserInfo() async {
    final auth = GetIt.I<AuthService>();
    if (!auth.authState.isAuthenticated) {
      return;
    }

    if (_isLoadingUser) return;
    setState(() => _isLoadingUser = true);

    try {
      final user = await GetIt.I<AuthApiService>().getMe();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GetIt.I<AuthService>().authState.removeListener(_onAuthStateChanged);
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
    final profileIndex = _visibleRoutePaths.indexOf('/profile');
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
    context.go(_visibleRoutePaths[index]);
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
        items: _visibleNavigationItems,
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
