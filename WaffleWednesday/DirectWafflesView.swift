//
//  DirectWafflesView.swift
//  WaffleWednesday
//
//  Created by Claude on 11/01/25.
//

import SwiftUI
import AVFoundation

struct DirectWafflesView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var directWaffles: [DirectWaffle] = []
    @State private var isLoading = false
    @State private var playingWaffleId: String?
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Direct Waffles")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text("Replies sent to you")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()

                    if isLoading {
                        ProgressView()
                            .padding(40)
                    } else if directWaffles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple.opacity(0.5))

                            Text("No direct waffles yet")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("When friends reply to your waffles,\nthey'll appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(directWaffles) { waffle in
                                DirectWaffleCard(
                                    waffle: waffle,
                                    isPlaying: playingWaffleId == waffle.id,
                                    onPlay: {
                                        if playingWaffleId == waffle.id {
                                            stopPlayback()
                                        } else {
                                            playWaffle(waffle)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .refreshable {
                await loadDirectWaffles()
            }
            .task {
                await loadDirectWaffles()
            }
            .onDisappear {
                stopPlayback()
            }
    }

    private func loadDirectWaffles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            directWaffles = try await firebaseManager.fetchDirectWaffles()
        } catch {
            print("Error loading direct waffles: \(error)")
        }
    }

    private func playWaffle(_ waffle: DirectWaffle) {
        stopPlayback()

        guard let url = URL(string: waffle.audioURL) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                audioPlayer = try AVAudioPlayer(data: data)
                audioPlayer?.delegate = nil
                audioPlayer?.play()
                playingWaffleId = waffle.id
            } catch {
                print("Error playing audio: \(error)")
            }
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        playingWaffleId = nil
    }
}

struct DirectWaffleCard: View {
    let waffle: DirectWaffle
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Profile picture
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

            // Waffle info
            VStack(alignment: .leading, spacing: 4) {
                Text(waffle.fromUserName)
                    .font(.system(size: 16, weight: .semibold))

                Text(formatTimestamp(waffle.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Duration: \(formatDuration(waffle.duration))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Play button
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.red : Color.purple)
                        .frame(width: 44, height: 44)

                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct DirectWafflesView_Previews: PreviewProvider {
    static var previews: some View {
        DirectWafflesView()
            .environmentObject(FirebaseManager.shared)
    }
}
