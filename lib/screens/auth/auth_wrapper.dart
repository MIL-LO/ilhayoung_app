import 'package:flutter/material.dart';

import '../../core/enums/user_type.dart';
import '../login/jeju_login_screen.dart';
import '../worker/main/worker_main_screen.dart';
import '../employer/main/employer_main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  UserType? _userType;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return JejuLoginScreen(onLoginSuccess: _handleLogin);
    }

    switch (_userType) {
      case UserType.worker:
        return WorkerMainScreen(onLogout: _handleLogout);
      case UserType.employer:
        return EmployerMainScreen(onLogout: _handleLogout);
      default:
        return JejuLoginScreen(onLoginSuccess: _handleLogin);
    }
  }

  void _handleLogin(UserType userType) {
    setState(() {
      _isLoggedIn = true;
      _userType = userType;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _userType = null;
    });
  }
}