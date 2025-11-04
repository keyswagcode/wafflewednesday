//
//  AudioPermissionManager.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import Foundation
import AVFoundation

class AudioPermissionManager: ObservableObject {
    static let shared = AudioPermissionManager()

    @Published var microphoneAuthorized = false
    @Published var authorizationStatus: AVAudioSession.RecordPermission = .undetermined

    private init() {
        checkMicrophonePermission()
    }

    // Request microphone permission
    func requestMicrophonePermission() async -> Bool {
        let status = AVAudioSession.sharedInstance().recordPermission

        switch status {
        case .granted:
            await MainActor.run {
                self.microphoneAuthorized = true
                self.authorizationStatus = .granted
            }
            return true

        case .denied:
            await MainActor.run {
                self.microphoneAuthorized = false
                self.authorizationStatus = .denied
            }
            return false

        case .undetermined:
            // Request permission
            let granted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            await MainActor.run {
                self.microphoneAuthorized = granted
                self.authorizationStatus = granted ? .granted : .denied
            }
            return granted

        @unknown default:
            return false
        }
    }

    // Check current microphone permission status
    func checkMicrophonePermission() {
        let status = AVAudioSession.sharedInstance().recordPermission
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.microphoneAuthorized = (status == .granted)
        }
    }

    // Configure audio session for recording and playback
    func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()

        // Configure for both recording (microphone) and playback (speakers)
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true)

        print("Audio session configured successfully")
    }

    // Activate audio session for recording
    func activateAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(true)
    }

    // Deactivate audio session
    func deactivateAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }

    // Check if headphones are connected
    func isHeadphonesConnected() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for output in route.outputs {
            if output.portType == .headphones || output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP {
                return true
            }
        }
        return false
    }

    // Get current audio route description
    func getCurrentAudioRoute() -> String {
        let route = AVAudioSession.sharedInstance().currentRoute
        let inputs = route.inputs.map { $0.portName }.joined(separator: ", ")
        let outputs = route.outputs.map { $0.portName }.joined(separator: ", ")
        return "Inputs: \(inputs), Outputs: \(outputs)"
    }
}
