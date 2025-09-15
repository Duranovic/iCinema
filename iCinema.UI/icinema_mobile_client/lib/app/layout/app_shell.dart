import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
