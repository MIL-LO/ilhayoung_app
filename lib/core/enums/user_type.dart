// lib/core/enums/user_type.dart

enum UserType {
  worker,
  employer, manager;

  String get displayName {
    switch (this) {
      case UserType.worker:
        return '일하는 사람';
      case UserType.employer:
        return '사업자';
      case UserType.manager:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String get serverValue {
    switch (this) {
      case UserType.worker:
        return 'STAFF';
      case UserType.employer:
        return 'OWNER';
      case UserType.manager:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static UserType? fromString(String value) {
    switch (value.toUpperCase()) {
      case 'STAFF':
      case 'WORKER':
        return UserType.worker;
      case 'OWNER':
      case 'EMPLOYER':
        return UserType.employer;
      default:
        return null;
    }
  }
}