import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Events for the LoginBloc
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user submits the login form
class LoginSubmitted extends LoginEvent {
  /// Key to validate the form
  final GlobalKey<FormState> formKey;

  /// Email credential
  final String email;

  /// Password credential
  final String password;

  const LoginSubmitted(this.formKey, this.email, this.password);

  @override
  List<Object?> get props => [formKey, email, password];
}
