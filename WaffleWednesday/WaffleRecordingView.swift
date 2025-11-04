//
//  WaffleRecordingView.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import SwiftUI

struct WaffleRecordingView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var showUploadConfirmation = false
    @Binding var hasRecordedThisWeek: Bool
    var onUpload: (URL, TimeInterval) -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.7),
                    Color(red: 1.0, green: 0.8, blue: 0.5),
                    Color.orange.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                VStack(spacing: 8) {
                    Text("Record Your Waffle")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Text(getCurrentWednesdayMessage())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                Spacer()

                // Recording Status
                VStack(spacing: 20) {
                    // Animated waffle icon
                    Image(systemName: "waveform.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(audioRecorder.isRecording ? .red : .orange)
                        .scaleEffect(audioRecorder.isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: audioRecorder.isRecording)

                    // Timer
                    Text(audioRecorder.formattedTime(audioRecorder.recordingTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)

                    // Status text
                    Text(getStatusText())
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Control Buttons
                VStack(spacing: 20) {
                    if !audioRecorder.hasRecording {
                        // Record/Stop Button
                        Button(action: {
                            if audioRecorder.isRecording {
                                audioRecorder.stopRecording()
                            } else {
                                audioRecorder.startRecording()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .font(.system(size: 24))
                                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 65)
                            .background(audioRecorder.isRecording ? Color.red : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    } else {
                        // Playback Button
                        Button(action: {
                            if audioRecorder.isPlaying {
                                audioRecorder.stopPlayback()
                            } else {
                                audioRecorder.playRecording()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: audioRecorder.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 24))
                                Text(audioRecorder.isPlaying ? "Pause" : "Listen to Your Waffle")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 65)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                        HStack(spacing: 16) {
                            // Re-record Button
                            Button(action: {
                                audioRecorder.deleteRecording()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Re-record")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }

                            // Upload Button
                            Button(action: {
                                showUploadConfirmation = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Upload Waffle")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .alert("Upload Your Waffle?", isPresented: $showUploadConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Upload") {
                if let url = audioRecorder.getRecordingURL() {
                    let duration = audioRecorder.getRecordingDuration()
                    onUpload(url, duration)
                    hasRecordedThisWeek = true
                }
            }
        } message: {
            Text("Your friends will be able to listen to this waffle. You can only record one waffle per Wednesday!")
        }
    }

    private func getStatusText() -> String {
        if audioRecorder.isRecording {
            return "Recording..."
        } else if audioRecorder.hasRecording {
            return "Recording complete!"
        } else {
            return "Tap to start recording"
        }
    }

    private func getCurrentWednesdayMessage() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "It's Wednesday, \(formatter.string(from: Date()))!\nShare what's on your mind."
    }
}
