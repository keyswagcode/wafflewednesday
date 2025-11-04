//
//  NotificationManager.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

#if canImport(UIKit)
import UIKit
#endif
import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var deviceToken: String?

    override private init() {
        super.init()
    }

    // Request notification permissions
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await center.requestAuthorization(options: options)

        await MainActor.run {
            self.isAuthorized = granted
        }

        if granted {
            await registerForPushNotifications()
        }
    }

    // Register for remote push notifications
    @MainActor
    func registerForPushNotifications() async {
        #if os(iOS)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
    }

    // Check current authorization status
    func checkAuthorizationStatus() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        let authorized = settings.authorizationStatus == .authorized
        await MainActor.run {
            self.isAuthorized = authorized
        }
        return authorized
    }

    // Handle device token registration
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        self.deviceToken = token
        print("Device Token: \(token)")

        // TODO: Send this token to your backend server
    }

    // Handle registration failure
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Schedule a local notification (for testing)
    func scheduleTestNotification() async throws {
        let content = UNMutableNotificationContent()
        content.title = "Waffle Wednesday"
        content.body = "It's time for waffles!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        try await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle the notification tap here
        print("Notification tapped: \(response.notification.request.identifier)")
        completionHandler()
    }
}
