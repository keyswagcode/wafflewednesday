//
//  WaffleWednesdayApp.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FirebaseCore
import FirebaseAuth

#if os(iOS)
// AppDelegate for Firebase configuration and phone auth
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()

        print("Firebase configured successfully")
        return true
    }

    // Required for phone auth with reCAPTCHA
    func application(_ application: UIApplication, open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }

    func application(_ application: UIApplication,
                    didReceiveRemoteNotification notification: [AnyHashable : Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
}
#endif

@main
struct WaffleWednesdayApp: App {
    #if os(iOS)
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #else
    init() {
        // Configure Firebase for non-iOS platforms
        FirebaseApp.configure()
    }
    #endif

    // Firebase manager
    @StateObject private var firebaseManager = FirebaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseManager)
        }
    }
}
