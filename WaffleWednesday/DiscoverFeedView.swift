//
//  DiscoverFeedView.swift
//  WaffleWednesday
//
//  Created by Claude on 10/26/25.
//

import SwiftUI

struct DiscoverFeedView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var discoverWaffles: [WafflePost] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Discover")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text("Trending waffles & celebrities")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()

                    if isLoading {
                        ProgressView()
                            .padding(40)
                    } else if discoverWaffles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow.opacity(0.5))

                            Text("Nothing to discover yet")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Check back soon for featured content!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(discoverWaffles) { waffle in
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
                await loadDiscoverWaffles()
            }
            .task {
                await loadDiscoverWaffles()
            }
    }

    private func loadDiscoverWaffles() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // In the future, this could fetch trending or featured waffles
            discoverWaffles = try await firebaseManager.fetchPublicWaffles()
        } catch {
            print("Error loading discover waffles: \(error)")
        }
    }
}

struct DiscoverFeedView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverFeedView()
            .environmentObject(FirebaseManager.shared)
    }
}
