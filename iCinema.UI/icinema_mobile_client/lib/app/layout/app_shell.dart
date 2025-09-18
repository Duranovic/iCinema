import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../../features/auth/presentation/widgets/login_sheet.dart';
import '../constants/navigation.dart';
import '../constants/route_paths.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const AppShell({
    required this.child,
    required this.currentLocation,
    super.key,
  });

  int get _selectedIndex {
    return routePaths
        .indexWhere((p) => currentLocation.startsWith(p))
        .clamp(0, routePaths.length - 1);
  }

  int? get _selectedIndexOrNull {
    if (_selectedIndex >= mainNavigationItems.length) {
      return null;
    }
    return _selectedIndex;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: child,
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
