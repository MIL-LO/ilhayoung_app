import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// UserType enum import
import 'core/enums/user_type.dart';
// 화면 imports
import 'screens/login/jeju_login_screen.dart';
import 'screens/worker/main/worker_main_screen.dart';
import 'screens/employer/main/employer_main_screen.dart';
// 일자리 리스트 화면 import
import 'screens/worker/jobs/jeju_job_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: JejuApp()));
}

class JejuApp extends StatelessWidget {
  const JejuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일하영 - 제주 일자리 플랫폼',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'SF Pro Text',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
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