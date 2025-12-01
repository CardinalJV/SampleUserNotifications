//
//  ContentView.swift
//  SampleUserNotifications
//
//  Created by Viranaiken Jessy on 30/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(NotificationController.self) private var notificationController
    
    @State var notificationTitle: String = ""
    @State var notificationBody: String = ""
    @State var notificationHour: Int = 0
    @State var notificationMinute: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            // MARK: - Notifications pending request
            Section {
                VStack {
                    if notificationController.notificationsRequests.isEmpty {
                        Text("No notification pending")
                    } else {
                        ForEach(notificationController.notificationsRequests, id: \.self) { notification in
                            Text(notification.content.title + " : " + notification.content.body)
                                .padding()
                                .background(Color(.systemGray4))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    Button("Get notification pending requests") {
                        Task {
                            await notificationController.getPendingNotificationRequests()
                        }
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Button("Remove all pending notifications") {
                        notificationController.removeAllPendingNotificationRequests()
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Spacer()
            // MARK: - Notifications settings status
            Section {
                
            }
            // MARK: - Create custom notification
            Section {
                VStack {
                    TextField("Title", text: self.$notificationTitle)
                    TextField("Body", text: self.$notificationBody)
                    HStack {
                        Text("Hour:")
                        Spacer()
                        Picker("Heure", selection: $notificationHour) {
                            ForEach(0..<24) { h in
                                Text(String(format: "%02d", h))
                                    .tag(h)
                            }
                        }
                    }
                    HStack {
                        Text("Minute:")
                        Spacer()
                        Picker("Minute", selection: $notificationMinute) {
                            ForEach(0..<60) { m in
                                Text(String(format: "%02d", m))
                                    .tag(m)
                            }
                        }
                    }
                    Button("Create notification") {
                        Task {
                            await notificationController.createNotification(hour: self.notificationHour, minute: self.notificationMinute, title: self.notificationTitle, body: self.notificationBody)
                        }
                        UIApplication.shared.endEditing()
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Spacer()
        }
    }
}
// Extension to dismiss the keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

#Preview {
    
    @Previewable var notificationController = NotificationController()
    
    ContentView()
        .environment(notificationController)
}
