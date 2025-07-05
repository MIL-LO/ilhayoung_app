// lib/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/user_type.dart';
import '../../core/models/oauth_response.dart';
import '../../services/auth_service.dart';
import '../login/jeju_login_screen.dart';
import '../profile/worker_info_input_screen.dart';
import '../profile/employer_info_input_screen.dart';
import '../worker/main/worker_main_screen.dart';
import '../employer/main/employer_main_wrapper.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _needsSignup = false;
  UserType? _userType;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final needsSignup = await AuthService.needsSignup();
      final userType = await AuthService.getUserType();

      setState(() {
        _isLoggedIn = isLoggedIn;
        _needsSignup = needsSignup;
        _userType = userType;
        _isLoading = false;
      });
    } catch (e) {
      print('Auth status check error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 로그인되지 않은 경우
    if (!_isLoggedIn) {
      return JejuLoginScreen(
        onLoginSuccess: (UserType userType) {
          setState(() {
            _isLoggedIn = true;
            _userType = userType;
            _needsSignup = true; // 로그인 후 정보 입력 필요
          });
        },
      );
    }

    // 회원가입이 필요한 경우 (사용자 타입별로 다른 화면)
    if (_needsSignup && _userType != null) {
      if (_userType == UserType.worker) {
        return WorkerInfoInputScreen(
          onComplete: (UserType userType) {
            setState(() {
              _needsSignup = false;
            });
          },
        );
      } else {
        return EmployerInfoInputScreen(
          onComplete: (UserType userType) {
            setState(() {
              _needsSignup = false;
            });
          },
        );
      }
    }

    // 정상적으로 로그인된 경우 (사용자 타입별로 다른 화면)
    if (_userType == UserType.worker) {
      return WorkerMainScreen(onLogout: _handleLogout);
    } else {
      return EmployerMainWrapper(onLogout: _handleLogout);
    }
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _needsSignup = false;
      _userType = null;
    });
  }
}
