//
//  FirebaseManager.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - Models
enum PrivacyLevel: String, Codable {
    case friendsOnly = "friends"
    case publicAndFriends = "public"
}

struct WafflePost: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let audioURL: String
    let duration: TimeInterval
    let timestamp: Date
    let wednesdayDate: String // Format: "YYYY-MM-DD"
    let privacyLevel: String // "friends" or "public"

    var profileInitial: String {
        String(userName.prefix(1)).uppercased()
    }
}

struct UserProfile: Codable {
    let id: String
    var name: String
    let phoneNumber: String?
    let appleId: String?
    var friendIds: [String]
    let createdAt: Date
    var profileImageURL: String?
    var favoriteFriendIds: [String]? // Top 3 starred friends
    var friendInteractions: [String: Int]? // userId -> interaction count
    var privacyLevel: String? // "friends" or "public" - defaults to "public"
}

struct WaffleComment: Identifiable, Codable {
    let id: String
    let waffleId: String
    let userId: String
    let userName: String
    let text: String
    let timestamp: Date

    var profileInitial: String {
        String(userName.prefix(1)).uppercased()
    }
}

struct DirectWaffle: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let fromUserName: String
    let toUserId: String
    let audioURL: String
    let timestamp: Date
    let duration: TimeInterval

    var profileInitial: String {
        String(fromUserName.prefix(1)).uppercased()
    }
}

