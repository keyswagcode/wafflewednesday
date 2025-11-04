//
//  AudioPlayerView.swift
//  WaffleWednesday
//
//  Created by Claude on 10/26/25.
//

import SwiftUI
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var player: AVPlayer?
    private var timeObserver: Any?

    func playAudio(from url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Observe time
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }

        // Get duration
        Task { @MainActor in
            if let duration = try? await playerItem.asset.load(.duration) {
                self.duration = duration.seconds
            }
        }

        player?.play()
        isPlaying = true

        // Observe when finished
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
            self?.currentTime = 0
            self?.player?.seek(to: .zero)
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}

struct AudioPlayerView: View {
    let waffle: WafflePost
    let canReply: Bool
    let onReply: (() -> Void)?

    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var isLoadingAudio = false
    @State private var comments: [WaffleComment] = []
    @State private var showComments = false
    @State private var newCommentText = ""
    @State private var isLoadingComments = false
    @State private var isPostingComment = false
    @EnvironmentObject var firebaseManager: FirebaseManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack(spacing: 12) {
                // Profile circle
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

                    Text(waffle.profileInitial)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(waffle.userName)
                        .font(.system(size: 17, weight: .semibold))

                    Text(waffle.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if canReply, let onReply = onReply {
                    Button(action: onReply) {
                        Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(15)
                    }
                }
            }

            // Audio player controls
            VStack(spacing: 12) {
                // Play button and waveform
                HStack(spacing: 15) {
                    Button(action: {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            if audioPlayer.currentTime == 0 {
                                loadAndPlayAudio()
                            } else {
                                audioPlayer.resume()
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 44, height: 44)

                            if isLoadingAudio {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(isLoadingAudio)

                    // Waveform visualization (simplified)
                    HStack(spacing: 2) {
                        ForEach(0..<40) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.purple.opacity(audioPlayer.currentTime > 0 && Double(index) / 40.0 < (audioPlayer.currentTime / audioPlayer.duration) ? 1.0 : 0.3))
                                .frame(width: 3, height: CGFloat.random(in: 8...30))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Duration
                    Text(formatTime(audioPlayer.duration))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 40)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        if audioPlayer.duration > 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.purple)
                                .frame(width: geometry.size.width * (audioPlayer.currentTime / audioPlayer.duration), height: 4)
                        }
                    }
                }
                .frame(height: 4)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)

            // Comments section
            VStack(alignment: .leading, spacing: 12) {
                    // Comments toggle button
                    Button(action: {
                        showComments.toggle()
                        if showComments && comments.isEmpty {
                            loadComments()
                        }
                    }) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                            Text("\(comments.count) \(comments.count == 1 ? "Comment" : "Comments")")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Image(systemName: showComments ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    }

                    // Comments list
                    if showComments {
                        if isLoadingComments {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else if comments.isEmpty {
                            Text("No comments yet. Be the first to comment!")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(comments) { comment in
                                    CommentView(comment: comment)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Comment input
                        HStack(spacing: 12) {
                            TextField("Add a comment...", text: $newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 14))

                            Button(action: {
                                postComment()
                            }) {
                                if isPostingComment {
                                    ProgressView()
                                } else {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(newCommentText.isEmpty ? .gray : .purple)
                                }
                            }
                            .disabled(newCommentText.isEmpty || isPostingComment)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            loadComments()
        }
    }

    private func loadAndPlayAudio() {
        guard let url = URL(string: waffle.audioURL) else { return }
        isLoadingAudio = true

        // Download and play
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingAudio = false
                if error == nil, let data = data {
                    // Save temporarily and play
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
                    try? data.write(to: tempURL)
                    audioPlayer.playAudio(from: tempURL)
                }
            }
        }.resume()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func loadComments() {
        print("🔄 loadComments called for waffle: \(waffle.id)")
        isLoadingComments = true
        Task {
            do {
                let fetchedComments = try await firebaseManager.fetchComments(waffleId: waffle.id)
                print("📦 Fetched \(fetchedComments.count) comments")
                await MainActor.run {
                    comments = fetchedComments
                    isLoadingComments = false
                    print("✅ Comments updated in UI: \(comments.count)")
                }
            } catch {
                print("❌ Error loading comments: \(error)")
                await MainActor.run {
                    isLoadingComments = false
                }
            }
        }
    }

    private func postComment() {
        guard !newCommentText.isEmpty else {
            print("⚠️ Empty comment text, not posting")
            return
        }

        guard let user = firebaseManager.currentUser else {
            print("❌ No user logged in")
            return
        }

        let commentText = newCommentText
        print("📝 postComment UI called with text: '\(commentText)'")
        newCommentText = ""
        isPostingComment = true

        // Create the comment object
        let newComment = WaffleComment(
            id: UUID().uuidString,
            waffleId: waffle.id,
            userId: user.id,
            userName: user.name,
            text: commentText,
            timestamp: Date()
        )

        // Add comment to UI immediately (optimistic update)
        comments.append(newComment)

        Task {
            do {
                print("🚀 Calling FirebaseManager.postComment...")
                try await firebaseManager.postComment(waffleId: waffle.id, text: commentText)
                print("✅ Comment posted successfully")

                await MainActor.run {
                    isPostingComment = false
                }
            } catch {
                print("❌ Error posting comment: \(error)")
                await MainActor.run {
                    // Remove the optimistic comment and restore text on error
                    comments.removeAll { $0.id == newComment.id }
                    newCommentText = commentText
                    isPostingComment = false
                }
            }
        }
    }
}

// MARK: - Comment View
struct CommentView: View {
    let comment: WaffleComment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.7), Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Text(comment.profileInitial)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(comment.userName)
                        .font(.system(size: 14, weight: .semibold))

                    Text(comment.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Text(comment.text)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}
