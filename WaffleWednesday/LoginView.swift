//
//  LoginView.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager

    @State private var showPhoneLogin = false
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

                VStack(spacing: 30) {
                    Spacer()

                    // App Logo - Cartoon Waffle
                    CartoonWaffleView()
                        .frame(width: 120, height: 120)

                    // App Title
                    Text("Waffle Wednesday")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Welcome back!")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Spacer()

                    // Login Options
                    VStack(spacing: 16) {
                        // Sign in with Apple Button
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 55)
                        .cornerRadius(12)

                        // Phone Number Login Button
                        Button(action: {
                            showPhoneLogin.toggle()
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 20))
                                Text("Continue with Phone Number")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    // Terms and Privacy
                    Text("By continuing, you agree to our Terms and Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
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
            .sheet(isPresented: $showPhoneLogin) {
                PhoneLoginView(onLoginSuccess: {
                    showPhoneLogin = false
                    dismiss()
                    onLoginSuccess()
                })
            }
            // TODO: Add PermissionsView when integrated
            // .sheet(isPresented: $showPermissions) {
            //     PermissionsView()
            // }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                isLoading = true
                errorMessage = nil

                let userID = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                let fullNameString = [fullName?.givenName, fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                print("User ID: \(userID)")
                print("Email: \(email ?? "N/A")")
                print("Name: \(fullNameString)")

                // Sign in with Firebase
                Task {
                    do {
                        try await firebaseManager.signInWithApple(
                            userId: userID,
                            email: email,
                            fullName: fullNameString.isEmpty ? nil : fullNameString
                        )

                        await MainActor.run {
                            isLoading = false
                            dismiss()
                            onLoginSuccess()
                        }
                    } catch {
                        await MainActor.run {
                            isLoading = false
                            errorMessage = "Sign in failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        case .failure(let error):
            print("Apple Sign In Error: \(error.localizedDescription)")
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onLoginSuccess: {})
            .environmentObject(FirebaseManager.shared)
    }
}
