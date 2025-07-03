import 'package:flutter/material.dart';
import '../../core/enums/user_type.dart';
import '../login/jeju_login_screen.dart';
import '../profile/worker_info_input_screen.dart';
import '../profile/employer_info_input_screen.dart';
import '../worker/main/worker_main_screen.dart';
// import '../employer/main/employer_main_screen.dart'; // 자영업자 메인 화면 (추후 구현)

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
      return const WorkerMainScreen();
    } else {
      // TODO: 자영업자 메인 화면 구현 후 연결
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🏢',
                style: TextStyle(fontSize: 64),
              ),
              SizedBox(height: 20),
              Text(
                '자영업자 화면',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '곧 준비될 예정입니다!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}