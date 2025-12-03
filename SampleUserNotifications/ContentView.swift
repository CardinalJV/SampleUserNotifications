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
    @State var notificationYear: Int = 0
    @State var notificatonMonth: Int = 0
    @State var notificationDay: Int = 0
    @State var notificationHour: Int = 0
    @State var notificationMinute: Int = 0
    @State var notificationSettings = ""
    
    @State private var showMonthAndDayPicker: Bool = false
    
    let months = Calendar.current.monthSymbols
    
    private func resetForm() {
        self.notificationTitle.removeAll()
        self.notificationBody.removeAll()
        self.notificationHour = 0
        self.notificationMinute = 0
    }
    
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
                            NotificationView(notificationRequest: notification)
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
                    .background(.red)
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
                HStack {
                    Text("Notification settings")
                    if !self.notificationSettings.isEmpty {
                        Text(self.notificationSettings)
                            .foregroundStyle(.blue)
                            .bold()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Spacer()
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
                    if showMonthAndDayPicker {
                        HStack {
                            Text("Month")
                            Spacer()
                            Picker("Month", selection: $notificatonMonth) {
                                ForEach(1...12, id: \.self) { index in
                                    Text(months[index - 1])
                                        .tag(index)
                                }
                            }
                        }
                        HStack {
                            Text("Day")
                            Spacer()
                            Picker("Day", selection: $notificationDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)")
                                        .tag(day)
                                }
                            }
                        }
                    }
                    Button("Show day and month") {
                        self.showMonthAndDayPicker.toggle()
                    }
                    Button("Create notification") {
                        Task {
                            await notificationController.createNotification(year: self.notificationYear, month: self.notificatonMonth, day: self.notificationDay, hour: self.notificationHour, minute: self.notificationMinute, title: self.notificationTitle, body: self.notificationBody)
                            self.resetForm()
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
        .task {
            self.notificationSettings = await notificationController.getNotificationSettings()
        }
    }
}

struct NotificationView: View {
    
    let notificationRequest: UNNotificationRequest
    
    @State var date: String = ""
    
    private func getNotificationDate(trigger: UNCalendarNotificationTrigger) -> String {
        let dateComponents = trigger.dateComponents
        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let str = formatter.string(from: date)
            return str
        }
        return ""
    }
    
    var body: some View {
        VStack {
            Text(self.notificationRequest.content.title + " : " + self.notificationRequest.content.body)
                .padding()
                .background(Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Text(self.date)
        }
        .task {
            if let trigger = self.notificationRequest.trigger {
                self.date = self.getNotificationDate(trigger: trigger as! UNCalendarNotificationTrigger)
            }
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
