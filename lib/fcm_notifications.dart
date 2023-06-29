library fcm_notifications;

import 'package:fcm_notifications/src/models/fcm_silent_data.dart';

export 'src/fcm_notifications_core.dart';
export 'src/models/fcm_silent_data.dart';

/// Method structure to listen to an incoming action with dart
typedef Future<void> PushTokenHandler(String token);

/// Method structure to listen to an notification event with dart
typedef Future<void> FcmSilentDataHandler(FcmSilentData silentData);