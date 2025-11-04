//
//  PermissionsView.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct PermissionsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var audioManager = AudioPermissionManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var currentStep = 0
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(index <= currentStep ? Color.orange : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)

            Spacer()

            // Permission Cards
            TabView(selection: $currentStep) {
                // Notifications Permission
                PermissionCard(
                    icon: "bell.fill",
                    iconColor: .orange,
                    title: "Stay Updated",
                    description: "Get notified about important updates and reminders for your Waffle Wednesday activities.",
                    isGranted: notificationManager.isAuthorized,
                    actionTitle: "Enable Notifications",
                    action: {
                        Task {
                            try? await notificationManager.requestAuthorization()
                            withAnimation {
                                currentStep = 1
                            }
                        }
                    }
                )
                .tag(0)

                // Microphone Permission
                PermissionCard(
                    icon: "mic.fill",
                    iconColor: .blue,
                    title: "Voice Features",
                    description: "Allow microphone access to use voice features and communicate with other users.",
                    isGranted: audioManager.microphoneAuthorized,
                    actionTitle: "Enable Microphone",
                    action: {
                        Task {
                            let granted = await audioManager.requestMicrophonePermission()
                            if granted {
                                try? audioManager.configureAudioSession()
                            }
                            withAnimation {
                                currentStep = 2
                            }
                        }
                    }
                )
                .tag(1)

                // All Set
                PermissionCard(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "All Set!",
                    description: "You're ready to start using Waffle Wednesday. Enjoy your experience!",
                    isGranted: true,
                    actionTitle: "Get Started",
                    action: {
                        dismiss()
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)

            Spacer()

            // Skip Button
            if currentStep < 2 {
                Button(action: {
                    withAnimation {
                        currentStep += 1
                    }
                }) {
                    Text("Skip for now")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Open Settings", isPresented: $showingSettings) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                #if os(iOS)
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                #endif
            }
        } message: {
            Text("To enable permissions, please go to Settings > Waffle Wednesday")
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isGranted: Bool
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(iconColor)
            }

            // Title and Description
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 40)

            // Action Button
            Button(action: action) {
                HStack {
                    Text(actionTitle)
                        .font(.system(size: 17, weight: .semibold))

                    if isGranted {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(isGranted ? Color.green : iconColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isGranted && actionTitle != "Get Started")
            .padding(.horizontal, 40)
        }
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView()
    }
}
