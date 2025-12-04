import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icinema_desktop/app/di/injection.dart';
import 'package:icinema_desktop/app/services/auth_service.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) async {
                    if (state is LoginSuccess) {
                      // Save session and let router redirect to /home
                      print('Login success, setting session...');
                      await getIt<AuthService>().setSession(
                        token: state.loginResponse.token,
                        expiresAt: state.loginResponse.expiresAt,
                      );
                      print('Session set, auth state: ${getIt<AuthService>().authState.value}');
                    } else if (state is LoginFailure) {
                      print('Login failure: ${state.message}');
                      final media = MediaQuery.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Container(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Text(
                              state.friendlyError(state.message),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          backgroundColor: Colors.red[700],
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                            right: 32,
                            bottom: 32,
                            left: media.size.width > 700 ? media.size.width - 390 : 16, // if wide screen, push right
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 3),
                          elevation: 6,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo or App Name
                          Center(
                            child: Column(
                              children: [
                                // Replace with your logo if needed
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: colorScheme.primary,
                                  child: const Icon(Icons.local_movies, color: Colors.white, size: 32),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'iCinema Administrator',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Prijavi se na svoj račun",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: 'Email',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) =>
                            v != null && v.contains('@') ? null : 'Unesi valjan email',
                          ),
                          const SizedBox(height: 16),
                          // Password
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscureText,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: 'Lozinka',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (v) =>
                            v != null && v.length >= 6 ? null : 'Lozinka mora sadržavati najmanje 6 karaktera',
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 16),
                          // Login button / Loading
                          SizedBox(
                            height: 48,
                            child: state is LoginLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  context.read<LoginBloc>().add(
                                    LoginSubmitted(
                                      _formKey,
                                      _emailCtrl.text,
                                      _passCtrl.text,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Prijavi se'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}