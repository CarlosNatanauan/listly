// exceptions/session_expired_exception.dart
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);
}
