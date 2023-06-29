import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fcm_notifications_example/routes.dart';
import 'package:flutter/material.dart';
import 'package:fcm_notifications/fcm_notifications.dart';

import 'notifications/notification_controller.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeLocalNotifications(debug: true);
  await NotificationController.initializeRemoteNotifications(debug: true);
  await NotificationController.getInitialNotificationAction();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String name = 'FCM Notifications - Example App';
  static final Color mainColor = Color(0xFF9D50DD);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Only after at least the action method is set, the notification events are delivered
    NotificationController.initializeNotificationListeners();
  }

  @override
  void dispose() {
    AwesomeNotifications().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        // The navigator key is necessary to allow to navigate through static methods
        navigatorKey: MyApp.navigatorKey,
        title: 'FCM Notifications',
        color: MyApp.mainColor,
        theme: ThemeData(
            primaryColor: MyApp.mainColor,
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: MyApp.mainColor),
              textTheme: TextTheme(
                  headline6: TextStyle(
                      color: MyApp.mainColor, fontWeight: FontWeight.bold)),
            )),
        initialRoute: PAGE_HOME,
        routes: materialRoutes);
  }
}
