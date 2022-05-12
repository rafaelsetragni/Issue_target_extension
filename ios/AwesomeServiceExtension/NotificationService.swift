//
//  NotificationService.swift
//  AwesomeServiceExtension
//
//  Created by CardaDev on 12/05/22.
//

import UserNotifications
import awesome_notifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            guard let notificationModelArguments = bestAttemptContent.userInfo as NSDictionary? as? [String: Any] else {
                contentHandler(bestAttemptContent)
                return
            }
            let notificationModel = NotificationModel().fromMap(arguments: notificationModelArguments)
            print(String(describing: notificationModel?.toMap()))
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
