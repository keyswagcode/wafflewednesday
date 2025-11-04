//
//  ProfileView.swift
//  WaffleWednesday
//
//  Created by Claude on 10/26/25.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isEditingName = false
    @State private var newName = ""
    @State private var showingLogoutAlert = false
    @State private var myWaffles: [WafflePost] = []
    @State private var isLoading = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isUploadingPhoto = false
    @State private var showNotificationSettingsSheet = false
    @State private var showPrivacySheet = false
    @State private var selectedPrivacyLevel: String = "public"
    @State private var showFriendsSheet = false

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture with PhotoPicker
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                // Profile picture circle
                                Group {
                                    if let profileImage = profileImage {
                                        // Show selected image
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else if let user = firebaseManager.currentUser,
                                              let imageURL = user.profileImageURL,
                                              let url = URL(string: imageURL) {
                                        // Show profile image from URL
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                            case .failure, .empty:
                                                // Fallback to initial
                                                defaultProfileView
                                            @unknown default:
                                                defaultProfileView
                                            }
                                        }
                                        .id(imageURL)
                                    } else {
                                        // Show initial letter
                                        defaultProfileView
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )

                                // Camera icon
                                ZStack {
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 32, height: 32)

                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                .offset(x: -5, y: -5)

                                if isUploadingPhoto {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .disabled(isUploadingPhoto)

                        // Name
                        if let user = firebaseManager.currentUser {
                            if isEditingName {
                                HStack {
                                    TextField("Name", text: $newName)
                                        .textFieldStyle(.roundedBorder)
                                        .multilineTextAlignment(.center)

                                    Button("Save") {
                                        Task {
                                            await saveName()
                                        }
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Cancel") {
                                        isEditingName = false
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.horizontal)
                            } else {
                                HStack {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)

                                    Button {
                                        newName = user.name
                                        isEditingName = true
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.purple)
                                    }
                                }
                            }

                            // Phone number or Apple ID
                            if let phone = user.phoneNumber {
                                Text(phone)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else if user.appleId != nil {
                                Label("Signed in with Apple", systemImage: "apple.logo")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)

                    Divider()
                        .padding(.horizontal)

                    // Stats
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(firebaseManager.friendWaffles.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Friends")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(myWaffles.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Waffles")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("0")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Replies")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()
                        .padding(.horizontal)

                    // My Waffles Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("My Waffles")
                            .font(.headline)
                            .padding(.horizontal)

                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(40)
                        } else if myWaffles.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "waveform.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))

                                Text("No waffles yet")
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                Text("Record your first waffle this Wednesday!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(myWaffles) { waffle in
                                    AudioPlayerView(
                                        waffle: waffle,
                                        canReply: false,
                                        onReply: nil
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Divider()
                        .padding(.horizontal)

                    // Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            SettingsRow(icon: "bell.fill", title: "Notifications", color: .orange) {
                                showNotificationSettingsSheet = true
                            }

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(icon: "lock.fill", title: "Privacy", color: .purple) {
                                selectedPrivacyLevel = firebaseManager.currentUser?.privacyLevel ?? "public"
                                showPrivacySheet = true
                            }

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(icon: "person.2.fill", title: "Friends", color: .blue) {
                                showFriendsSheet = true
                            }

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .green) {
                                // Navigate to help
                            }

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(icon: "info.circle.fill", title: "About", color: .purple) {
                                // Navigate to about
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Logout Button
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Text("Log Out")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    Spacer()
                }
            }
            .refreshable {
                await loadMyWaffles()
            }
            .task {
                await loadMyWaffles()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WaffleUploaded"))) { _ in
                Task {
                    await loadMyWaffles()
                }
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let newValue = newValue {
                        await loadAndUploadPhoto(from: newValue)
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .sheet(isPresented: $showNotificationSettingsSheet) {
                NotificationSettingsView()
                    .environmentObject(notificationManager)
                    .presentationDetents([.height(300)])
            }
            .sheet(isPresented: $showPrivacySheet) {
                PrivacySettingsSheet(
                    selectedPrivacyLevel: $selectedPrivacyLevel,
                    onSave: {
                        Task {
                            await updatePrivacyLevel(selectedPrivacyLevel)
                        }
                        showPrivacySheet = false
                    }
                )
                .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $showFriendsSheet) {
                ContactSyncView()
            }
    }

    private var defaultProfileView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.7), Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)

            if let user = firebaseManager.currentUser {
                Text(user.name.prefix(1).uppercased())
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    private func loadAndUploadPhoto(from item: PhotosPickerItem) async {
        isUploadingPhoto = true
        defer { isUploadingPhoto = false }

        do {
            // Load image data
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Failed to load image data")
                return
            }

            // Create UIImage
            guard let uiImage = UIImage(data: data) else {
                print("Failed to create UIImage")
                return
            }

            // Update local preview
            await MainActor.run {
                profileImage = uiImage
            }

            // Upload to Firebase
            try await firebaseManager.uploadProfilePicture(image: uiImage)

            // Clear local preview so view uses Firebase URL
            await MainActor.run {
                profileImage = nil
            }
        } catch {
            print("Error uploading profile picture: \(error)")
            // Reset on error
            await MainActor.run {
                profileImage = nil
            }
        }
    }

    private func loadMyWaffles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            print("📥 Loading my waffles...")

            // First cleanup old waffles (keep only last 2)
            try await firebaseManager.cleanupOldWaffles()

            // Then fetch the remaining waffles
            myWaffles = try await firebaseManager.fetchMyWaffles()
            print("✅ Loaded \(myWaffles.count) waffles")
        } catch {
            print("❌ Error loading my waffles: \(error)")
        }
    }

    private func saveName() async {
        // TODO: Implement name update in Firebase
        isEditingName = false
    }

    private func updatePrivacyLevel(_ level: String) async {
        do {
            try await firebaseManager.updatePrivacyLevel(level)
            print("Privacy level updated to: \(level)")
        } catch {
            print("Error updating privacy level: \(error)")
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            // User will be automatically redirected to login screen
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct PrivacySettingsSheet: View {
    @Binding var selectedPrivacyLevel: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Who can see your waffles?")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 20)

                VStack(spacing: 12) {
                    // Public and Friends Option
                    Button(action: {
                        selectedPrivacyLevel = "public"
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Public and Friends")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("Everyone can see your waffles on the public feed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedPrivacyLevel == "public" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 24))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPrivacyLevel == "public" ? Color.purple.opacity(0.1) : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedPrivacyLevel == "public" ? Color.purple : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Friends Only Option
                    Button(action: {
                        selectedPrivacyLevel = "friends"
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Friends Only")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("Only your friends can see your waffles")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedPrivacyLevel == "friends" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 24))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPrivacyLevel == "friends" ? Color.purple.opacity(0.1) : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedPrivacyLevel == "friends" ? Color.purple : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)

                Spacer()

                // Save Button
                Button(action: {
                    onSave()
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = false
    @State private var isCheckingStatus = true
    @State private var showSystemSettingsAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: "bell.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                }
                .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Get notified when friends post their waffles")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Divider()
                    .padding(.horizontal)

                // Notification Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Notifications")
                            .font(.headline)

                        Text("Receive push notifications")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if isCheckingStatus {
                        ProgressView()
                    } else {
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .onChange(of: notificationsEnabled) { newValue in
                                Task {
                                    if newValue {
                                        // Try to enable notifications
                                        do {
                                            try await notificationManager.requestAuthorization()
                                            // Check if it was actually enabled
                                            let status = await notificationManager.checkAuthorizationStatus()
                                            await MainActor.run {
                                                if !status {
                                                    // Permission was denied - show alert
                                                    notificationsEnabled = false
                                                    showSystemSettingsAlert = true
                                                }
                                            }
                                        } catch {
                                            await MainActor.run {
                                                notificationsEnabled = false
                                                showSystemSettingsAlert = true
                                            }
                                        }
                                    } else {
                                        // Can't disable from app - show alert
                                        showSystemSettingsAlert = true
                                        notificationsEnabled = true
                                    }
                                }
                            }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // Info text
                Text("To change notification settings, go to your device Settings app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await checkNotificationStatus()
            }
            .alert("Open Settings", isPresented: $showSystemSettingsAlert) {
                Button("Cancel", role: .cancel) {
                    // Refresh status when alert is dismissed
                    Task {
                        await checkNotificationStatus()
                    }
                }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("To change notification permissions, please go to Settings > WaffleWednesday > Notifications")
            }
        }
    }

    private func checkNotificationStatus() async {
        isCheckingStatus = true
        let status = await notificationManager.checkAuthorizationStatus()
        await MainActor.run {
            notificationsEnabled = status
            isCheckingStatus = false
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(FirebaseManager.shared)
    }
}
