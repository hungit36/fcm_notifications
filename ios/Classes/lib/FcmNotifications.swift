import Foundation

import UIKit
import FirebaseCore
import FirebaseMessaging
import IosAwnCore
import IosAwnFcmCore

public class FcmNotifications:
                        NSObject,
                        MessagingDelegate,
                        UNUserNotificationCenterDelegate
{
    let TAG = "FcmNotifications"

    static var _debug:Bool? = nil
    static var debug:Bool {
        get {
            if _debug == nil {
                _debug = FcmDefaultsManager.shared.debug
            }
            return _debug!
        }
        set {
            _debug = newValue
            FcmDefaultsManager.shared.debug = newValue
        }
    }

    static var firebaseDeviceToken:String?

    private var originalUserCenter:UNUserNotificationCenter?
    private var originalUserCenterDelegate:UNUserNotificationCenterDelegate?
    private var originalDelegateHasDidReceive = false
    private var originalDelegateHasWillPresent = false

    private var originalMessaging:Messaging?
    private var originalMessagingDelegate:MessagingDelegate?
    private var originalDelegateHasReceiveMessage = false
    private var originalDelegateHasSubscribe = false
    private var originalDelegateHasUnsubscribe = false

    private var isInitialized:Bool = false

    private static func checkGooglePlayServices() -> Bool {
        return true
    }

    public func initialize(
        silentHandle:Int64,
        dartBgHandle:Int64,
        licenseKeys:[String],
        debug:Bool
    ) throws -> Bool {
        if isInitialized {
            return true
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        FcmNotifications.debug = debug

        FcmDefaultsManager.shared.debug = debug
        FcmDefaultsManager.shared.silentCallback = silentHandle
        FcmDefaultsManager.shared.backgroundCallback = dartBgHandle
        FcmDefaultsManager.shared.licenseKeys = licenseKeys

        if FcmNotifications.debug {
            Logger.d(TAG,
                  "FCM Notifications service initialized")
            Logger.d(TAG,
                  "FCM Notifications - App Group: "+Definitions.USER_DEFAULT_TAG)
        }

        if try !LicenseManager.shared.isLicenseKeyValid() {
            Logger.i(TAG,
                 "You need to insert a valid license key to use FCM Notification's " +
                 "plugin in release mode without watermarks (Bundle ID: \"\(Bundle.main.bundleIdentifier ?? "")\"). " +
                 "To know more about it, please visit https://khohatsi.com/prices")
        }
        else {
            Logger.d(TAG,"FCM Notification's license key validated")
        }

        isInitialized = true
        return true
    }

    public func subscribeOnAwesomeFcmEvents(listener: AwesomeFcmListener){
        _ = AwesomeFcmEventsReceiver
            .shared
            .subscribeOnNotificationEvents(listener: listener)
    }

    public func unsubscribeOnAwesomeFcmEvents(listener: AwesomeFcmListener){
        _ = AwesomeFcmEventsReceiver
            .shared
            .unsubscribeOnNotificationEvents(listener: listener)
    }

    static var _firebaseEnabled:Bool = false
    static var firebaseEnabled:Bool {
        get {
            return _firebaseEnabled
        }
    }

    public func enableRemoteNotifications(_ application: UIApplication) -> Bool {
        if !SwiftUtils.isRunningOnExtension() {
            if !enableFirebase(application) {
               return false
            }
            //attachMessagingDelegate()
        }
        return true
    }

    public func isFcmAvailable(whenFinished completionHandler: @escaping (Bool?, AwesomeNotificationsException?) -> ()) throws {
        completionHandler(FcmNotifications._firebaseEnabled, nil)
    }

    private func enableFirebase(_ application: UIApplication) -> Bool {
        if FcmNotifications._firebaseEnabled {
            return true
        }

        guard let firebaseConfigPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }

        if FileManager.default.fileExists(atPath: firebaseConfigPath) {
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            FcmNotifications._firebaseEnabled = true
        }
        return FcmNotifications._firebaseEnabled
    }

    private func attachMessagingDelegate() {
        if !FcmNotifications.firebaseEnabled {
            return
        }

        if FcmNotifications.debug {
            Logger.d(TAG, "Awesome Notifications FCM attached to iOS")
        }
    }

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        return AwesomeFcmService()
            .didReceiveRemoteNotification(
                userInfo: userInfo,
                fetchCompletionHandler: completionHandler)
    }

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        AwesomeFcmEventsReceiver
            .shared
            .addNewNativeTokenEvent(withToken: deviceTokenString)

        Messaging.messaging().apnsToken = deviceToken
        Logger.d(TAG, "Received a new valid APNs token")
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        didReceiveRegistrationToken(messaging, token: fcmToken)
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let unwrapped = fcmToken {
            didReceiveRegistrationToken(messaging, token: unwrapped)
        }
    }

    private func didReceiveRegistrationToken(_ messaging: Messaging, token: String){
        Logger.d(TAG, "Received a new valid token")
        FcmNotifications.firebaseDeviceToken = token

        if isInitialized {
            AwesomeFcmEventsReceiver
                .shared
                .addNewTokenEvent(withToken: token)
        }
    }

    public func requestFirebaseToken(
        whenFinished requestCompletion: @escaping (String?, AwesomeNotificationsException?) -> ()
    ) {
        if let token:String = FcmNotifications.firebaseDeviceToken {
            requestCompletion(token, nil)
            AwesomeFcmEventsReceiver
                .shared
                .addNewTokenEvent(withToken: token)
            return
        }
        else {
            Messaging.messaging().token(completion: { [self] token, error in
                FcmNotifications.firebaseDeviceToken = token
                let success:Bool = error == nil

                if FcmNotifications.debug {
                    Logger.d(TAG,
                             success ?
                                 "Retrieve a new valid FCM token" :
                                 "Fcm token registering failed")
                }

                if !success {
                    let awesomeException = ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: TAG,
                            code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                            message: error!.localizedDescription,
                            detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".request.token",
                            exception: error!)

                    requestCompletion(token, awesomeException)
                } else {
                    requestCompletion(token, nil)
                }

                AwesomeFcmEventsReceiver
                    .shared
                    .addNewTokenEvent(withToken: token)
            })
        }

    }

    public func subscribe(
        onTopic topic:String,
        whenFinished subscriptionCompletion: @escaping (Bool, AwesomeNotificationsException?) -> ()
    ) {
        Messaging.messaging().subscribe(toTopic: topic, completion: { [self] error in
            let success:Bool = error == nil
            if FcmNotifications.debug {
                Logger.d(TAG,
                         success ?
                             "Subscribed to topic \(topic)" :
                             "Topic \(topic) subscription failed")
            }

            if !success {
                let awesomeException = ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                        message: error!.localizedDescription,
                        detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".subscribe.\(topic)",
                        exception: error!)

                subscriptionCompletion(success, awesomeException)
            } else {
                subscriptionCompletion(success, nil)
            }
        })
    }

    public func unsubscribeTopic(
        onTopic topic:String,
        whenFinished unsubscriptionCompletion: @escaping (Bool, AwesomeNotificationsException?) -> ()
    ) {
        Messaging.messaging().unsubscribe(fromTopic: topic, completion: { [self] error in
            let success:Bool = error == nil
            if FcmNotifications.debug {
                Logger.d(TAG,
                         success ?
                             "Unsubscribed to topic \(topic)" :
                             "Topic \(topic) unsubscription failed")
            }

            if !success {
                let awesomeException = ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                        message: error!.localizedDescription,
                        detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".unsubscribe.\(topic)",
                        exception: error!)

                unsubscriptionCompletion(success, awesomeException)
            } else {
                unsubscriptionCompletion(success, nil)
            }
        })
    }
}