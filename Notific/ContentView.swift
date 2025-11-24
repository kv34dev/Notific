import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @State private var title: String = ""
    @State private var bodyText: String = ""
    
    @State private var sendMode: SendMode = .seconds
    
    @State private var seconds: Double = 5
    @State private var dateTime: Date = Date().addingTimeInterval(60)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Notification Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notification Details")
                            .font(.title2.bold())
                        
                        modernTextField("Title", text: $title)
                        modernTextField("Body", text: $bodyText)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    
                    // MARK: - Trigger Settings
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Trigger Settings")
                            .font(.title2.bold())
                        
                        Picker("Mode", selection: $sendMode) {
                            Text("After Seconds").tag(SendMode.seconds)
                            Text("Calendar & Time").tag(SendMode.calendar)
                        }
                        .pickerStyle(.segmented)
                        
                        if sendMode == .seconds {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Send After: \(Int(seconds)) seconds")
                                    .font(.headline)
                                
                                Slider(value: $seconds, in: 1...60, step: 1)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Date & Time")
                                    .font(.headline)
                                
                                DatePicker("",
                                           selection: $dateTime,
                                           in: Date()...,
                                           displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                            }
                        }
                        
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    
                    // MARK: - Buttons
                    VStack(spacing: 16) {
                        
                        modernButton(title: "Send", color: .blue) {
                            scheduleNotification()
                        }
                        
                        modernButton(title: "Clear All", color: .red, icon: "trash") {
                            clearAll()
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 24)
            }
            .navigationTitle("Notifier")
        }
        .onAppear {
            requestPermissions()
        }
    }
    
    
    // MARK: - TextField
    func modernTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.body)
    }
    
    // MARK: - Button
    func modernButton(title: String,
                      color: Color,
                      icon: String? = nil,
                      action: @escaping () -> Void) -> some View {
        
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title).font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .background(color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    
    // MARK: - Permission
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    
    // MARK: - Scheduling
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? "No Title" : title
        content.body = bodyText.isEmpty ? "No Body" : bodyText
        content.sound = .default
        
        let trigger: UNNotificationTrigger
        
        switch sendMode {
        case .seconds:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        case .calendar:
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dateTime
            )
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    // MARK: - Clear All
    func clearAll() {
        title = ""
        bodyText = ""
        seconds = 5
        dateTime = Date().addingTimeInterval(60)
        sendMode = .seconds
    }
}


// MARK: - Enum
enum SendMode {
    case seconds
    case calendar
}
