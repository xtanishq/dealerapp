import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String gender;
  final String phone;
  final String password;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.gender,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, gender, phone, password];
}

class LogoutEvent extends AuthEvent {}
