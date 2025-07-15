// lib/core/enums/user_type.dart

enum UserType {
  worker,
  manager;

  String get displayName {
    switch (this) {
      case UserType.worker:
        return '일하는 사람';
      case UserType.manager:
        return '자영업자';
    }
  }

  String get serverValue {
    switch (this) {
      case UserType.worker:
        return 'STAFF';
      case UserType.manager:
        return 'MANAGER';
    }
  }

  static UserType? fromString(String value) {
    switch (value.toUpperCase()) {
      case 'STAFF':
      case 'WORKER':
        return UserType.worker;
      case 'MANAGER':
      case 'OWNER':
      case 'EMPLOYER':
        return UserType.manager;
      default:
        return null;
    }
  }
}