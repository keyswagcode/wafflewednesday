//
//  PhoneLoginView.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/24/25.
//

import SwiftUI

struct PhoneLoginView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager

    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var userName = ""
    @State private var isCodeSent = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var onLoginSuccess: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        Spacer()
                            .frame(height: 40)

                        // Icon - Cartoon Waffle
                        CartoonWaffleView()
                            .frame(width: 80, height: 80)

                        // Title
                        Text(isCodeSent ? "Enter Code" : "Phone Login")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text(isCodeSent
                            ? "We sent a verification code to \(phoneNumber)"
                            : "Enter your phone number to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        // Input Fields
                        VStack(spacing: 20) {
                            if !isCodeSent {
                                // Phone Number Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Phone Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    TextField("+1 (555) 123-4567", text: $phoneNumber)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                        )
                                }

                                // Name Input (for new users)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Name (optional)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    TextField("John Doe", text: $userName)
                                        .textContentType(.name)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                        )
                                }

                                // Send Code Button
                                Button(action: sendVerificationCode) {
                                    Text("Send Verification Code")
                                        .font(.system(size: 17, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(phoneNumber.isEmpty ? Color.gray : Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .disabled(phoneNumber.isEmpty)

                            } else {
                                // Verification Code Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Verification Code")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    TextField("123456", text: $verificationCode)
                                        .keyboardType(.numberPad)
                                        .textContentType(.oneTimeCode)
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                        )
                                }

                                // Verify Button
                                Button(action: verifyCode) {
                                    Text("Verify & Sign In")
                                        .font(.system(size: 17, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(verificationCode.isEmpty ? Color.gray : Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .disabled(verificationCode.isEmpty)

                                // Resend Code
                                Button(action: sendVerificationCode) {
                                    Text("Resend Code")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.purple)
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                        Spacer()

                        // Helper text
                        if !isCodeSent {
                            VStack(spacing: 8) {
                                Text("We'll send you a verification code via SMS")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)

                                Text("Enter your phone number with country code (e.g., +1 555-123-4567)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 40)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(30)
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }

    private func sendVerificationCode() {
        guard !phoneNumber.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        // Format phone number to include country code if not present
        var formattedNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedNumber.hasPrefix("+") {
            formattedNumber = "+1" + formattedNumber.filter { $0.isNumber }
        }

        Task {
            do {
                try await firebaseManager.sendVerificationCode(to: formattedNumber)

                await MainActor.run {
                    isLoading = false
                    isCodeSent = true
                    verificationCode = ""
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to send code: \(error.localizedDescription)"
                }
            }
        }
    }

    private func verifyCode() {
        guard !verificationCode.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        // Format phone number
        var formattedNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedNumber.hasPrefix("+") {
            formattedNumber = "+1" + formattedNumber.filter { $0.isNumber }
        }

        Task {
            do {
                try await firebaseManager.verifyCodeAndSignIn(
                    code: verificationCode,
                    phoneNumber: formattedNumber,
                    userName: userName.isEmpty ? "User" : userName
                )

                await MainActor.run {
                    isLoading = false
                    dismiss()
                    onLoginSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Verification failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView(onLoginSuccess: {})
            .environmentObject(FirebaseManager.shared)
    }
}
