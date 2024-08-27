import 'dart:convert';
import 'dart:developer';

import 'package:attendance/api/userApi.dart';
import 'package:attendance/constants.dart';
import 'package:attendance/models/userModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

final authPageProvider =
    StateNotifierProvider<UserAuth, AuthState>((ref) => UserAuth(ref: ref));

class UserAuth extends StateNotifier<AuthState> {
  final StateNotifierProviderRef ref;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  UserAuth({required this.ref})
      : super(
          AuthState(
            user: User(
              id: '',
              name: '',
              companyName: '',
              email: '',
              password: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            loginStatus: AuthStatus.initial,
            role: Role.user,
            authStatus: AuthStatus.initial,
            fpasswordStatus: AuthStatus.initial,
            appStatus: AppStatus.initial,
            token: "",
          ),
        ) {
    _loadUserState();
  }

  Future<void> _loadUserState() async {
    try {
      final accessToken = await storage.read(key: 'AT');
      if (accessToken != null && accessToken.isNotEmpty) {
        state = state.copyWith(token: accessToken);
        if (!JwtDecoder.isExpired(accessToken)) {
          final decodedToken = JwtDecoder.decode(accessToken);
          final userEmail = decodedToken['email'];
          final userRole = decodedToken['role'];

          // Example: Fetch user info if needed
          await getUserInfo();

          state = state.copyWith(
            appStatus: AppStatus.authenticated,
            role: Role.values.firstWhere((r) => r.toString() == userRole),
          );
        } else {
          await logout();
        }
      } else {
        state = state.copyWith(appStatus: AppStatus.unAuthenticated);
      }
    } catch (e) {
      print("Error loading user state: $e");
      state = state.copyWith(appStatus: AppStatus.unAuthenticated);
    }
  }

  Future<bool> checkAuthentication() async {
    final accessToken = await storage.read(key: 'AT');
    state = state.copyWith(token: accessToken);

    if (accessToken == null || accessToken.isEmpty) {
      state = state.copyWith(appStatus: AppStatus.unAuthenticated);
      return false;
    }

    try {
      if (!JwtDecoder.isExpired(accessToken)) {
        final decodedToken = JwtDecoder.decode(accessToken);
        final emailId = decodedToken['email'];
        final role = decodedToken['role'];

        state = state.copyWith(appStatus: AppStatus.authenticated);
        return true;
      } else {
        state = state.copyWith(appStatus: AppStatus.unAuthenticated);
        await logout();
        return false;
      }
    } catch (e) {
      print("CheckAuthentication Error: $e");
      state = state.copyWith(appStatus: AppStatus.unAuthenticated);
      await logout();
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(loginStatus: AuthStatus.processing);
      String url = '$appBaseUrl/auth/login';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['token'] as String?;
        log(state.token.toString());
        if (accessToken == null) {
          throw Exception("Invalid response format: 'token' is missing");
        }

        await storage.write(key: 'AT', value: accessToken);

        final userData = data['user'] as Map<String, dynamic>?;

        if (userData != null) {
          state = state.copyWith(
            user: User.fromJson(userData),
            token: accessToken,
            appStatus: AppStatus.authenticated,
            loginStatus: AuthStatus.processed,
          );
        } else {
          state = state.copyWith(
            token: accessToken,
            appStatus: AppStatus.authenticated,
            loginStatus: AuthStatus.processed,
          );
        }
      } else {
        state = state.copyWith(loginStatus: AuthStatus.error);
        print('Sign-in failed: ${response.body}');
      }
    } catch (e) {
      state = state.copyWith(loginStatus: AuthStatus.error);
      print('Sign-in error: $e');
    }
  }

  Future<void> signUp(String name, String email, String password,
      String companyName, String confirmPassword) async {
    try {
      state = state.copyWith(authStatus: AuthStatus.processing);

      final response = await UserHelper.signUp(
        emailId: email,
        name: name,
        companyName: companyName,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];
        print('Sign-up successful: $message');
        state = state.copyWith(authStatus: AuthStatus.processed);

        final pin = data['pin'];
        if (pin != null) {
          print('Generated PIN: $pin');
        }
      } else {
        state = state.copyWith(authStatus: AuthStatus.error);
        print('Sign-up failed: ${response.body}');
      }
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.error);
      print('Sign-up error: $e');
    }
  }

  Future<void> getUserInfo() async {
    try {
      final response =
          await UserHelper.userInfo(accessToken: state.token ?? '');

      // Log response details
      log('Access Token: ${state.token}');
      log('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Log the parsed data
        log('Parsed Data: ${data.toString()}');

        if (data != null && data is Map<String, dynamic>) {
          // Extract user data if it exists
          final userData = data; // Adjust this if user data is nested
          log('Extracted User Data: ${userData.toString()}');

          try {
            User user = User.fromJson(userData);
            log(user.companyName);
            state = state.copyWith(user: user);
            log('User Data: ${user.toJson()}');
          } catch (e) {
            log('Error parsing user data: $e');
          }
        } else {
          log('Data is not in the expected format');
        }
      } else {
        log('Failed to fetch user info: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error getting user info: $e');
    }
  }

  Future<bool> verifyPin(String pin, String email) async {
    try {
      state = state.copyWith(authStatus: AuthStatus.processing);
      final response = await UserHelper.verifyOtp(email: email, pin: pin);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];
        print('Pin verification successful: $message');
        state = state.copyWith(authStatus: AuthStatus.processed);
        return true;
      } else {
        state = state.copyWith(authStatus: AuthStatus.error);
        print('Pin verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.error);
      print('Pin verification error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    String url = '$appBaseUrl/user/logout';

    try {
      await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.token}',
        },
      );
      await storage.delete(key: 'AT');
      state = state.copyWith(
        appStatus: AppStatus.unAuthenticated,
        token: null,
        user: User(
          id: '',
          name: '',
          companyName: '',
          email: '',
          password: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}

class AuthState {
  final User user;
  final Role? role;
  final AuthStatus? authStatus;
  final AuthStatus? loginStatus;
  final AuthStatus? googleLoginStatus;
  final AuthStatus? fpasswordStatus;
  final AppStatus? appStatus;
  final String? token;

  AuthState({
    required this.user,
    this.role,
    this.authStatus,
    this.loginStatus,
    this.googleLoginStatus,
    this.fpasswordStatus,
    required this.appStatus,
    this.token,
  });

  AuthState copyWith({
    User? user,
    Role? role,
    AuthStatus? authStatus,
    AuthStatus? loginStatus,
    AuthStatus? googleLoginStatus,
    AuthStatus? fpasswordStatus,
    AppStatus? appStatus,
    String? token,
  }) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      authStatus: authStatus ?? this.authStatus,
      loginStatus: loginStatus ?? this.loginStatus,
      googleLoginStatus: googleLoginStatus ?? this.googleLoginStatus,
      fpasswordStatus: fpasswordStatus ?? this.fpasswordStatus,
      appStatus: appStatus ?? this.appStatus,
      token: token ?? this.token,
    );
  }
}

enum AppStatus { initial, authenticated, unAuthenticated }

enum AuthStatus { initial, processing, processed, error }

enum Role { user, admin }
