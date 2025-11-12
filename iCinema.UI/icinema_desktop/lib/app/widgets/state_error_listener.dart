import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A reusable listener that shows a SnackBar when the provided [errorSelector]
/// returns a non-null error string. After showing, it calls [onClear] to reset
/// the error in the state to avoid retriggering on rebuilds.
class StateErrorListener<B extends StateStreamable<S>, S> extends StatelessWidget {
  final String? Function(S state) errorSelector;
  final VoidCallback onClear;
  final Widget child;

  const StateErrorListener({
    super.key,
    required this.errorSelector,
    required this.onClear,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (prev, curr) => errorSelector(prev) != errorSelector(curr) && errorSelector(curr) != null,
      listener: (context, state) {
        final msg = errorSelector(state) ?? 'Došlo je do greške.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
        onClear();
      },
      child: child,
    );
  }
}
