import Foundation
import IosAwnCore
import IosAwnFcmCore
import awesome_notifications

open class DartFcmServiceExtension: AwesomeServiceExtension {
    
    open override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ){
        SwiftFcmNotificationsPlugin.loadClassReferences()
        super.didReceive(request, withContentHandler: contentHandler)
    }
}