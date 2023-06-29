#import "FcmNotificationsPlugin.h"
#if __has_include(<fcm_notifications/fcm_notifications-Swift.h>)
#import <fcm_notifications/fcm_notifications-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fcm_notifications-Swift.h"
#endif

@implementation FcmNotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFcmNotificationsPlugin registerWithRegistrar:registrar];
}
@end