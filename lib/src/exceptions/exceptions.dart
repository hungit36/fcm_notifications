import 'dart:core';

class DartCallbackException implements Exception {
  String msg;
  DartCallbackException(this.msg);
}

class FcmNotificationsException implements Exception {
  String msg;
  FcmNotificationsException(this.msg);
}