// MARK: - Firebase Manager
@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    @Published var currentUser: UserProfile?
    @Published var friendWaffles: [WafflePost] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                Task {
                    try? await self?.loadUserProfile(userId: user.uid)
                }
            } else {
                self?.currentUser = nil
            }
        }
    }

    // MARK: - Authentication

    private var verificationID: String?

    /// Send verification code to phone number
    func sendVerificationCode(to phoneNumber: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let verificationID = verificationID else {
                    continuation.resume(throwing: NSError(domain: "FirebaseManager", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No verification ID received"]))
                    return
                }

                Task { @MainActor in
                    self?.verificationID = verificationID
                    print("Verification code sent to \(phoneNumber)")
                }
                continuation.resume()
            }
        }
    }

    /// Verify code and sign in with phone number
    func verifyCodeAndSignIn(code: String, phoneNumber: String, userName: String) async throws {
        guard let verificationID = self.verificationID else {
            throw NSError(domain: "FirebaseManager", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No verification ID found. Please request a new code."])
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        let userId = authResult.user.uid

        // Check if user exists
        let userDoc = try await db.collection("users").document(userId).getDocument()

        if userDoc.exists {
            try await loadUserProfile(userId: userId)
        } else {
            // Create new user
            let user = UserProfile(
                id: userId,
                name: userName,
                phoneNumber: phoneNumber,
                appleId: nil,
                friendIds: [],
                createdAt: Date()
            )

            try db.collection("users").document(userId).setData(from: user)

            await MainActor.run {
                self.currentUser = user
            }
        }

        // Clear verification ID after successful sign in
        self.verificationID = nil
    }

    /// Sign in or create user with Apple ID
    func signInWithApple(userId: String, email: String?, fullName: String?) async throws {
        // Check if user exists in Firestore
        let userDoc = try await db.collection("users").document(userId).getDocument()

        if userDoc.exists {
            // Load existing user
            try await loadUserProfile(userId: userId)
        } else {
            // Create new user
            let user = UserProfile(
                id: userId,
                name: fullName ?? "User",
                phoneNumber: nil,
                appleId: userId,
                friendIds: [],
                createdAt: Date()
            )

            // Save to Firestore
            try db.collection("users").document(userId).setData(from: user)

            await MainActor.run {
                self.currentUser = user
            }
        }
    }

    /// Load user profile from Firestore
    private func loadUserProfile(userId: String) async throws {
        let userDoc = try await db.collection("users").document(userId).getDocument()
        let user = try userDoc.data(as: UserProfile.self)

        await MainActor.run {
            self.currentUser = user
        }
    }

    // MARK: - Waffle Management

    /// Upload a waffle recording
    func uploadWaffle(audioURL: URL, duration: TimeInterval) async throws -> String {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        print("📤 Starting waffle upload...")
        print("   User: \(user.name) (\(user.id))")
        print("   Duration: \(duration)s")

        // Upload audio file to Firebase Storage
        let audioRef = storage.reference().child("waffles/\(user.id)/\(Date().timeIntervalSince1970).m4a")
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        print("   Uploading audio to Storage...")
        _ = try await audioRef.putFileAsync(from: audioURL, metadata: metadata)
        let downloadURL = try await audioRef.downloadURL()
        print("   ✅ Audio uploaded: \(downloadURL)")

        // Create waffle post with user's privacy setting
        let wednesdayDate = getCurrentWednesdayDateString()
        let privacyLevel = user.privacyLevel ?? "public" // Default to public if not set
        let waffle = WafflePost(
            id: UUID().uuidString,
            userId: user.id,
            userName: user.name,
            audioURL: downloadURL.absoluteString,
            duration: duration,
            timestamp: Date(),
            wednesdayDate: wednesdayDate,
            privacyLevel: privacyLevel
        )

        print("   Saving to Firestore...")
        print("   Wednesday date: \(wednesdayDate)")
        print("   Privacy: \(privacyLevel)")

        // Save to Firestore
        try db.collection("waffles").document(waffle.id).setData(from: waffle)

        print("✅ Waffle uploaded successfully: \(waffle.id)")

        // Cleanup: Keep only the last 2 waffles for this user
        try await cleanupOldWaffles()

        return waffle.id
    }

    /// Keep only the last 2 waffles for the current user, delete older ones
    func cleanupOldWaffles() async throws {
        guard let user = currentUser else {
            return
        }

        print("🧹 Cleaning up old waffles for user: \(user.id)")

        // Fetch all waffles by this user
        let snapshot = try await db.collection("waffles")
            .whereField("userId", isEqualTo: user.id)
            .getDocuments()

        let waffles = try snapshot.documents.compactMap { doc in
            try doc.data(as: WafflePost.self)
        }

        // Sort by timestamp, newest first
        let sortedWaffles = waffles.sorted { $0.timestamp > $1.timestamp }

        print("   Found \(sortedWaffles.count) total waffles")

        // Keep only the first 2, delete the rest
        if sortedWaffles.count > 2 {
            let wafflesToDelete = Array(sortedWaffles.dropFirst(2))
            print("   Deleting \(wafflesToDelete.count) old waffles")

            for waffle in wafflesToDelete {
                // Delete from Firestore
                try await db.collection("waffles").document(waffle.id).delete()
                print("   🗑️ Deleted from Firestore: \(waffle.id)")

                // Delete from Storage
                if let storageURL = URL(string: waffle.audioURL) {
                    let audioRef = storage.reference(forURL: waffle.audioURL)
                    try await audioRef.delete()
                    print("   🗑️ Deleted from Storage: \(waffle.audioURL)")
                }
            }

            print("✅ Cleanup complete: kept 2, deleted \(wafflesToDelete.count)")
        } else {
            print("   ✅ No cleanup needed (\(sortedWaffles.count) waffles)")
        }
    }

    /// Fetch friends' waffles for current Wednesday
    func fetchFriendsWaffles() async throws -> [WafflePost] {
        guard let user = currentUser else {
            return []
        }

        let wednesdayDate = getCurrentWednesdayDateString()

        // Fetch from Firestore
        // Note: Removed .order(by:) to avoid requiring a composite index
        var query: Query = db.collection("waffles")
            .whereField("wednesdayDate", isEqualTo: wednesdayDate)

        // Filter by friend IDs if user has friends
        if !user.friendIds.isEmpty {
            query = query.whereField("userId", in: user.friendIds)
        }

        let snapshot = try await query.getDocuments()

        let waffles = try snapshot.documents.compactMap { doc in
            try doc.data(as: WafflePost.self)
        }

        // Sort in memory by timestamp, newest first
        let sortedWaffles = waffles.sorted { $0.timestamp > $1.timestamp }

        await MainActor.run {
            self.friendWaffles = sortedWaffles
        }

        return sortedWaffles
    }

    /// Fetch all public waffles for current Wednesday
    func fetchPublicWaffles() async throws -> [WafflePost] {
        let wednesdayDate = getCurrentWednesdayDateString()

        // Fetch from Firestore - only public waffles
        // Note: Removed .order(by:) to avoid requiring a composite index
        let snapshot = try await db.collection("waffles")
            .whereField("wednesdayDate", isEqualTo: wednesdayDate)
            .whereField("privacyLevel", isEqualTo: "public")
            .getDocuments()

        let waffles = try snapshot.documents.compactMap { doc in
            try doc.data(as: WafflePost.self)
        }

        // Sort in memory by timestamp, newest first, then take top 50
        let sortedWaffles = waffles.sorted { $0.timestamp > $1.timestamp }.prefix(50)

        return Array(sortedWaffles)
    }

    /// Check if user has already posted this Wednesday
    func hasPostedThisWednesday() async throws -> Bool {
        guard let user = currentUser else {
            return false
        }

        let wednesdayDate = getCurrentWednesdayDateString()

        // Check Firestore
        let snapshot = try await db.collection("waffles")
            .whereField("userId", isEqualTo: user.id)
            .whereField("wednesdayDate", isEqualTo: wednesdayDate)
            .getDocuments()

        return !snapshot.isEmpty
    }

    /// Fetch user's own waffles
    func fetchMyWaffles() async throws -> [WafflePost] {
        guard let user = currentUser else {
            print("⚠️ No user logged in when fetching waffles")
            return []
        }

        print("📥 Fetching waffles for user: \(user.name) (\(user.id))")

        // Fetch all waffles by this user
        // Note: Removed .order(by:) to avoid requiring a composite index
        // We'll sort in memory instead
        let snapshot = try await db.collection("waffles")
            .whereField("userId", isEqualTo: user.id)
            .getDocuments()

        print("   Found \(snapshot.documents.count) documents")

        let waffles = try snapshot.documents.compactMap { doc in
            try doc.data(as: WafflePost.self)
        }

        // Sort in memory by timestamp, newest first
        let sortedWaffles = waffles.sorted { $0.timestamp > $1.timestamp }

        print("✅ Fetched \(sortedWaffles.count) waffles")
        for (index, waffle) in sortedWaffles.enumerated() {
            print("   \(index + 1). \(waffle.wednesdayDate) - \(waffle.duration)s - \(waffle.privacyLevel)")
        }

        return sortedWaffles
    }

    /// Send a reply waffle to another user
    func sendReply(to userId: String, audioURL: URL, duration: TimeInterval) async throws {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        // Upload audio file to Firebase Storage
        let audioRef = storage.reference().child("replies/\(user.id)/\(Date().timeIntervalSince1970).m4a")
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        _ = try await audioRef.putFileAsync(from: audioURL, metadata: metadata)
        let downloadURL = try await audioRef.downloadURL()

        // Create reply document
        let reply = [
            "id": UUID().uuidString,
            "fromUserId": user.id,
            "fromUserName": user.name,
            "toUserId": userId,
            "audioURL": downloadURL.absoluteString,
            "duration": duration,
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]

        // Save to Firestore
        try await db.collection("replies").addDocument(data: reply)

        print("Reply sent to user: \(userId)")
    }

    /// Fetch direct waffles (replies) sent to the current user
    func fetchDirectWaffles() async throws -> [DirectWaffle] {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        let snapshot = try await db.collection("replies")
            .whereField("toUserId", isEqualTo: user.id)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        var directWaffles: [DirectWaffle] = []
        for document in snapshot.documents {
            let data = document.data()

            if let id = data["id"] as? String,
               let fromUserId = data["fromUserId"] as? String,
               let fromUserName = data["fromUserName"] as? String,
               let toUserId = data["toUserId"] as? String,
               let audioURL = data["audioURL"] as? String,
               let timestamp = data["timestamp"] as? Timestamp,
               let duration = data["duration"] as? TimeInterval {

                let directWaffle = DirectWaffle(
                    id: id,
                    fromUserId: fromUserId,
                    fromUserName: fromUserName,
                    toUserId: toUserId,
                    audioURL: audioURL,
                    timestamp: timestamp.dateValue(),
                    duration: duration
                )
                directWaffles.append(directWaffle)
            }
        }

        return directWaffles
    }

    // MARK: - Friends Management

    /// Add friend by user ID
    func addFriend(userId: String) async throws {
        guard let user = self.currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        // Update Firestore
        try await db.collection("users").document(user.id).updateData([
            "friendIds": FieldValue.arrayUnion([userId])
        ])

        // Update local state
        await MainActor.run {
            if var updatedUser = self.currentUser,
               !updatedUser.friendIds.contains(userId) {
                updatedUser.friendIds.append(userId)
                self.currentUser = updatedUser
            }
        }

        print("Friend added: \(userId)")
    }

    /// Find users by phone numbers
    func findUsersByPhoneNumbers(_ phoneNumbers: [String]) async throws -> [UserProfile] {
        // Firestore 'in' queries have a limit of 10 items, so we need to batch
        let batchSize = 10
        var allUsers: [UserProfile] = []

        for i in stride(from: 0, to: phoneNumbers.count, by: batchSize) {
            let end = min(i + batchSize, phoneNumbers.count)
            let batch = Array(phoneNumbers[i..<end])

            let snapshot = try await db.collection("users")
                .whereField("phoneNumber", in: batch)
                .getDocuments()

            let users = try snapshot.documents.compactMap { doc in
                try doc.data(as: UserProfile.self)
            }

            allUsers.append(contentsOf: users)
        }

        return allUsers
    }

    // MARK: - Profile Management

    /// Upload profile picture and update user profile
    func uploadProfilePicture(image: UIImage) async throws {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        // Upload to Firebase Storage
        let imageRef = storage.reference().child("profile_pictures/\(user.id).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await imageRef.downloadURL()

        // Update Firestore
        try await db.collection("users").document(user.id).updateData([
            "profileImageURL": downloadURL.absoluteString
        ])

        // Update local state
        await MainActor.run {
            if var updatedUser = self.currentUser {
                updatedUser.profileImageURL = downloadURL.absoluteString
                self.currentUser = updatedUser
            }
        }

        print("Profile picture uploaded successfully")
    }

    /// Update user's privacy level
    func updatePrivacyLevel(_ level: String) async throws {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        // Update Firestore
        try await db.collection("users").document(user.id).updateData([
            "privacyLevel": level
        ])

        // Update local state
        await MainActor.run {
            if var updatedUser = self.currentUser {
                updatedUser.privacyLevel = level
                self.currentUser = updatedUser
            }
        }

        print("Privacy level updated to: \(level)")
    }

    // MARK: - Comments Management

    /// Post a comment on a waffle
    func postComment(waffleId: String, text: String) async throws {
        print("💬 postComment called - waffleId: \(waffleId), text: \(text)")

        guard let user = currentUser else {
            print("❌ No user logged in")
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        print("✅ User found: \(user.name)")

        let comment = WaffleComment(
            id: UUID().uuidString,
            waffleId: waffleId,
            userId: user.id,
            userName: user.name,
            text: text,
            timestamp: Date()
        )

        print("💾 Saving comment to Firestore...")
        try await db.collection("comments").document(comment.id).setData(from: comment)
        print("✅ Comment posted successfully: \(comment.id)")
    }

    /// Fetch comments for a waffle
    func fetchComments(waffleId: String) async throws -> [WaffleComment] {
        let snapshot = try await db.collection("comments")
            .whereField("waffleId", isEqualTo: waffleId)
            .getDocuments()

        let comments = try snapshot.documents.compactMap { doc in
            try doc.data(as: WaffleComment.self)
        }

        // Sort by timestamp (oldest first) in memory to avoid requiring a Firestore index
        return comments.sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Helper Methods

    private func getCurrentWednesdayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        if weekday == 4 { // Wednesday
            return formatter.string(from: today)
        } else if weekday < 4 {
            // Get last Wednesday
            let daysToSubtract = weekday + 3
            let lastWednesday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
            return formatter.string(from: lastWednesday)
        } else {
            // Get last Wednesday
            let daysToSubtract = weekday - 4
            let lastWednesday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
            return formatter.string(from: lastWednesday)
        }
    }
}
