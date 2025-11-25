import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../domain/usecases/validate_ticket_usecase.dart';
import '../bloc/validation_cubit.dart';
import '../widgets/validation_result_dialog.dart';
import 'qr_scanner_page.dart';

class ValidationPage extends StatelessWidget {
  const ValidationPage({super.key});

  void _openScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => ValidationCubit(getIt<ValidateTicketUseCase>())..startScanning(),
          child: const QrScannerPage(),
        ),
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    final cubit = ValidationCubit(getIt<ValidateTicketUseCase>());
    final scaffoldContext = context; // Capture context

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: BlocListener<ValidationCubit, ValidationState>(
          listener: (context, state) {
            if (state is ValidationSuccess) {
              Navigator.of(ctx, rootNavigator: true).pop(); // Close input dialog
              _showValidationResult(scaffoldContext, state.result);
            } else if (state is ValidationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Unesi kod ručno'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Kod karte',
                    hintText: 'Unesite kod sa karte',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Otkaži'),
              ),
              BlocBuilder<ValidationCubit, ValidationState>(
                builder: (context, state) {
                  final isLoading = state is ValidationLoading;
                  return FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final code = controller.text.trim();
                            if (code.isNotEmpty) {
                              cubit.validateTicket(code);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Validiraj'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationResult(BuildContext context, result) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => ValidationResultDialog(
        result: result,
        onClose: () {
          Navigator.of(ctx, rootNavigator: true).pop();
        },
        onScanAnother: () {
          Navigator.of(ctx, rootNavigator: true).pop();
          // Wait for dialog dismiss animation then show manual entry
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              _showManualEntryDialog(context);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 120,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 32),
              Text(
                'Validacija karata',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Skenirajte QR kod na karti kako biste validirali ulazak.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => _openScanner(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Skeniraj QR kod'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _showManualEntryDialog(context),
                icon: const Icon(Icons.keyboard, size: 20),
                label: const Text('ili unesi kod ručno'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
