import 'package:flutter/material.dart';

const mainNavigationItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: 'Početna',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.movie_outlined),
    activeIcon: Icon(Icons.movie),
    label: 'Repertoar',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.qr_code_scanner_outlined),
    activeIcon: Icon(Icons.qr_code_scanner),
    label: 'Validacija',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outlined),
    activeIcon: Icon(Icons.person),
    label: 'Profil',
  ),
];
