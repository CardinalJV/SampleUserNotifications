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
    
    func createBadgeInAndOutNotification() async {
        // Badge-in
        let badgeInContent = UNMutableNotificationContent()
        badgeInContent.title = "Apple developer academy"
        badgeInContent.body = "Badge-in"
        var dateIn = DateComponents()
        dateIn.hour = 14
        dateIn.minute = 0
        let triggerIn = UNCalendarNotificationTrigger(dateMatching: dateIn, repeats: true)
        // Badge-Out
        let badgeOutContent = UNMutableNotificationContent()
        badgeOutContent.title = "Apple developer academy"
        badgeOutContent.body = "Badge-out"
        var dateOut = DateComponents()
        dateOut.hour = 18
        dateOut.minute = 0
        let triggerOut = UNCalendarNotificationTrigger(dateMatching: dateOut, repeats: true)
        // Request for both
        let badgeInRequest = UNNotificationRequest(identifier: "badgeIn-notification", content: badgeInContent, trigger: triggerIn)
        let badgeOutRequest = UNNotificationRequest(identifier: "badgeOut-notification", content: badgeOutContent, trigger: triggerOut)
        do {
            try await center.add(badgeInRequest)
            try await center.add(badgeOutRequest)
            await self.getPendingNotificationRequests()
        } catch {
            print("Error during setting notification: \(error.localizedDescription)")
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
