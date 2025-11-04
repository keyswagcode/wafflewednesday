//
//  PublicFeedView.swift
//  WaffleWednesday
//
//  Created by Claude on 10/26/25.
//

import SwiftUI

struct PublicFeedView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var publicWaffles: [WafflePost] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Public Feed")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text("Listen to everyone's waffles")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()

                    if isLoading {
                        ProgressView()
                            .padding(40)
                    } else if publicWaffles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "waveform")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))

                            Text("No waffles yet")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Be the first to record this Wednesday!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(publicWaffles) { waffle in
                                AudioPlayerView(
                                    waffle: waffle,
                                    canReply: false,
                                    onReply: nil
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .refreshable {
                await loadPublicWaffles()
            }
            .task {
                await loadPublicWaffles()
            }
    }

    private func loadPublicWaffles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch all waffles for current Wednesday
            publicWaffles = try await firebaseManager.fetchPublicWaffles()
        } catch {
            print("Error loading public waffles: \(error)")
        }
    }
}

struct PublicFeedView_Previews: PreviewProvider {
    static var previews: some View {
        PublicFeedView()
            .environmentObject(FirebaseManager.shared)
    }
}
