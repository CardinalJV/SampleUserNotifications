//
//  NotificationController.swift
//  SampleUserNotifications
//
//  Created by Viranaiken Jessy on 26/11/25.
//

import UserNotifications

@Observable class NotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    let center = UNUserNotificationCenter.current()
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
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        do {
            try await center.add(request)
            await self.getPendingNotificationRequests()
        } catch {
            print("Error during adding notification: \(error.localizedDescription)")
        }
    }
    
    func removeAllPendingNotificationRequests() {
        self.notificationsRequests.removeAll()
        center.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotificationRequests() async {
        self.notificationsRequests = await center.pendingNotificationRequests()
    }
}
