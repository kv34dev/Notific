import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var title: String = ""
    @State private var bodyText: String = ""
    
    @State private var isSendingContinuously = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Local Notification Sender")
                .font(.title)
                .padding(.top, 40)
            
            TextField("Notification Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Notification Body", text: $bodyText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Send Once") {
                sendNotification()
            }
            .buttonStyle(.borderedProminent)

            Button("Start Continuous Sending") {
                startContinuousSending()
            }
            .buttonStyle(.borderedProminent)

            Button("Stop") {
                stopContinuousSending()
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Spacer()
        }
        .onAppear {
            requestNotificationPermissions()
        }
    }
    
    // MARK: - Notification Permissions
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Permission error: \(error)")
            }
        }
    }

    // MARK: - Send Single Notification
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? "No Title" : title
        content.body = bodyText.isEmpty ? "No Body" : bodyText
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Start Continuous Notifications
    func startContinuousSending() {
        guard !isSendingContinuously else { return }
        isSendingContinuously = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            sendNotification()
        }
    }

    // MARK: - Stop Continuous Notifications
    func stopContinuousSending() {
        isSendingContinuously = false
        timer?.invalidate()
        timer = nil
    }
}
