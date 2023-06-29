package com.khohatsi.fcm_notifications;

import android.content.Context;

import me.carda.awesome_notifications.AwesomeNotificationsFlutterExtension;
import com.khohatsi.fcm_notifications.core.services.AwesomeFcmService;

public class DartFcmService extends AwesomeFcmService {
    @Override
    public void initializeExternalPlugins(Context context) throws Exception {
        AwesomeNotificationsFlutterExtension.initialize();
        FcmNotificationsFlutterExtension.initialize();
    }
}