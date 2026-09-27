import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../core/constants.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'PRINCIPAL', 'CAMPUS_HEAD', 'ADMIN', 'FACULTY', 'STUDENT'
  final String? department;
  final String? cabin;
  final String? rollNo;
  final String? token;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.cabin,
    this.rollNo,
    this.token,
  });

  bool get isPrincipal => role == 'PRINCIPAL' || role == 'CAMPUS_HEAD' || role == 'ADMIN';
  bool get isTeacher => role == 'FACULTY';
  bool get isStudent => role == 'STUDENT';
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final AuthUser? user;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  // Quick Login (1-Tap direct role preview)
  Future<void> quickLogin(String accountKey) async {
    final account = AppConstants.quickAccounts[accountKey];
    if (account == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    // Try real backend login
    final res = await ApiService().login(account['email']!, account['password']!);
    String? token;
    String id = 'srk_${accountKey}_id';

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      token = data['tokens']?['accessToken'] ?? data['token'];
      if (data['user'] != null && data['user']['id'] != null) {
        id = data['user']['id'];
      }
    }

    final user = AuthUser(
      id: id,
      name: account['name']!,
      email: account['email']!,
      role: account['role']!,
      department: account['dept'],
      cabin: account['cabin'],
      rollNo: account['rollNo'],
      token: token ?? 'demo_token_srk',
    );

    ApiService().setAuthToken(user.token);
    SocketService().init(user.token!);

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      user: user,
    );
  }

  // Custom Credentials Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await ApiService().login(email, password);
    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      final u = data['user'] ?? {};
      final token = data['tokens']?['accessToken'] ?? data['token'] ?? 'jwt_token';

      final user = AuthUser(
        id: u['id'] ?? u['_id'] ?? 'user_1',
        name: u['name'] ?? email.split('@')[0],
        email: email,
        role: u['role'] ?? 'STUDENT',
        department: u['department'] ?? 'SRK Campus',
        cabin: u['cabin'],
        rollNo: u['rollNo'],
        token: token,
      );

      ApiService().setAuthToken(token);
      SocketService().init(token);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
      return true;
    } else {
      // Fallback matching
      for (final key in AppConstants.quickAccounts.keys) {
        final acc = AppConstants.quickAccounts[key]!;
        if (acc['email']?.toLowerCase() == email.trim().toLowerCase()) {
          return quickLogin(key).then((_) => true);
        }
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: res['message'] ?? 'Invalid email or password',
      );
      return false;
    }
  }

  void logout() {
    ApiService().setAuthToken(null);
    SocketService().disconnect();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
