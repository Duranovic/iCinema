import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A reusable listener that shows a SnackBar when the provided [successSelector]
/// returns a non-null success string. After showing, it calls [onClear] to reset
/// the success message in the state.
class StateSuccessListener<B extends StateStreamable<S>, S> extends StatelessWidget {
  final String? Function(S state) successSelector;
  final VoidCallback onClear;
  final Widget child;

  const StateSuccessListener({
    super.key,
    required this.successSelector,
    required this.onClear,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (prev, curr) => successSelector(prev) != successSelector(curr) && successSelector(curr) != null,
      listener: (context, state) {
        final msg = successSelector(state);
        if (msg != null) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  msg,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green[800], // Darker green
                behavior: SnackBarBehavior.floating,
              ),
            );
          onClear();
        }
      },
      child: child,
    );
  }
}

