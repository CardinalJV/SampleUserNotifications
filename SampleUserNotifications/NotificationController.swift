//
//  NotificationController.swift
//  SampleUserNotifications
//
//  Created by Viranaiken Jessy on 26/11/25.
//

import UserNotifications

@Observable class NotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    let center = UNUserNotificationCenter.current()
    // Will stock the pending notification
    var notificationsRequests: [UNNotificationRequest] = []
    
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error during requestAuthorization: \(error.localizedDescription)")
        }
    }
    
    func getNotificationSettings() async -> String {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        case .ephemeral:
            return "Ephemeral"
        default:
            return "Unknown"
        }
    }
    
    func createNotification(hour: Int, minute: Int, title: String, body: String) async {
        /// Init the content of the notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        /// Init the date to display notification
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        /// Init the trigger that will sets the date components
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        /// Init the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        /// Request
        do {
            try await center.add(request)
            await self.getPendingNotificationRequests()
        } catch {
            print("Error during adding notification: \(error.localizedDescription)")
        }
    }
    
    func removeAllPendingNotificationRequests() {
        /// Remove all pending notification
        self.notificationsRequests.removeAll()
        center.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotificationRequests() async {
        /// Get the pending notification
        self.notificationsRequests = await center.pendingNotificationRequests()
    }
}
