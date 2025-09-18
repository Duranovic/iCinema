import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/services/auth_service.dart';
import '../widgets/login_sheet.dart';

class LoginSheetLauncherPage extends StatefulWidget {
  const LoginSheetLauncherPage({super.key});

  @override
  State<LoginSheetLauncherPage> createState() => _LoginSheetLauncherPageState();
}

class _LoginSheetLauncherPageState extends State<LoginSheetLauncherPage> {
  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_opened) {
      _opened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => const LoginSheet(),
        );
        // If user logged in or confirmed, go to profile; otherwise pop back.
        final loggedIn = getIt<AuthService>().authState.isAuthenticated;
        if (mounted) {
          if (loggedIn || result == true) {
            context.go('/profile');
          } else {
            context.pop();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Transparent placeholder page behind the sheet
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
