import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final StorageService storageService;

  AuthBloc({
    required this.apiService,
    required this.storageService,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await storageService.getToken();
      final user = await storageService.getUser();

      if (token != null && user != null) {
        emit(AuthAuthenticated(user, token));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
        emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await apiService.login(event.email, event.password);

      final token = response['access_token'] ?? '';
      final userData = response['user'] ?? {};
      final user = User.fromJson(userData);

      await storageService.saveToken(token);
      await storageService.saveUser(user);

      emit(AuthAuthenticated(user, token));
    } catch (e) {
      emit(AuthError('Login failed. Please check your credentials.'));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await apiService.register(
        name: event.name,
        email: event.email,
        gender: event.gender,
        phone: event.phone,
        password: event.password,
      );

      final loginResponse = await apiService.login(event.email, event.password);
      
      final token = loginResponse['access_token'] ?? '';
      final userData = loginResponse['user'] ?? {};
      final user = User.fromJson(userData);

      await storageService.saveToken(token);
      await storageService.saveUser(user);

      emit(AuthAuthenticated(user, token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await storageService.clearAll();
    
    emit(AuthUnauthenticated());
  }
}
