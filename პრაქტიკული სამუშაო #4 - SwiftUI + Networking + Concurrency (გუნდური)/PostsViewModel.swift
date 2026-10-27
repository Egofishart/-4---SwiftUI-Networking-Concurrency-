//
//  ContentView.swift
//  პრაქტიკული სამუშაო #4 - SwiftUI + Networking + Concurrency (გუნდური)
//
//  Created by NikoDanelia on 27/10/2026.
//

import SwiftUI
import Combine
struct PostsView: View {
    @StateObject private var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                 
                    ProgressView("პოსტები იტვირთება...")
                        .controlSize(.large)
                } else if let error = viewModel.errorMessage {
          
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                await viewModel.loadPosts()
                            }
                        }) {
                            Text("ხელახლა ცდა")
                                .bold()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                
                    List(viewModel.posts) { post in
                        NavigationLink(value: post) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(post.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(post.body)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("პოსტები")

            .navigationDestination(for: Post.self) { post in
                Text("Post Detail View — ID: \(post.id)")
            }
            .task {
                if viewModel.posts.isEmpty {
                    await viewModel.loadPosts()
                }
            }
        }
    }
}
#Preview {
    PostsView()
}


