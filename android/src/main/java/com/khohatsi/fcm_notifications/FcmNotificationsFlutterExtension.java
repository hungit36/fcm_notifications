package com.khohatsi.fcm_notifications;

import android.content.Context;

import me.carda.awesome_notifications.DartBackgroundExecutor;
import me.carda.awesome_notifications.core.AwesomeNotifications;
import me.carda.awesome_notifications.core.AwesomeNotificationsExtension;
import me.carda.awesome_notifications.core.logs.Logger;

import com.khohatsi.fcm_notifications.core.FcmNotifications;
import com.khohatsi.fcm_notifications.core.background.FcmBackgroundExecutor;

public class FcmNotificationsFlutterExtension extends AwesomeNotificationsExtension {
    private static final String TAG = "FcmNotificationsFlutterExtension";

    public static void initialize(){
        if(FcmNotifications.awesomeFcmExtensions != null) return;
        FcmNotifications.awesomeFcmExtensions = new FcmNotificationsFlutterExtension();

        if (AwesomeNotifications.debug)
            Logger.d(TAG, "Flutter FCM extensions attached to FCM Notification's core.");
    }

    @Override
    public void loadExternalExtensions(Context context) {
        FcmNotifications.awesomeFcmServiceClass = DartFcmService.class;
        FcmNotifications.awesomeFcmBackgroundExecutorClass = FcmBackgroundExecutor.class;
        FcmBackgroundExecutor.setBackgroundExecutorClass(FcmDartBackgroundExecutor.class);
    }
}