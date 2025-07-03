// lib/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import '../../core/enums/user_type.dart';
import '../login/jeju_login_screen.dart';
import '../profile/worker_info_input_screen.dart';
import '../profile/employer_info_input_screen.dart';
import '../worker/main/worker_main_screen.dart';
import '../employer/main/employer_main_wrapper.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  bool _hasUserInfo = false;
  UserType? _userType;

  @override
  Widget build(BuildContext context) {
    // 1단계: 로그인 화면
    if (!_isAuthenticated) {
      return JejuLoginScreen(
        onLoginSuccess: (UserType userType) {
          setState(() {
            _isAuthenticated = true;
            _userType = userType;
            _hasUserInfo = false; // 로그인 후에는 정보 입력 필요
          });
        },
      );
    }

    // 2단계: 정보입력 화면 (사용자 타입별로 다른 화면)
    if (!_hasUserInfo && _userType != null) {
      if (_userType == UserType.worker) {
        // 구직자 정보 입력 화면
        return WorkerInfoInputScreen(
          onComplete: (UserType userType) {
            setState(() {
              _hasUserInfo = true;
            });
          },
        );
      } else {
        // 자영업자 정보 입력 화면
        return EmployerInfoInputScreen(
          onComplete: (UserType userType) {
            setState(() {
              _hasUserInfo = true;
            });
          },
        );
      }
    }

    // 3단계: 메인 화면 (사용자 타입별로 다른 화면)
    if (_userType == UserType.worker) {
      return WorkerMainScreen(onLogout: _handleLogout);
    } else {
      return EmployerMainWrapper(onLogout: _handleLogout);
    }
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _hasUserInfo = false;
      _userType = null;
    });
  }
}