import 'package:flutter/material.dart';

const mainNavigationItems = [
  NavigationRailDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: Text('Početna'),
    padding: EdgeInsets.all(10),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.movie_outlined),
    selectedIcon: Icon(Icons.movie),
    label: Text('Filmovi'),
    padding: EdgeInsets.all(10),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.schedule_outlined),
    selectedIcon: Icon(Icons.schedule),
    label: Text('Projekcije'),
    padding: EdgeInsets.all(10),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.local_movies_outlined),
    selectedIcon: Icon(Icons.local_movies),
    label: Text('Kina'),
    padding: EdgeInsets.all(10),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.bar_chart_outlined),
    selectedIcon: Icon(Icons.bar_chart),
    label: Text('Izvještaji'),
    padding: EdgeInsets.all(10),
  ),
];
