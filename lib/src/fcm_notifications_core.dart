import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:fcm_notifications/fcm_notifications.dart';
import 'package:fcm_notifications/src/fcm_definitions.dart';
import 'package:fcm_notifications/src/isolates/silent_push_isolate_main.dart';

import 'exceptions/exceptions.dart';

class FcmNotifications {
  /// STREAM CREATION METHODS *********************************************

  static bool _isInitialized = false;
  static get isInitialized => _isInitialized;

  PushTokenHandler? _tokenFcmHandler;
  PushTokenHandler? _tokenNativeHandler;

  /// SINGLETON METHODS *********************************************

  final MethodChannel _channel;

  factory FcmNotifications() => _instance;

  @visibleForTesting
  FcmNotifications.private(MethodChannel channel) : _channel = channel;

  static final FcmNotifications _instance =
      FcmNotifications.private(
          const MethodChannel(CHANNEL_FLUTTER_PLUGIN));

  /// INITIALIZING METHODS *********************************************

  /// Initializes the plugin, setting the [onFcmTokenHandle] and [onFcmSilentDataHandle]
  /// listeners to capture Firebase Messaging events and the [licenseKeys] necessary
  /// to validate the release use of this plugin.
  /// You should call this method only once at main_complete.dart.
  /// [debug]: enables the console log prints
  Future<bool> initialize(
      {required PushTokenHandler onFcmTokenHandle,
      required FcmSilentDataHandler onFcmSilentDataHandle,
      List<String>? licenseKeys,
      PushTokenHandler? onNativeTokenHandle,
      bool debug = false}) async {
    WidgetsFlutterBinding.ensureInitialized();

    _tokenFcmHandler = onFcmTokenHandle;
    _tokenNativeHandler = onNativeTokenHandle;

    final dartCallbackReference =
        PluginUtilities.getCallbackHandle(silentPushBackgroundMain);
    final tokenCallbackReference =
        PluginUtilities.getCallbackHandle(onFcmTokenHandle);
    final silentCallbackReference =
        PluginUtilities.getCallbackHandle(onFcmSilentDataHandle);

    _channel.setMethodCallHandler(_handleMethod);
    _isInitialized =
        await _channel.invokeMethod(CHANNEL_METHOD_FCM_INITIALIZE, {
      DEBUG_MODE: debug,
      LICENSE_KEYS: licenseKeys,
      DART_BG_HANDLE: dartCallbackReference!.toRawHandle(),
      TOKEN_HANDLE: tokenCallbackReference?.toRawHandle(),
      SILENT_HANDLE: silentCallbackReference?.toRawHandle()
    });

    if (tokenCallbackReference == null) {
      debugPrint('Callback FcmTokenHandler is not defined or is invalid.'
          '\nPlease, ensure to create a valid global static method to handle it.');
    }

    if (silentCallbackReference == null) {
      debugPrint('Callback FcmSilentDataHandler is not defined or is invalid.'
          '\nPlease, ensure to create a valid global static method to handle it.');
    }

    return _isInitialized;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case CHANNEL_METHOD_NEW_NATIVE_TOKEN:
        final String token = call.arguments;
        if (_tokenNativeHandler != null) _tokenNativeHandler!(token);
        return;

      case CHANNEL_METHOD_NEW_FCM_TOKEN:
        final String token = call.arguments;
        if (_tokenFcmHandler != null) _tokenFcmHandler!(token);
        return;

      case CHANNEL_METHOD_SILENT_CALLBACK:
        try {
          if (!await receiveSilentData(
              (call.arguments as Map).cast<String, dynamic>())) {
            throw FcmNotificationsException(
                'Silent data could not be recovered');
          }
        } on DartCallbackException {
          debugPrint('Fatal: could not find silent callback');
        } catch (e) {
          debugPrint(
              "FCM Notifications: An error occurred in your silent data handler:");
          debugPrint(e.toString());
        }
        return;

      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  /// FIREBASE METHODS *********************************************

  /// Check if firebase is fully available on the project
  Future<bool> get isFirebaseAvailable async {
    final bool isAvailable =
        await _channel.invokeMethod(CHANNEL_METHOD_IS_FCM_AVAILABLE);
    return isAvailable;
  }

  /// Gets the firebase cloud messaging token
  Future<String> requestFirebaseAppToken() async {
    final String? fcmToken =
        await _channel.invokeMethod(CHANNEL_METHOD_GET_FCM_TOKEN);
    return fcmToken ?? '';
  }

  Future<void> subscribeToTopic(String topic) async {
    await _channel.invokeMethod(
        CHANNEL_METHOD_SUBSCRIBE_TOPIC, {NOTIFICATION_TOPIC: topic});
  }

  Future<void> unsubscribeToTopic(String topic) async {
    await _channel.invokeMethod(
        CHANNEL_METHOD_UNSUBSCRIBE_TOPIC, {NOTIFICATION_TOPIC: topic});
  }
}
