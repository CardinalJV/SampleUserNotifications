//
//  SampleUserNotificationsApp.swift
//  SampleUserNotifications
//
//  Created by Viranaiken Jessy on 30/11/25.
//

import SwiftUI

@main
struct SampleUserNotificationsApp: App {
    
    @State private var notificationController = NotificationController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await notificationController.requestAuthorization()
                }
        }
        .environment(self.notificationController)
    }
}
