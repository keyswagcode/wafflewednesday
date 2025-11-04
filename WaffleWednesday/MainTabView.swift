//
//  MainTabView.swift
//  WaffleWednesday
//
//  Created by Claude on 10/26/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var selectedTab = 0
    @State private var showingRecordSheet = false
    @State private var hasRecordedThisWeek = false
    @State private var isCheckingRecordingStatus = true
    @State private var showUploadError = false
    @State private var uploadErrorMessage = ""

    var body: some View {
        Group {
            if isCheckingRecordingStatus {
                // Loading state
                ProgressView()
            } else if false { // TESTING: Disabled "must record first" gate to allow unlimited uploads
                // Must record waffle first
                VStack {
                    Text("It's Waffle Wednesday!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    Text("Record your waffle to continue")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)

                    WaffleRecordingView(
                        hasRecordedThisWeek: $hasRecordedThisWeek,
                        onUpload: { audioURL, duration in
                            Task {
                                do {
                                    _ = try await firebaseManager.uploadWaffle(audioURL: audioURL, duration: duration)
                                    hasRecordedThisWeek = true
                                    // Notify that a waffle was uploaded
                                    NotificationCenter.default.post(name: NSNotification.Name("WaffleUploaded"), object: nil)
                                    print("✅ Waffle uploaded successfully!")
                                    // Small delay for smooth transition
                                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                                    // Auto-navigate to profile tab to see the waffle
                                    await MainActor.run {
                                        selectedTab = 4
                                    }
                                } catch {
                                    print("❌ Error uploading waffle: \(error)")
                                    await MainActor.run {
                                        uploadErrorMessage = "Upload failed: \(error.localizedDescription)"
                                        showUploadError = true
                                    }
                                }
                            }
                        }
                    )
                }
            } else {
                // Show tab interface
                tabInterface
            }
        }
        .task {
            await checkRecordingStatus()
        }
    }

    private var tabInterface: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            TabView(selection: $selectedTab) {
                // Friends Feed
                FriendsWafflesView()
                    .padding(.bottom, 80) // Space for tab bar
                    .tag(0)

                // Public Feed
                PublicFeedView()
                    .padding(.bottom, 80) // Space for tab bar
                    .tag(1)

                // Placeholder for middle button (recording)
                Color.clear
                    .tag(2)

                // Direct Waffles
                DirectWafflesView()
                    .padding(.bottom, 80) // Space for tab bar
                    .tag(3)

                // Profile
                ProfileView()
                    .padding(.bottom, 80) // Space for tab bar
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Tab Bar - Always on top
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, showingRecordSheet: $showingRecordSheet)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingRecordSheet) {
            WaffleRecordingView(
                hasRecordedThisWeek: $hasRecordedThisWeek,
                onUpload: { audioURL, duration in
                    // Handle upload
                    Task {
                        do {
                            _ = try await firebaseManager.uploadWaffle(audioURL: audioURL, duration: duration)
                            hasRecordedThisWeek = true
                            // Notify that a waffle was uploaded
                            NotificationCenter.default.post(name: NSNotification.Name("WaffleUploaded"), object: nil)
                            print("✅ Waffle uploaded successfully!")
                            // Close sheet first
                            await MainActor.run {
                                showingRecordSheet = false
                            }
                            // Small delay for smooth transition
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                            // Auto-navigate to profile tab to see the waffle
                            await MainActor.run {
                                selectedTab = 4
                            }
                        } catch {
                            print("❌ Error uploading waffle: \(error)")
                            await MainActor.run {
                                uploadErrorMessage = "Upload failed: \(error.localizedDescription)"
                                showUploadError = true
                                showingRecordSheet = false
                            }
                        }
                    }
                }
            )
            .environmentObject(firebaseManager)
        }
        .alert("Upload Error", isPresented: $showUploadError) {
            Button("OK") {
                showUploadError = false
            }
        } message: {
            Text(uploadErrorMessage)
        }
    }

    // Check if user has recorded this week
    private func checkRecordingStatus() async {
        do {
            hasRecordedThisWeek = try await firebaseManager.hasPostedThisWednesday()
        } catch {
            print("Error checking recording status: \(error)")
            hasRecordedThisWeek = false
        }
        isCheckingRecordingStatus = false
    }

    // Check if today is Wednesday
    private func isWednesday() -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        print("🗓️ Today is weekday: \(weekday) (1=Sunday, 4=Wednesday)")
        return true // TESTING: Always return true to allow recording any day
        // return weekday == 4 // Wednesday is 4 (Sunday is 1)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showingRecordSheet: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Friends Tab
            TabBarButton(
                icon: "person.2.fill",
                title: "Friends",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // Public Tab
            TabBarButton(
                icon: "globe",
                title: "Public",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // Record Button (Center - Waffle Icon)
            Button(action: {
                showingRecordSheet = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)

                    // Waffle grid pattern
                    VStack(spacing: 3) {
                        HStack(spacing: 3) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        HStack(spacing: 3) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        HStack(spacing: 3) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                .offset(y: -15)
            }
            .frame(maxWidth: .infinity)

            // Direct Waffles Tab
            TabBarButton(
                icon: "message.fill",
                title: "Direct",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }

            // Profile Tab
            TabBarButton(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .frame(height: 80)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: -5)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))

                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? .purple : .gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(FirebaseManager.shared)
    }
}
