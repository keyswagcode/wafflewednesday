//
//  FriendsWafflesView.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import SwiftUI

struct FriendsWafflesView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var friendWaffles: [WafflePost] = []
    @State private var isLoading = false
    @State private var replyingToWaffle: WafflePost?

    var body: some View {
        ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Friends' Waffles")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text("Listen to what your friends shared this Wednesday")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()

                    if isLoading {
                        ProgressView()
                            .padding(40)
                    } else if friendWaffles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))

                            Text("No Waffles Yet")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Invite friends to share their Wednesday waffles!\nYou'll see them here once they record.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Button(action: {
                                // TODO: Share/invite friends
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Invite Friends")
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(friendWaffles) { waffle in
                                AudioPlayerView(
                                    waffle: waffle,
                                    canReply: true,
                                    onReply: {
                                        replyingToWaffle = waffle
                                    }
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .refreshable {
                await loadFriendWaffles()
            }
            .task {
                await loadFriendWaffles()
            }
            .sheet(item: $replyingToWaffle) { waffle in
                ReplyRecordingView(originalWaffle: waffle)
                    .environmentObject(firebaseManager)
            }
    }

    private func loadFriendWaffles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch waffles from friends
            friendWaffles = try await firebaseManager.fetchFriendsWaffles()
        } catch {
            print("Error loading friend waffles: \(error)")
        }
    }
}

struct ReplyRecordingView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.dismiss) var dismiss
    let originalWaffle: WafflePost

    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isSending = false
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Original waffle info
                VStack(spacing: 12) {
                    Text("Replying to")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.7), Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)

                            Text(originalWaffle.profileInitial)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(originalWaffle.userName)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()

                // Recording UI
                VStack(spacing: 20) {
                    if audioRecorder.isRecording {
                        VStack(spacing: 12) {
                            Text("Recording...")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text(audioRecorder.formattedTime(audioRecorder.recordingTime))
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(.purple)

                            Circle()
                                .fill(Color.red)
                                .frame(width: 20, height: 20)
                                .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(), value: audioRecorder.isRecording)
                        }
                    }

                    Button(action: {
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                        } else {
                            audioRecorder.startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(audioRecorder.isRecording ? Color.red : Color.purple)
                                .frame(width: 100, height: 100)

                            Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(isSending)

                    if audioRecorder.hasRecording {
                        VStack(spacing: 12) {
                            Text("Duration: \(audioRecorder.formattedTime(audioRecorder.recordingTime))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button(action: sendReply) {
                                if isSending {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Send Reply")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .disabled(isSending)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Record Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Reply Sent!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your reply has been sent to \(originalWaffle.userName). They'll see it in their Direct Waffles tab!")
            }
        }
    }

    private func sendReply() {
        guard let audioURL = audioRecorder.getRecordingURL() else { return }
        let duration = audioRecorder.getRecordingDuration()
        isSending = true

        Task {
            do {
                try await firebaseManager.sendReply(to: originalWaffle.userId, audioURL: audioURL, duration: duration)
                audioRecorder.deleteRecording()

                await MainActor.run {
                    isSending = false
                    showSuccessAlert = true
                }
            } catch {
                print("Error sending reply: \(error)")
                await MainActor.run {
                    isSending = false
                }
            }
        }
    }
}

struct FriendsWafflesView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsWafflesView()
            .environmentObject(FirebaseManager.shared)
    }
}
