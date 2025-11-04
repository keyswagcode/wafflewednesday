//
//  ShareManager.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Share Manager
class ShareManager {
    static let shared = ShareManager()

    private init() {}

    /// Generate invite message
    func generateInviteMessage() -> String {
        return """
        Hey! I'm using Waffle Wednesday - a fun app where you record a voice message every Wednesday to share with friends. Join me! 🧇

        Download here: [App Store Link]
        """
    }

    /// Share via iOS Share Sheet
    func shareInvite(from viewController: UIViewController?) {
        let message = generateInviteMessage()

        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        // For iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2,
                                       y: UIScreen.main.bounds.height / 2,
                                       width: 0,
                                       height: 0)
            popover.permittedArrowDirections = []
        }

        viewController?.present(activityViewController, animated: true)
    }
}

// MARK: - Share Sheet SwiftUI Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Share Button Component
struct ShareButton: View {
    @State private var showShareSheet = false

    var body: some View {
        Button(action: {
            showShareSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                Text("Invite Friends")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [ShareManager.shared.generateInviteMessage()])
        }
    }
}

// MARK: - Invite Friends View
struct InviteFriendsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    @State private var showContactSync = false

    var body: some View {
        NavigationView {
            ZStack {
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

                VStack(spacing: 30) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 140, height: 140)

                        Image(systemName: "person.2.wave.2.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.orange)
                    }

                    // Title & Description
                    VStack(spacing: 12) {
                        Text("Invite Friends")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        Text("Waffle Wednesday is better with friends! Invite them to join and share weekly voice messages.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    // Actions
                    VStack(spacing: 16) {
                        // Sync Contacts Button
                        Button(action: {
                            showContactSync = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 20))
                                Text("Find Friends from Contacts")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        }

                        // Share Button
                        Button(action: {
                            showShareSheet = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                Text("Share Invite Link")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.orange)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                        }

                        // Copy Link Button
                        Button(action: {
                            UIPasteboard.general.string = ShareManager.shared.generateInviteMessage()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 20))
                                Text("Copy Invite Message")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.orange)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Text("More friends = More waffles to listen to!")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 30)
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
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [ShareManager.shared.generateInviteMessage()])
            }
            .sheet(isPresented: $showContactSync) {
                ContactSyncView()
            }
        }
    }
}

struct InviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendsView()
    }
}
