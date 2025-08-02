import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icinema_desktop/app/constants/navigation.dart';
import 'package:icinema_desktop/app/constants/route_paths.dart';
import 'package:icinema_desktop/app/enums/user_actions.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const AppShell(
      {required this.child, required this.currentLocation, super.key});

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
        body: Row(children: [
      SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: NavigationRail(
                    selectedIndex: _selectedIndexOrNull,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (int index) {
                      _onItemTapped(context, index);
                    },
                    destinations: mainNavigationItems),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PopupMenuButton<UserAction>(
                  tooltip: 'Open user menu',
                  child: const CircleAvatar(
                    radius: 25,
                  ),
                  onSelected: (action) {
                    if (action == UserAction.profile) {
                      context.go('/profile');
                    } else {
                      // TODO: Implement logout functionality
                      context.go('/login');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: UserAction.profile, child: Text('Profile')),
                    PopupMenuItem(
                        value: UserAction.logout,
                        child: Text(
                          'Log out',
                          style: TextStyle(color: Colors.red),
                        )),
                  ],
                ),
              ),
            ],
          )),
      const VerticalDivider(thickness: 1, width: 1),
      Expanded(
          child:
              Padding(padding: const EdgeInsetsGeometry.all(40), child: child)),
    ]));
  }
}
