//
//  ContentView.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some View {
        Group {
            if firebaseManager.currentUser != nil {
                MainTabView()
            } else {
                LoginView(onLoginSuccess: {
                    // Request notification permission once after first login
                    Task {
                        let isAuthorized = await notificationManager.checkAuthorizationStatus()
                        if !isAuthorized {
                            try? await notificationManager.requestAuthorization()
                        }
                    }
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirebaseManager.shared)
    }
}

// MARK: - Shared Components

// Cartoon Waffle Component
struct CartoonWaffleView: View {
    var body: some View {
        ZStack {
            // Waffle shadow
            Circle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 280, height: 40)
                .blur(radius: 20)
                .offset(y: 130)

            // Main waffle body
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.96, green: 0.76, blue: 0.35),
                                Color(red: 0.85, green: 0.65, blue: 0.25)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 250, height: 250)

                // Waffle grid pattern
                VStack(spacing: 20) {
                    ForEach(0..<5) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<5) { column in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0.75, green: 0.55, blue: 0.15))
                                    .frame(width: 35, height: 35)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            }
                        }
                    }
                }
                .clipShape(Circle())
                .frame(width: 250, height: 250)

                // Shine/highlight effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.0)
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 250, height: 250)
                    .offset(x: -30, y: -30)

                // Cute face
                VStack(spacing: 20) {
                    // Eyes
                    HStack(spacing: 50) {
                        // Left eye
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 20, height: 20)
                                .offset(x: 3, y: 2)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .offset(x: 5, y: -1)
                        }

                        // Right eye
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 20, height: 20)
                                .offset(x: 3, y: 2)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .offset(x: 5, y: -1)
                        }
                    }

                    // Happy smile
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addQuadCurve(
                            to: CGPoint(x: 60, y: 0),
                            control: CGPoint(x: 30, y: 25)
                        )
                    }
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 60, height: 25)
                    .offset(y: 5)
                }
                .offset(y: -10)
            }

            // Syrup drip on top
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.3, blue: 0.0),
                                Color(red: 0.5, green: 0.25, blue: 0.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 15, height: 40)
                    .offset(x: -70, y: -125)
                    .rotationEffect(.degrees(20))

                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.3, blue: 0.0),
                                Color(red: 0.5, green: 0.25, blue: 0.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: -65, y: -100)
            }
            .opacity(0.8)
        }
    }
}
