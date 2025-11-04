//
//  ContactsManager.swift
//  WaffleWednesday
//
//  Created by Keyan Chang on 10/23/25.
//

import Foundation
import Contacts
import SwiftUI

// MARK: - Contact Model
struct ContactInfo: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    var isOnWaffleWednesday: Bool = false
    var userId: String?
}

// MARK: - Contacts Manager
class ContactsManager: ObservableObject {
    static let shared = ContactsManager()

    @Published var contacts: [ContactInfo] = []
    @Published var friendsOnApp: [ContactInfo] = []
    @Published var isAuthorized = false
    @Published var authorizationStatus: CNAuthorizationStatus = .notDetermined

    private let contactStore = CNContactStore()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Permission Management

    /// Check current authorization status
    func checkAuthorizationStatus() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.isAuthorized = (status == .authorized)
        }
    }

    /// Request contacts permission
    func requestAccess() async -> Bool {
        do {
            let granted = try await contactStore.requestAccess(for: .contacts)
            await MainActor.run {
                self.isAuthorized = granted
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Error requesting contacts access: \(error)")
            return false
        }
    }

    // MARK: - Contact Fetching

    /// Fetch all contacts from device
    func fetchContacts() async throws -> [ContactInfo] {
        guard authorizationStatus == .authorized else {
            throw NSError(domain: "ContactsManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Contacts access not authorized"])
        }

        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var fetchedContacts: [ContactInfo] = []

        try contactStore.enumerateContacts(with: request) { contact, _ in
            let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)

            // Extract phone numbers
            for phoneNumber in contact.phoneNumbers {
                let number = phoneNumber.value.stringValue
                let cleanedNumber = self.cleanPhoneNumber(number)

                if !cleanedNumber.isEmpty {
                    let contactInfo = ContactInfo(
                        name: fullName.isEmpty ? "Unknown" : fullName,
                        phoneNumber: cleanedNumber
                    )
                    fetchedContacts.append(contactInfo)
                }
            }
        }

        await MainActor.run {
            self.contacts = fetchedContacts
        }

        return fetchedContacts
    }

    /// Find which contacts are on Waffle Wednesday
    func findFriendsOnApp() async throws {
        let contacts = try await fetchContacts()
        let phoneNumbers = contacts.map { $0.phoneNumber }

        // Query Firebase for users with these phone numbers
        let usersOnApp = try await FirebaseManager.shared.findUsersByPhoneNumbers(phoneNumbers)

        // Match contacts with users
        var friendsFound: [ContactInfo] = []

        for var contact in contacts {
            if let user = usersOnApp.first(where: { $0.phoneNumber == contact.phoneNumber }) {
                contact.isOnWaffleWednesday = true
                contact.userId = user.id
                friendsFound.append(contact)
            }
        }

        await MainActor.run {
            self.friendsOnApp = friendsFound
        }
    }

    // MARK: - Helper Methods

    /// Clean phone number to international format
    private func cleanPhoneNumber(_ phoneNumber: String) -> String {
        let cleaned = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // Add country code if not present
        if cleaned.hasPrefix("1") && cleaned.count == 11 {
            return "+\(cleaned)"
        } else if cleaned.count == 10 {
            return "+1\(cleaned)"
        } else if cleaned.hasPrefix("+") {
            return cleaned
        }

        return "+\(cleaned)"
    }
}

// MARK: - Contact Sync View
struct ContactSyncView: View {
    @StateObject private var contactsManager = ContactsManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var searchText = ""

    var filteredFriends: [ContactInfo] {
        if searchText.isEmpty {
            return contactsManager.friendsOnApp
        } else {
            return contactsManager.friendsOnApp.filter { contact in
                contact.name.lowercased().contains(searchText.lowercased()) ||
                contact.phoneNumber.contains(searchText)
            }
        }
    }

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

                VStack(spacing: 20) {
                    if !contactsManager.isAuthorized {
                        // Permission Request
                        VStack(spacing: 30) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.orange)

                            VStack(spacing: 12) {
                                Text("Find Your Friends")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)

                                Text("Sync your contacts to find friends who are already on Waffle Wednesday")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }

                            Button(action: {
                                Task {
                                    let granted = await contactsManager.requestAccess()
                                    if granted {
                                        await syncContacts()
                                    }
                                }
                            }) {
                                Text("Sync Contacts")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)

                            Button("Skip for Now") {
                                dismiss()
                            }
                            .foregroundColor(.secondary)
                        }
                    } else {
                        // Friends List
                        VStack(spacing: 0) {
                            Text("Friends on Waffle Wednesday")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                                .padding(.bottom, 10)

                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search friends...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())

                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                            if isLoading {
                                ProgressView()
                                    .padding(.top, 40)
                            } else if contactsManager.friendsOnApp.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "person.crop.circle.badge.questionmark")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.top, 40)

                                    Text("No friends found yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)

                                    Text("Invite your friends to join Waffle Wednesday!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(filteredFriends) { contact in
                                            FriendRowView(contact: contact) {
                                                addFriend(contact)
                                            }
                                        }

                                        if !searchText.isEmpty && filteredFriends.isEmpty {
                                            VStack(spacing: 16) {
                                                Image(systemName: "magnifyingglass")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(.top, 40)

                                                Text("No friends found")
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)

                                                Text("Try a different search term")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)
                                }
                            }
                        }
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            if contactsManager.isAuthorized {
                Task {
                    await syncContacts()
                }
            }
        }
    }

    private func syncContacts() async {
        isLoading = true
        do {
            try await contactsManager.findFriendsOnApp()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    private func addFriend(_ contact: ContactInfo) {
        guard let userId = contact.userId else { return }

        Task {
            do {
                try await firebaseManager.addFriend(userId: userId)
            } catch {
                errorMessage = "Failed to add friend: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

struct FriendRowView: View {
    let contact: ContactInfo
    let onAdd: () -> Void

    @State private var isAdded = false

    var body: some View {
        HStack(spacing: 16) {
            // Profile circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.yellow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Text(String(contact.name.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                Text(contact.phoneNumber)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                onAdd()
                isAdded = true
            }) {
                Text(isAdded ? "Added" : "Add")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(isAdded ? Color.green : Color.orange)
                    .cornerRadius(20)
            }
            .disabled(isAdded)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
