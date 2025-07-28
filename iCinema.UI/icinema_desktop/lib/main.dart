import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum _UserAction { profile, logout }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                  height: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: NavigationRail(
                          selectedIndex: 0,
                          labelType: NavigationRailLabelType.all,
                          onDestinationSelected: (int index) {
                            print("SELECTED INDEX: ");
                            print(index);
                          },
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.home_outlined),
                              selectedIcon: Icon(Icons.home),
                              label: Text('Početna'),
                              padding: const EdgeInsets.all(10),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.movie_outlined),
                              selectedIcon: Icon(Icons.movie),
                              label: Text('Filmovi'),
                              padding: const EdgeInsets.all(10),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.schedule_outlined),
                              selectedIcon: Icon(Icons.schedule),
                              label: Text('Projekcije'),
                              padding: const EdgeInsets.all(10),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.people_outline),
                              selectedIcon: Icon(Icons.people),
                              label: Text('Korisnici'),
                              padding: const EdgeInsets.all(10),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.bar_chart_outlined),
                              selectedIcon: Icon(Icons.bar_chart),
                              label: Text('Izvještaji'),
                              padding: const EdgeInsets.all(10),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PopupMenuButton<_UserAction>(
                          tooltip: 'Open user menu',
                          child: const CircleAvatar(
                            radius: 25,
                          ),
                          onSelected: (action) {
                            if (action == _UserAction.profile) {
                              // navigate…
                            } else {
                              // logout…
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: _UserAction.profile,
                                child: Text('Profile')),
                            PopupMenuItem(
                                value: _UserAction.logout,
                                child: Text(
                                  'Log out',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ));
  }
}
